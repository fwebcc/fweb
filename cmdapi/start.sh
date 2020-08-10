#!/bin/sh
### BEGIN INIT INFO
# Provides:          test
# Required-Start: $local_fs $remote_fs
# Required-Stop: $local_fs $remote_fs
# Should-Start: $network
# Should-Stop: $network
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description: test
# Description: test
### END INIT INFO
/home/sweb/config/s_start.sh
/home/sweb/sweb.sh start