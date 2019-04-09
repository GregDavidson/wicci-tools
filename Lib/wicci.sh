#!/bin/sh
# Purpose: settings & key functions for sh scripts to source
# such as by: eval `wicci-paths +`
# scripts and variables ending in _ should not be used directly!

# pgm_name_ is for scripts run as programs in a new shell
set_pgm_name() {
		for n in "$1" "$pgm_name_" "${0##*/}"; do
				[ -n "$n" ] && pgm_name_="$n" && return 0
		done
		return 1
}
set_pgm_name										# see: you don't really need to call it at all!

for d in $HOME $HOME/Shared /Shared; do # find it
		f="$d/Lib/Sh/Simples/simples.sh"
		[ -f "$f" ] && break
done
[ -f "$f" ] && simples_sh="$f"

# parent script calls "include_script" below
# include_stack_ is for scripts sourced (.) by existing shells
push_include__() {	include_stack_="$1 $2"; }
push_include_() { push_include__ "$1" $include_stack_; }
pop_include__() { shift; include_stack_="$*"; }
pop_include_() { pop_include__ $include_stack_; }
include_name_() { printf '%s' "$1"; }
include_name() { include_name_ $include_stack_; }

script_name() {
		for this in "`include_name`" "$pgm_name_" "${0##*/}"; do
				[ -n "$this" ] && printf '%s' "$this" && return 0
		done; return 1
}

msg() { >&2 printf '%s\n' "$*"; }
warn() { msg "`script_name` warning: $*"; }

[ -n "$try_code_" ] || try_code_=1			# unique code > 0 for each place of error
die() {	msg "$*"; exit "$try_code_"; }
err() {	die "`script_name` error:" "$*"; }

# e.g.: try <command>			-- when <command> might fail
# e.g.: try; <command> || cleanup-code || err ...
try() {
		try_code_=`expr $try_code_ + 1`	# increment failure exit code
		[ $# -gt 0 ] && ! "$@" &&	err "$* failed!"
}
# e.g.: if failed <command>; then cleanup-code; err "$failed_ failed"; fi
failed() { try; failed_="$*"; if "$@"; then return 1; else return 0; fi; }

include_script() { set -x
		include_script__="$1"
		try; [ $# = 1 ] || err "include_script $# arguments"
		try; [ -r "$include_script__" ] || err "include_script $include_script__ unreadable"
		set -- `head -1 "$1"`
		case "$1" in
				"#!/bin"/sh|"#!/bin"/[kz]sh|"#!/bin"/bash) ;;
				*) err "include_script $include_script__[1]=$1 but SHELL=$SHELL" ;;
		esac
		push_include_ "$include_script__"
		. "$include_script__"
		include_script__code=$?
		pop_include_
		return "$include_script__code"
}
