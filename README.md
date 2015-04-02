# Directory: Wicci/Tools

## Subdirectories:
	Bin/	- Utilitiy Programs (mostly scripts) for the Wicci System
	Lib/		- files needed by some Utility Programs
	Src/	- source files for any compiled  Utility Programs

## All scripts should be self documenting as follows:
	shell scripts should have a line with pgm_purpose='...'
	other scripts should have a line with #[[:space:]]*[Pp]urpose: ...
near the top of the file.

## wicci-paths

To add key Wicci paths, etc. to your script, put one of these at the top:
				eval `wicci-paths`		-- just adds key paths & filenames
				eval `wicci-paths +`	-- also sources lib/wicci.sh
				eval `wicci-paths simples`	-- also sources simples package
Note: wicci-paths checks your shell and does "the right thing".

## Documentation

	 $ wicci-tools wicci-tools	# wicci-tools describes itself
	 $ wicci-tools		#  wicci-tools describes ALL wicci-tools

## Notes on future improvements

### wicci-tools

Instead of having wicci-tools grep scripts for embedded
static strings, it would be good to have all scripts check
for help-related command-line options.  Wicci-tools could
then simply loop over the selected scripts supplying the
desired option.  This would be a win because the description
strings should sometimes be generated dynamically.
