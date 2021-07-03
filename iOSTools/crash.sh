
archivesdir="$HOME/Library/Developer/Xcode/Archives"

valueAt() {
	value=$(cat "$1" | grep -Eo "\"$2\"\s*:\s*\"[0-9a-fA-F\-]+\"" | cut -d ':' -f 2)
	echo ${value:1:0-1}
}

logdir="$HOME/crash"

for crash in $*
do
	if [[ -f "$crash" ]]; then
		uuid=$(valueAt "$crash" "slice_uuid" | tr '[a-z]' '[A-Z]')
		name=$(valueAt "$crash" "app_name")
		# for archive in $(find "${archivesdir}" -iname "*.xcarchive")
		for dSYM in $(find "${archivesdir}" -iname "*.app.dSYM")
		do
			dSYM_uuid=$(dwarfdump --uuid "$dSYM" | grep -E "arm64" | cut -d ' ' -f 2 | tr '[a-z]' '[A-Z]')
			if [[ "$uuid" == "$dSYM_uuid" ]]; then
				logname=$(basename "$crash")
				log="$(logdir)${logname%%.*}.log"
				symbolscache "$crash" "$dSYM" > "$log"
				echo "$crash ==> $dSYM"
			fi
		done
	fi	
done

