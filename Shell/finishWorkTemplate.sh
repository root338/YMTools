
projectName="MyTest"
minHour=9
maxHour=23
# 在取值为 01-09 时，进行数字判断时会被认为八进制，导致判断出错，需要处理结果前缀的 0
currentHour=$(expr $(date "+%H") + 0)
if [[ ${currentHour} -lt ${minHour} ]] || [[ ${currentHour} -gt ${maxHour} ]]; then
  echo "不在规定时间内，不发送消息"
  exit 0
fi
statusInfo="$HOME/.jenkinsBuildStatus/${projectName}/default/statusInfo.json"
if [[ ! -f "${statusInfo}" ]]; then
  exit 0
fi
statusPath="statusPath:${statusInfo}"
toolPath=~/dev/YMTools/Python/YMDing/ding.py
python3 "${toolPath}" "${statusPath}"
rm "${statusInfo}"

valueAt() {
	# 命令行执行python，获取文件json对应key值
	# echo $(cat $1 | python3 -c "import json, sys;obj=json.load(sys.stdin);print(obj['$2'])")
	py="import json, sys; from pathlib import Path; obj = json.load(open('$1')); print(obj['$2'])"
	python3 -c "$py"
}
