loglevel {{ .Env.Get "REDIS_LOGLEVEL" }}
protected-mode no
port 6379
timeout 0
bind 0.0.0.0
aclfile /usr/local/etc/redis/service-accounts.acl