

# oldifs="$IFS"
IFS=$'\n'
for line in $(find /Users/apple/.jenkinsBuildStatus -name "statusInfo.json" -type f)
do
  echo "${line}"
done
# IFS="${oldifs}"
