#Purpose: normalize SQL files for analysis
s/^ //
s/ $//
s/ *--.*//
/^$/d
s/CREATE OR REPLACE/CREATE/
/^CREATE$/N;y/\
/ /


