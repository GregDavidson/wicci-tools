# Wicci Project; auxiliary program makefile; requires GNU Make.
# Copyright (c) 2005, 2006, J. Greg Davidson.
# You may use this file under the terms of the
# GNU AFFERO GENERAL PUBLIC LICENSE 3.0
# as specified in the file LICENSE.md included with this distribution.
# All other use requires my permission in writing.
show-pg-sizes: w-pg-sizes
	$(CC) $(CFLAGS) -E $<.c | sed -n '/^int main(.*) *{$$/,$$p'
	./$<
w-pg-sizes: w-pg-sizes.c
	$(CC) $(CFLAGS) $< -o $@
w-pg-ctl: w-pg-ctl.c
	$(CC) -o w-pg-ctl w-pg-ctl.c
	su -c "chown root.postgres vis-pg-ctl; chmod +s vis-pg-ctl" || rm vis-pg-ctl
install: w-pg-sizes
	mv w-pg-sizes ../bin
