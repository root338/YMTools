## 脚本功能说明
## iOS 解析 crash 
## 前置条件:
## 1. 需要添加 symbolicatecrash 解析工具的环境变量设置
## 2. find 查找 xcarchive 归档文件是以 crash 文件中 app_name 字段内容为前缀进行搜索的
## 3. 搜索到归档文件以 归档路径/dSYM/app_name.app.dSYM 读取到符合文件
## 4. 默认以 arm64 进行解析
## 解析后的 log 文件自动导出到 $logdir 变量路径下，完成后自动打开该文件夹(如果存在解析结果的话)
###############################################################################################
## 参数说明:
## 输入的参数全部当成是 crash 路径来使用
##
## 其它注意事项:
## 由于项目中应该有很多归档文件，每个都需要先获取 arm64 下的 uuid 来匹配是否可以解析 crash 日志，所以总的来说脚本跑的会很慢
archivesdir="$HOME/Library/Developer/Xcode/Archives"

valueAt() {
	value=$(cat "$1" | grep -Eo "\"$2\"\s*:\s*\"[0-9a-zA-Z\-]+\"" | cut -d ':' -f 2)
	value=${value#\"*}
	value=${value%*\"}
	echo $value # ${value:1:0-1} # 不知道啥情况，在脚本中执行报错
}

logdir="$HOME/crash"
mkdir -p "$logdir"
exist="fasle"

for crash in $*
do
	if [[ ! -f "$crash" ]]; then
		# 不是文件，拼一下执行路径
		crash="$(pwd)/$crash"
	fi
	if [[ -f "$crash" ]]; then
		uuid=$(valueAt "$crash" "slice_uuid" | tr '[a-z]' '[A-Z]')
		name=$(valueAt "$crash" "app_name")
		# for in 中空格会做为一种分隔符，所以先搜索全部目标，再一行一行读取
		result=$(find "${archivesdir}" -iname "$name*.xcarchive")
		count=$(echo "$result" | wc -l)
		for ((i=3; i <= $count; i++))
		do
			archive=$(echo "$result" | sed -n "${i}p")
			dSYM="$archive/dSYMs/$name.app.dSYM"
			dSYM_uuid=$(dwarfdump --uuid "$dSYM" | grep -E "arm64" | cut -d ' ' -f 2 | tr '[a-z]' '[A-Z]')
			if [[ "$uuid" == "$dSYM_uuid" ]]; then
				logname=$(basename "$crash")
				log="${logdir}/${logname%%.*}.log"
				symbolicatecrash "$crash" "$dSYM" > "$log"
				echo "$crash ==> $dSYM"
				exist="true"
			fi
		done
	fi
done

if [[ $exist == true ]]; then
	open "$logdir"
fi
