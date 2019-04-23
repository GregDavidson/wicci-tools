#!/usr/bin/env awk
#Purpose: Count TABLEs, VIEWs, FUNCTIONs, etc. [draft]'

$1 = "CREATE" {
if [ $# = 0 ]; then
	set -- `wicci-sql-files`
fi
echo Number of files: $#
echo Number of TABLES: $(grep 'CREATE TABLE' $files | wc -l)
echo Number of VIEWS: $(grep '^VIEW' $files | wc -l)
echo Number of FUNCTIONS: $(grep '^FUNCTION' $files | wc -l)

cat "$@" | tr -s ' 	' ' ' | sed -e 's/^ //' -e 's/ $//'
