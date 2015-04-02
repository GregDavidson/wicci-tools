# Purpose: Provide key Wicci System paths for scripts to source
# Source one of wicci{,-simples}.{sh,bash} instead of this file!

for d in ~/.Wicci $HOME/Wicci $HOME/Projects/Wicci /Wicci; do
		[ -d "$d" -o -L "$d" ] && export WICCI_TOP="$d" && break
done

export WICCI_DOC="$WICCI_TOP/Doc"
export WICCI_TOOLS="$WICCI_TOP/Tools"
export WICCI_TOOLS_BIN="$WICCI_TOOLS/Bin"
export WICCI_TOOLS_LIB="$WICCI_TOOLS/Lib"
export WICCI_BIN="$WICCI_TOOLS_BIN"
export WICCI_DB_NAME=wicci1
export WICCI_OUT="$WICCI_TOP/Made/"$WICCI_DB_NAME""
export WICCI_CORE="$WICCI_TOP/Core"
export WICCI_LIB="$WICCI_CORE/Lib"
export WICCI_CSS="$WICCI_LIB/CSS"
export WICCI_JS="$WICCI_LIB/JS"
export WICCI_SVG="$WICCI_LIB/SVG"
export WICCI_XSL="$WICCI_LIB/XSL"
export WICCI_SQL_DIRS_NAME=WICCI_SQL_DIRS
export WICCI_SQL_DIRS="$WICCI_CORE/WICCI_SQL_DIRS"
export WICCI_SQL_FILES_NAME=WICCI_SQL_FILES
