---
layout: post
title:  "Portal Gun"
date:   2016-08-24
---

![Portal Gun Overview](/assets/images/portal-gun-overview.png)

### Thinking with portals

[Portal-Gun](https://github.com/claydotio/portal-gun) is a multi-layer iframe rpc library. It was designed to solve the problem of native mobile application embedded web API calls.
For example, you write a small wrapper application with Cordova which simply points an iframe to your content site, which can then detect and call into native functions (securely).
At Clay we had a 3rd level application layer, where we iframe our games. Above is a visualization of our `Native > Clay > 3rd Party` iframe setup.

Portal-Gun allows infinite nesting of iframe layers and upward rpc call propagation. When a `call` is made the request is propagated to the top frame. If the top frame cannot handle the request (or errors), the request is handled by the next layer below (2nd top frame), and so on until it eventually calls the local version of the method (if it exists) and then succeeds or fails.

```coffee
PortalGun = require 'portal-gun'

portal = new PortalGun({
  # Validate parent is trusted origin before sending it confidential information
  isParentValidFn: (origin) ->
    return origin is 'http://x.com'
})

portal.listen()

portal.on 'methodName', (what) -> "#{what}?"

portal.call 'methodName', 'hello' # Promise interface
.then (result) -> # 'hello?'
```
