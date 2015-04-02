#!/bin/awk
# CREATE TABLE (\w+) [(][[:space:]]*(ref|tor) (\w+) PRIMARY KEY
# CREATE TABLE (\w+) [(][[:space:]]*PRIMARY KEY[(](ref|tor)[)]
BEGIN{
	RS=""
	FS="\n"
	IGNORECASE=1
	part1=".*\\<CREATE[[:space:]]+TABLE[[:space:]]+(\\w+)[[:space:]]*[(][[:space:]]*"
	part2a="\\<(ref|tor)\\>[[:space:]]+(\\w+)[[:space:]]+PRIMARY[[:space:]]+KEY\\>.*"
	part2b="\\<PRIMARY[[:space:]]+KEY[(]\\<(ref|tor)\\>[)]"
	pat1=part1 part2a ".*"
	pat2=part1 part2b ".*"
}
$0 ~ pat1 {
	print gensub(pat1, "\\1 \\2 \\3", "1")
} $0 ~ pat2 {
	print gensub(pat2, "\\1 \\2", "1")
}
