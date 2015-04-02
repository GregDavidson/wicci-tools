#!/bin/bash
# Purpose: settings & key functions for bash scripts to source
# such as by: eval `wicci-paths +`
# scripts and variables ending in _ should not be used directly!

# pgm_name is for scripts run as programs in a new shell
set_pgm_name() {
		for n in "$1" "$pgm_name" "${0##*/}"; do
				[ -n "$n" ] && pgm_name="$n" && return 0
		done
		return 1
}
set_pgm_name										# see: you don't really need to call it at all!

# parent script calls "include_script" below
# include_stack_ is for scripts sourced (.) by existing shells
push_include__() {	include_stack_="$1 $2"; }
push_include_() { push_include__ "$1" $include_stack_; }
pop_include__() { shift; include_stack_="$*"; }
pop_include_() { pop_include__ $include_stack_; }
include_name_() { printf '%s' "$1"; }
include_name() { include_name_ $include_stack_; }

script_name() {
		for this in "`include_name`" "$pgm_name" "${0##*/}"; do
				[ -n "$this" ] && printf '%s' "$this" && return 0
		done; return 1
}

msg() { >&2 printf '%s\n' "$*"; }
warn() { msg "`script_name` warning: $*"; }
[ -n "$next_code_" ] || next_code_=1			# unique code > 0 for each place of error
die_() {	code="$1"; shift; msg "$*"; exit "$code"; }
die0() {	die_ 0 "$*"; }
die() {	die_ "$next_code_" "$*"; }
err_() { code="$1"; shift; die_ "$code" "`script_name`[$code] error:" "$*"; }
ferr_() { code="$1"; shift; die_ "$code" "`script_name`[$code] ${FUNCNAME}() error:" "$*"; }
alias err='err_ $LINENO'
alias ferr='ferr_ $LINENO'

# e.g.: next <command> || cleanup-code || err ...
next_() {
		next_code_=`expr $next_code_ + 1`	# increment failure exit code
		unset next_lineno_
		[[ $# == 0 ]] && return 0
		[[ $# == 1 && "$1" =~ ^0-9*$  ]] && return 0
		[[ "$1" =~ ^0-9*$  ]] && line=$1 && next_lineno_=$1 && try_lineno_=$1 && shift
		try_line_="$*"
		"$@"
}
alias next='next_ $LINENO'
# e.g.: try <command>			-- when <command> might fail
try_() { next "$@" || die "`script_name` $next_line $try_line_: $* failed!"; }
alias try='try_ $LINENO'
# e.g.: if failed <command>; then cleanup-code; err "$failed_ failed"; fi
failed_() { try; failed__="$*"; if "$@"; then return 1; else return 0; fi; }
alias failed='failed_ $LINENO'

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
