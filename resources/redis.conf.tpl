loglevel {{ .Env.Get "REDIS_LOGLEVEL" }}
protected-mode no
port 6379
timeout 0
bind 0.0.0.0
dir {{ .Env.Get "CONF_DIR" }}/data
aclfile {{ .Env.Get "CONF_DIR" }}/data/service-accounts.acl