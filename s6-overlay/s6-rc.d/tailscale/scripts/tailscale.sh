#!/command/with-contenv sh

up () {
  sleep 10 # wait for tailscaled to start

  # only start tailscale if it's enabled
  [ -z "${TS_AUTH_KEY}" ] && exit 0
  
  [ "${TS_ACCEPT_ROUTES}" = "true" ]  && ARGS="--accept-routes ${ARGS}"
  [ ! -z "${TS_AUTH_KEY}" ]           && ARGS="--authkey=${TS_AUTH_KEY} ${ARGS}"
  [ ! -z "${TS_HOSTNAME}" ]           && ARGS="--hostname=${TS_HOSTNAME} ${ARGS}"
  [ ! -z "${TS_ROUTES}" ]             && ARGS="--advertise-routes=${TS_ROUTES} ${ARGS}"
  [ ! -z "${TS_EXTRA_ARGS}" ]         && ARGS="${TS_EXTRA_ARGS} ${ARGS}"
  
  tailscale set --operator=openclaw
  sleep 2
  USER=openclaw HOME=/home/openclaw s6-setuidgid openclaw tailscale up ${ARGS} 2>&1 
}

down () {
  s6-setuidgid openclaw tailscale down
}

# execute the passed in argument
$1| s6-log -bp n3 'p[tailscale]' 1 /var/log/tailscale
