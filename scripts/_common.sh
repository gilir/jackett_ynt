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

ynh_setup_source_multiarch () {
    # Declare an array to define the options of this helper.
    local legacy_args=ds
    declare -Ar args_array=( [d]=dest_dir= [s]=source_id= )
    local dest_dir
    local source_id
    # Manage arguments with getopts
    ynh_handle_getopts_args "$@"
    source_id="${source_id:-app}" # If the argument is not given, source_id equals "app"

    local src_file_path="$YNH_CWD/../conf/${source_id}.src"
    # In case of restore script the src file is in an other path.
    # So try to use the restore path if the general path point to no file.
    if [ ! -e "$src_file_path" ]; then
        src_file_path="$YNH_CWD/../settings/conf/${source_id}.src"
    fi

    # Load value from configuration file (see above for a small doc about this file
    # format)
    local src_url=$(grep 'SOURCE_URL=' "$src_file_path" | cut -d= -f2-)
    local src_sum=$(grep 'SOURCE_SUM=' "$src_file_path" | cut -d= -f2-)
    local src_sumprg=$(grep 'SOURCE_SUM_PRG=' "$src_file_path" | cut -d= -f2-)
    local src_format=$(grep 'SOURCE_FORMAT=' "$src_file_path" | cut -d= -f2-)
    local src_extract=$(grep 'SOURCE_EXTRACT=' "$src_file_path" | cut -d= -f2-)
    local src_in_subdir=$(grep 'SOURCE_IN_SUBDIR=' "$src_file_path" | cut -d= -f2-)
    local src_filename=$(grep 'SOURCE_FILENAME=' "$src_file_path" | cut -d= -f2-)

    # Multiarch support
    local arch
    apkArch="$(uname -m)"
	case "$apkArch" in
        armv7l)
            arch='ARM'
            ;;
        armhf)
            arch='ARM'
            ;;
		aarch64)
            arch='ARM64'
            ;;
		x86_64)
            arch='AMD64'
            ;;
		*)
	esac

    if [ -z "$src_url" ]; then
        local src_url=$(grep "SOURCE_URL_$arch=" "$src_file_path" | cut -d= -f2-)
    fi
    if [ -z "$src_sum" ]; then
        local src_sum=$(grep "SOURCE_SUM_$arch=" "$src_file_path" | cut -d= -f2-)
    fi
    if [ -z "$src_sumprg" ]; then
        local src_sumprg=$(grep "SOURCE_SUM_PRG_$arch=" "$src_file_path" | cut -d= -f2-)
    fi
    if [ -z "$src_format" ]; then
        local src_format=$(grep "SOURCE_FORMAT_$arch=" "$src_file_path" | cut -d= -f2-)
    fi
    if [ -z "$src_extract" ]; then
        local src_extract=$(grep "SOURCE_EXTRACT_$arch=" "$src_file_path" | cut -d= -f2-)
    fi
    if [ -z "$src_in_subdir" ]; then
        local src_in_subdir=$(grep "SOURCE_IN_SUBDIR_$arch=" "$src_file_path" | cut -d= -f2-)
    fi
    if [ -z "$src_filename" ]; then
        local src_filename=$(grep "SOURCE_FILENAME_$arch=" "$src_file_path" | cut -d= -f2-)
    fi

    # Default value
    src_sumprg=${src_sumprg:-sha256sum}
    src_in_subdir=${src_in_subdir:-true}
    src_format=${src_format:-tar.gz}
    src_format=$(echo "$src_format" | tr '[:upper:]' '[:lower:]')
    src_extract=${src_extract:-true}
    if [ "$src_filename" = "" ] ; then
        src_filename="${source_id}.${src_format}"
    fi
    local local_src="/opt/yunohost-apps-src/${YNH_APP_ID}/${src_filename}"

    if test -e "$local_src"
    then    # Use the local source file if it is present
        cp $local_src $src_filename
    else    # If not, download the source
        local out=`wget -nv -O $src_filename $src_url 2>&1` || ynh_print_err --message="$out"
    fi

    # Check the control sum
    echo "${src_sum} ${src_filename}" | ${src_sumprg} -c --status \
        || ynh_die --message="Corrupt source"

    # Extract source into the app dir
    mkdir -p "$dest_dir"

    if ! "$src_extract"
    then
        mv $src_filename $dest_dir
    elif [ "$src_format" = "zip" ]
    then
        # Zip format
        # Using of a temp directory, because unzip doesn't manage --strip-components
        if $src_in_subdir ; then
            local tmp_dir=$(mktemp -d)
            unzip -quo $src_filename -d "$tmp_dir"
            cp -a $tmp_dir/*/. "$dest_dir"
            ynh_secure_remove --file="$tmp_dir"
        else
            unzip -quo $src_filename -d "$dest_dir"
        fi
    else
        local strip=""
        if [ "$src_in_subdir" != "false" ]
        then
            if [ "$src_in_subdir" == "true" ]; then
                local sub_dirs=1
            else
                local sub_dirs="$src_in_subdir"
            fi
            strip="--strip-components $sub_dirs"
        fi
        if [[ "$src_format" =~ ^tar.gz|tar.bz2|tar.xz$ ]] ; then
            tar -xf $src_filename -C "$dest_dir" $strip
        else
            ynh_die --message="Archive format unrecognized."
        fi
    fi

    # Apply patches
    if (( $(find $YNH_CWD/../sources/patches/ -type f -name "${source_id}-*.patch" 2> /dev/null | wc -l) > "0" )); then
        local old_dir=$(pwd)
        (cd "$dest_dir" \
            && for p in $YNH_CWD/../sources/patches/${source_id}-*.patch; do \
                patch -p1 < $p; done) \
            || ynh_die --message="Unable to apply patches"
        cd $old_dir
    fi

    # Add supplementary files
    if test -e "$YNH_CWD/../sources/extra_files/${source_id}"; then
        cp -a $YNH_CWD/../sources/extra_files/$source_id/. "$dest_dir"
    fi
}

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
