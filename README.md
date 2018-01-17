# envoy_discover_service

`PREFIX`  uri配置

`DOMAINS` 域名配置

`LIMITS`  熔断限制tcp默认1024, 设置0为熔断

`MaxPendingRequests` 最大挂起请求默认1024, 设置0为直接挂起请求

`MaxRequests` 最大请求数限制默认为1024, 设置0为0请求

`MaxRetries` 最大重试次数默认为3, 设置0为0重试

`WEIGHT` 权重，请求根据权重转发向下游，最大为100


