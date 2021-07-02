# 安装 build.sh 中所需的环境

rootPath="/Users/apple/Android"
packageTmp="${rootPath}/tmp"

mkdir -p "${rootPath}"
mkdir -p "${packageTmp}"

systemType=$(uname)
ismac() {
	if [[ $("${systemType}" == "Darwin") ]]; then
		echo true
	else
		echo false
	fi
}
islinux() {
	# if [[ "${systemType}" == "Linux" ]]; then
	if [[ "${systemType}" != "Darwin" ]]; then
		echo true
	else
		echo false
	fi
}

## 处理 sdk 
androidsdk="${rootPath}/sdk"

sdkmanager=""
installCommandlinetools() {
	mkdir -p "${androidsdk}"
	mname="sdkmanager"
	sdkmanager=$(find "${androidsdk}" -name "${mname}")
	if [[ -n "${sdkmanager}" ]]; then
		return 0
	fi
	# 安装 sdkmanager
	if [[ $(ismac) == true ]]; then
		androidsdkname="commandlinetools-mac-7302050_latest.zip"
	else
		androidsdkname="commandlinetools-linux-7302050_latest.zip"
	fi
	wget "https://dl.google.com/android/repository/${androidsdkname}" -P "${packageTmp}"
	toolPath="${packageTmp}/${androidsdkname}"
	unzip "${toolPath}" -d "${androidsdk}"
	cd ${androidsdk}
	toolDir="$(ls | sed -n '1p')"
	sdkm="${toolDir}/latest"
	mkdir -p 
	mv "${toolDir}/*" "${sdkm}"
	sdkmanager=$(find "${androidsdk}" -name "${mname}")
}

installAndroidsdk() {
	
	# for argv in $*
	# do
	# 	type=${argv%%:*}
	# 	if [[ "${type}" == "android" ]]; then
	# 		value=${argv#*:}
	# 		echo $value
	# 	fi
	# done
	yes | "${sdkmanager}" "--sdk_root=${androidsdk}" --install "platforms;android-28"
}

## 处理打包工具 gradle
gradle="${rootPath}/gradle"
installGradle() {
	
	gradledir="${gradle}/gradle-$1"
	if [[ -d "${gradledir}" ]]; then
		return 0
	fi
	gradleZipName="gradle-$1-all.zip"
	wget "https://downloads.gradle-dn.com/distributions/${gradleZipName}" -P "${packageTmp}"
	zipPackage="${packageTmp}/${gradleZipName}"
	unzip "${zipPackage}" -d "${gradle}"
}
#wget https://github.com/frekele/oracle-java/releases/download/8u181-b13/jdk-8u181-linux-x64.tar.gz

# 安装 android sdk
installCommandlinetools
installAndroidsdk #android:28

installGradle "5.4.1"