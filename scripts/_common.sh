#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================
datadir=""
datadir_final=""
# dependencies used by the app
#TODO Do better than mono-devel
pkg_dependencies="libsqlite3-0 libmediainfo0v5 mono-runtime ca-certificates-mono libmono-system-net-http4.0-cil mono-devel"

#=================================================
# PERSONAL HELPERS
#=================================================
setup_permissions () {
    chown -R $app:$app "$final_path"
    chown -R $app:$app "/var/log/$app"
    chown -R $app:$app "$datadir_final"

    chmod u=rwX,g=rX,o= "$final_path"
    chmod u=rwX,g=rX,o= "/var/log/$app"
    chmod u=rwX,g=rX,o= "$datadir_final"
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
