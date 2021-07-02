###############################################################################################################
## 脚本说明
## 环境 gradle 5.4.1 java 1.8.0_181
## 使用了 tencent VasDolly 多渠道打包工具，jar 路径配置 tencentVasDolly
###############################################################################################################
## 输入参数说明
###############################################################################################################
# 打包参数说明，前面添加 * 号代表没有实现
# 示例 configuration=Debug isBuild branch=myrelease tag=7.0.8 channels=channel1,channel2 defaultChannels
# configuration		设置打包的环境 Debug/Release，默认 Release
# isBuild			不考虑缓存，强制重新打包
# branch			分支，默认 myrelease
# *tag				标签，当 branch 存在时，tag 会无效
# channels			导出的渠道，使用逗号（英文逗号）分隔
# fileChannels 		本地渠道配置文件路径 （文本格式/utf-8编码）
# urlChannels		网络渠道配置文件路径（文本格式/utf-8编码）
# defaultChannels	使用项目内部配置文件，默认 channel.txt，指定时需要 defaultChannels=xxx
# 渠道优先级 urlChannels > fileChannels > channels > defaultChannels
###############################################################################################################

### 全局常量设置
inputArguments=$*
# 对传入参数进行解析
getValue() {
	value=""
	for obj in $inputArguments
	do
		key=${obj%%=*}
		if [ -n $key ] && [ $key == $1 ]
		then
			value=${obj#*=}
	  		break
		fi
	done
	if [[ -n "${value}" ]]; then
	  echo "${value}"
	  return 0
  	fi
	echo $2
}
# 验证给定key值是否存在
# $1 需要验证的key值
# $2 是否仅存在key值
containsKey() {
	for obj in $inputArguments
	do
		if [[ $2 == true ]]; then
			key=$obj
		else
			key=${obj%%=*}
		fi
		if [[ $key == $1 ]]; then
			echo true
			return
		fi
	done
	echo false
}
# $1 路径下内容 cp 到 $2
mergeFolder() {
	if [[ ! -d $1 || ! -d $2 ]]; then
		return 0
	fi
	for path in $(ls $1)
	do
		from="$1/$path"
		to="$2/$path"
		if [[ -d "${from}" ]]; then
			if [[ ! -d "" ]]; then
				mkdir -p "${to}"
			fi
			mergeFolder "${from}" "${to}"
		else
			if [[ ! -e "${to}" ]]; then
				cp "${from}" "${to}"
			fi
		fi
	done
}

# 路径配置
rootPath="/YMProject"
projectTmp="${rootPath}/tmp"
projectPath="${rootPath}/YMMainProject-Android"
androidTools="${rootPath}/Android"
androidsdk="${androidTools}/sdk"

#配置打包时的临时环境变量
export JAVA_HOME="${androidTools}/jdk1.8.0_181"
export GRADLE_HOME="${androidTools}/gradle/gradle-5.4.1/bin/"
export JRE_HOME="${JAVA_HOME}/jre"
export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin:$GRADLE_HOME

# 安全删除，仅删除项目根目录(rootPath)下的内容
saferm() {
	absolutePath="$1"
	rootAbsolutePath="${rootPath}"
	# mac 下不支持 readlink -f 命令
	# absolutePath=$(readlink -f "$1")
	# rootAbsolutePath=$(readlink -f "${rootPath}")
	if [[ "${absolutePath}" == "/" ]]; then
		echo "确定删除根目录(${absolutePath})? 请检查配置选项是否错误"
		exit 1
	fi
	# 局限：当路径中包含"\ "代表空格时匹配会失败
	if [[ ! "${absolutePath}" =~ ^${rootAbsolutePath}.* ]]; then
		echo "${absolutePath} 路径下内容不支持自动删除，只能自动删除 ${rootPath} 下文件"
		return 0
	fi
	rm -fr "${absolutePath}"
}

#工具配置
# 腾讯 vasDolly 多渠道打包工具
tencentVasDolly="${androidTools}/jar/VasDolly.jar"

# 参数配置
# 远程仓库地址
remoteURL="git@172.16.10.180:gengwenkang/YMMainProject-Android.git"
configuration=$(getValue "configuration" "Release")
branch=$(getValue "branch" "ymrelease")
# 渠道导出路径文件夹
channelDir="${projectTmp}/apk"
tmp="${projectTmp}/shelltmp"
mainCacheDir="${projectTmp}/mainapk"
# 生成的 apk 包名
mainName="YueMei_QuicklyAsk"

# 全局变量
lastCommit="" # 最后一次提交的节点

# log 输出
echo "================= Android Auto Construct ================="
echo "=========================================================="
echo ">>>>> $(date) 开始构建 <<<<<"

initConfig() {
	saferm "${tmp}"
	mkdir -p "${tmp}"
}
# 更新项目
updateProject() {
	if [[ ! -d "${projectPath}" ]]; then
		result=$(mkdir -p ${projectPath})
		if [[ -n "${result}" ]]; then
			echo "创建 ${projectPath} 失败，错误信息: ${result}"
			exit 1
		fi
	fi
	cd "${projectPath}"
	isGit=$(git rev-parse --is-inside-work-tree)
	if [[ ! "${isGit}" == true ]]; then
		git init "${projectPath}"
	fi
	git config remote.origin.url "${remoteURL}"
	
	lastCommit=$(git ls-remote --heads --refs "${remoteURL}" "${branch}" | cut -f 1)
	localLastCommit=$(git log --pretty="%H" -n 1)
	if [[ -n "${lastCommit}" && "${lastCommit}" == "${localLastCommit}" ]]; then
		git checkout -f ${localLastCommit}
	else
		currentBranch=$(git branch)
		if [[ -n "${currentBranch}" ]]; then
			git fetch "${remoteURL}" "${branch}"
			git checkout -f FETCH_HEAD
		else
			git fetch "${remoteURL}" "${branch}":"${branch}"
			git checkout -f "${branch}"
		fi
		localLastCommit=$(git log --pretty="%H" -n 1)
	fi
#	git commit id 是通过 SHA-1 生成的，40 个十六进制字符
	if [[ ! "${lastCommit}" =~ ^[0-9a-fA-F]{40}$ || "${lastCommit}" != "${localLastCommit}" ]]; then
		echo "拉取指定分支失败, 请检查输入，指定分支名(${branch})"
		exit 1
	fi
}
# 编译 app
buildApp() {
	# 不知道啥情况，切换分支时出现了 YueMei_QuicklyAsk/yueMei_QuicklyAsk 两个文件夹，把仓库中yueMei_QuicklyAsk分成了两个内容
	# 这里手动合并一下
	# 在 mac 上测试发现没有 cd a, cd A 会进入一个目录下，所以分别判断目录是否存在就没有意义了
	num=$(find "${projectPath}" -maxdepth 1 -name "[yY]ueMei_QuicklyAsk"  | wc -l)
	if [[ $num -eq 2 ]]; then
		mainTarget="${projectPath}/yueMei_QuicklyAsk"
		tmpTarget="${projectPath}/YueMei_QuicklyAsk"
		mergeFolder "${tmpTarget}" "${mainTarget}"
		saferm "${tmpTarget}"
	fi
	### 开始打包
	# 项目中有可能没有本地配置文件，当判断不存在时创建所需要的配置文件
	localProperties="${projectPath}/local.properties"
	if [[ ! -f "${localProperties}" ]]; then
		echo sdk.dir="${androidsdk}" > "${localProperties}"
	fi
	gradle "assemble${configuration}"
}
getBuildApk() {
	configurationPath=$(echo "${configuration}" | tr '[A-Z]' '[a-z]')
	apkName="yueMei_QuicklyAsk-${configurationPath}.apk"
	mainTargetFolder=$(find "${projectPath}" -maxdepth 1 -name "[yY]ueMei_QuicklyAsk" | sed -n '1p')
	apkPath="${mainTargetFolder}/build/outputs/apk/${configurationPath}/${apkName}"
	echo "${apkPath}"
}
currentMainCacheApk() {
	_mainApkPath="${mainCacheDir}/${lastCommit}-${configuration}.apk"
	if [[ -z "$1" ]]; then
		echo "${_mainApkPath}"
		return 0
	elif [[ ! -f "$1" ]]; then
		echo "传入的路径不是文件$1，请检查"
		exit 1
	fi
	if [[ -f "${_mainApkPath}" ]]; then
		saferm "${_mainApkPath}"
	fi
	if [[ ! -d "${mainCacheDir}" ]]; then
		mkdir -p "${mainCacheDir}"
	fi
	
	result=$(cp "$1" "${_mainApkPath}")
	if [[ -n "${result}" ]]; then
		echo "移到 main apk 到缓存文件失败，错误信息:${result}"
		exit 1
	fi
	echo "${_mainApkPath}"
}
# 更新主包
handleMainApk() {
	_apk=$(currentMainCacheApk)
	if [[ $(containsKey "isBuild") == true || ! -f "${_apk}" ]]; then
	 	buildApp
		# 另写个方法获取编译 apk 文件是因为 buildApp 函数里面有其它输出
		currentMainCacheApk "$(getBuildApk)"
	fi
}
# 移动渠道包到指定路径 从 $1 移动到 $2 
moveChannels() {
	if [[ ! -d "$2" ]]; then
		mkdir -p "$2"
	fi
	for apk in $(ls "$1")
	do
		apkPath="$1/${apk}"
		if [[ -f "${apkPath}" ]]; then
			tmpName="${apk}" #${apk%-*}
			channelName=${tmpName%-*}
			if [[ "${channelName}" == "ziran" ]]; then
				apkFullName="${mainName}.apk"
			else
				apkFullName="${mainName}_${channelName}.apk"
			fi
			newApkPath="$2/${apkFullName}"
			if [[ -f "${newApkPath}" ]]; then
				saferm "${newApkPath}"
			fi
			mv "${apkPath}" "${newApkPath}"
		fi
	done
}
# 获取需要渠道配置信息
getChannelsConfig() {
	channels=$(getValue "urlChannels")
	if [[ -n "${channels}" ]]; then
		urlChannelsCacheDir="${tmp}/urlChannelsCaches"
		wget -P "${urlChannelsCacheDir}" "${channels}"
		echo "${urlChannelsCacheDir}/$(ls "${urlChannelsCacheDir}")"
		return 0
	fi
	channels=$(getValue "fileChannels")
	if [[ -f "${channels}" ]]; then
		echo "${channels}"
		return 0
	fi
	channels=$(getValue "channels")
	if [[ -n "$channels" ]]; then
		echo "${channels}"
		return 0
	fi
	channels=$(getValue "defaultChannels" "channel.txt")
	if [[ "${channels}" == true ]]; then
		channels=$(find "${projectPath}" -name "${channels}" | sed -n '1p')
		if [[ -f "${channels}" ]]; then
			echo "${channels}"
			return 0
		fi
	fi
	echo ""
}
# 处理渠道包，$1 生成好的主包路径
handleChannels() {
	if [[ ! -f "$1" ]]; then
		echo "指定路径下不是文件$1"
		exit 1
	fi
	channels=$(getChannelsConfig)
	if [[ ! -n "${channels}" ]]; then
		echo "没有指定渠道"
		return 0
	fi
	_tmpMainPath="${tmp}/tmpMain.apk"
	result=$(cp "$1" "${_tmpMainPath}")
	if [[ -n "${result}" ]]; then
		echo "生成临时文件失败，error: ${result}"
		exit 1
	fi
	channelsApkTmp="${tmp}/apk"
	java -jar ${tencentVasDolly} put -mtc "${channels}" "${_tmpMainPath}" "${channelsApkTmp}"
	moveChannels "${channelsApkTmp}" "${channelDir}"
}
# 初始化配置
initConfig
# 更新项目
updateProject
handleMainApk
handleChannels "$(currentMainCacheApk)" 
# # 清除不需要的缓存
saferm "${tmp}"
