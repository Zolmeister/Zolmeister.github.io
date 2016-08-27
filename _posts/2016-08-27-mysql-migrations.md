---
layout: post
title:  "MySQL Migrations"
date:   2016-08-27
---

![MySQL logo](https://zolmeister.com/assets/images/mysql-logo.jpg)

### Migrating 17M rows with no downtime - Isotope

Scenario: 17M rows in a table, constant writes/reads, slave/master setup.

If you  try to run an ALTER TABLE (especially on older versions of MySQL), most operations will lock the table for writes for the entire run-time of the query. To avoid this, we need to incrementally update the table, incorporating write changes as they arrive.

Our solution was to use the [Large Hadron Migrator](https://github.com/soundcloud/lhm), built and open-sourced by SoundCloud. LHM creates a copy table for the migration, with change triggers set up to keep up with new writes. It handles all the low-level details of the migration, and generally works well (though slowly, as I'll illustrate later).

First step is to create a migration.

```bash
$ apt-get -y install libmysqlclient-dev libmysqlclient18 ruby-dev build-essential rake
$ gem install activerecord-mysql-adapter standalone_migrations lhm
$ rake db:new_migration name=add_some_column_to_some_table
run/test locally: `RAILS_ENV=production rake db:migrate`
dump schema: `RAILS_ENV=production rake db:schema:dump`
```

Our database ran too slowly for the default change-rate of LHM (batches were too large, causing writes to time-out). By decreasing the speed of migration we avoided this, at the cost of migrations taking **20hr+** (we eventually moved away from MySQL).

```ruby
# Throttle is in ms - default 100
# Stride is in number of rows - default 40,000
options = { :stride => 16, :throttle => 100 }
```

Next, we'll build a docker container to be able to run the migration remotely

```
FROM ubuntu:14.04

RUN apt-get -y update
RUN apt-get -y install libmysqlclient-dev libmysqlclient18 ruby-dev build-essential rake
RUN gem install activerecord-mysql-adapter standalone_migrations lhm

ADD . /opt/isotope
WORKDIR /opt/isotope
```

```
docker build -t isotope .
docker push isotope
```

Finally, to run the migration itself

```
docker run -e RAILS_ENV=production -e MYSQL_MASTER_HOST=<MYSQL PRODUCTION IP> -e MYSQL_MASTER_PASS=<PASSWORD> -i -t isotope rake db:migrate
```

If something goes wrong during the migration we have to clean up the change table manually.

```
drop `lhmn_*` tables
drop `lhmn_*` triggers
```
