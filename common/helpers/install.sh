# -*-* shell *-*-

# enable aliases
shopt -s expand_aliases

# clear all aliases
unalias -a

# disable wildcards helper
_noglob_helper() {
       set +f
       "$@"
}

# Apply _noglob to v* commands
for cmd in vinstall vcopy vmove vmkdir vbin vman vdoc vconf vsconf vlicense; do
       alias ${cmd}="set -f; _noglob_helper _${cmd}"
done

_vbin() {
	local file="$1" targetfile="$2"

	if [ $# -lt 1 ]; then
		msg_red "$pkgver: vbin: 1 argument expected: <file>\n"
		return 1
	fi

	vinstall "$file" 755 usr/bin "$targetfile"
}

_vman() {
	local file="$1" target="${2:-${1##*/}}"

	if [ $# -lt 1 ]; then
		msg_red "$pkgver: vman: 1 argument expected: <file>\n"
		return 1
	fi

	suffix=${target##*.}

	if  [[ $target =~ (.*)\.([a-z][a-z](_[A-Z][A-Z])?)\.(.*) ]]
	then
		name=${BASH_REMATCH[1]}.${BASH_REMATCH[4]}
		mandir=${BASH_REMATCH[2]}/man${suffix:0:1}
	else
		name=$target
		mandir=man${suffix:0:1}
	fi

	if [[ ${mandir} == *man[0-9n] ]] ; then
		vinstall "$file" 644 "usr/share/man/${mandir}" "$name"
		return 0
	fi

	msg_red "$pkgver: vman: Filename '${target}' does not look like a man page\n"
	return 1
}

_vdoc() {
	local file="$1" targetfile="$2"

	if [ $# -lt 1 ]; then
		msg_red "$pkgver: vdoc: 1 argument expected: <file>\n"
		return 1
	fi

	vinstall "$file" 644 "usr/share/doc/${pkgname}" "$targetfile"
}

_vconf() {
	local file="$1" targetfile="$2"

	if [ $# -lt 1 ]; then
		msg_red "$pkgver: vconf: 1 argument expected: <file>\n"
		return 1
	fi

	vinstall "$file" 644 "etc/${pkgname}" "$targetfile"
}

_vsconf() {
	local file="$1" targetfile="$2"

	if [ $# -lt 1 ]; then
		msg_red "$pkgver: vsconf: 1 argument expected: <file>\n"
		return 1
	fi

	vinstall "$file" 644 "usr/share/examples/${pkgname}" "$targetfile"
}

_vlicense() {
	local file="$1" targetfile="$2"

	if [ $# -lt 1 ]; then
		msg_red "$pkgver: vlicense: 1 argument expected: <file>\n"
		return 1
	fi

	vinstall "$file" 644 "usr/share/licenses/${pkgname}" "$targetfile"
}

_vinstall() {
	local file="$1" mode="$2" targetdir="$3" targetfile="$4"
	local _destdir=

	if [ -z "$DESTDIR" ]; then
		msg_red "$pkgver: vinstall: DESTDIR unset, can't continue...\n"
		return 1
	fi

	if [ $# -lt 3 ]; then
		msg_red "$pkgver: vinstall: 3 arguments expected: <file> <mode> <target-directory>\n"
		return 1
	fi

	if [ ! -r "$file" ]; then
		msg_red "$pkgver: vinstall: cannot find '$file'...\n"
		return 1
	fi

	if [ -n "$XBPS_PKGDESTDIR" ]; then
		_destdir="$PKGDESTDIR"
	else
		_destdir="$DESTDIR"
	fi

	if [ -z "$targetfile" ]; then
		install -Dm${mode} ${file} "${_destdir}/${targetdir}/$(basename ${file})"
	else
		install -Dm${mode} ${file} "${_destdir}/${targetdir}/$(basename ${targetfile})"
	fi
}

_vcopy() {
	local files="$1" targetdir="$2" _destdir

	if [ -z "$DESTDIR" ]; then
		msg_red "$pkgver: vcopy: DESTDIR unset, can't continue...\n"
		return 1
	fi
	if [ $# -ne 2 ]; then
		msg_red "$pkgver: vcopy: 2 arguments expected: <files> <target-directory>\n"
		return 1
	fi

	if [ -n "$XBPS_PKGDESTDIR" ]; then
		_destdir="$PKGDESTDIR"
	else
		_destdir="$DESTDIR"
	fi

	cp -a $files ${_destdir}/${targetdir}
}

_vmove() {
	local files="$1" _destdir _pkgdestdir _targetdir

	if [ -z "$DESTDIR" ]; then
		msg_red "$pkgver: vmove: DESTDIR unset, can't continue...\n"
		return 1
	elif [ -z "$PKGDESTDIR" ]; then
		msg_red "$pkgver: vmove: PKGDESTDIR unset, can't continue...\n"
		return 1
	fi
	if [ $# -ne 1 ]; then
		msg_red "$pkgver: vmove: 1 argument expected: <files>\n"
		return 1
	fi
	for f in ${files}; do
		_targetdir=$(dirname $f)
		break
	done

	if [ "$files" = "all" ]; then
		files="*"
	fi

	if [ -n "$XBPS_PKGDESTDIR" ]; then
		_pkgdestdir="$PKGDESTDIR"
		_destdir="$DESTDIR"
	else
		_pkgdestdir="$DESTDIR"
		_destdir="$DESTDIR"
	fi

	if [ -z "${_targetdir}" ]; then
		[ ! -d ${_pkgdestdir} ] && install -d ${_pkgdestdir}
		mv ${_destdir}/$files ${_pkgdestdir}
	else
		if [ ! -d ${_pkgdestdir}/${_targetdir} ]; then
			install -d ${_pkgdestdir}/${_targetdir}
		fi
		mv ${_destdir}/$files ${_pkgdestdir}/${_targetdir}
	fi
}

_vmkdir() {
	local dir="$1" mode="$2" _destdir

	if [ -z "$DESTDIR" ]; then
		msg_red "$pkgver: vmkdir: DESTDIR unset, can't continue...\n"
		return 1
	fi

	if [ -z "$dir" ]; then
		msg_red "vmkdir: directory argument unset.\n"
		return 1
	fi

	if [ -n "$XBPS_PKGDESTDIR" ]; then
		_destdir="$PKGDESTDIR"
	else
		_destdir="$DESTDIR"
	fi

	if [ -z "$mode" ]; then
		install -d ${_destdir}/${dir}
	else
		install -dm${mode} ${_destdir}/${dir}
	fi
}
