# 安装 build.sh 中所需的环境

toolsdir="/Users/apple/Android"
packageTmp="${toolsdir}/tmp"

mkdir -p "${toolsdir}"
mkdir -p "${packageTmp}"

source verify.sh

add_export() {
	sumpath=""
	for _path in $*
	do
		if [[ -n $sumpath ]]; then
			sumpath=$sumpath:$_path
		else
			sumpath=$_path
		fi
	done
	export PATH=$PATH:$sumpath
}
## 处理 sdk 
androidsdk="${toolsdir}/sdk"
cmdtools="cmdline-tools"
getCommandlinetools() {
	cmdtoolsdir="${androidsdk}/${cmdtools}"
	mname="sdkmanager"
	if [[ -d "${cmdtoolsdir}" ]]; then
		sdkM=$(find "${cmdtoolsdir}" -name "${mname}")
		echo $sdkM
		if [[ -f "${sdkM}" ]]; then
			dir=$(dirname "${sdkM}")
			cd "$dir"
			echo "$(pwd)"
			return 0
		fi
	fi
	echo ""
}
installCommandlinetools() {
	mkdir -p "${androidsdk}"
	# 安装 sdkmanager
	if [[ $(ismac) == true ]]; then
		androidsdkname="commandlinetools-mac-7302050_latest.zip"
	else
		androidsdkname="commandlinetools-linux-7302050_latest.zip"
	fi
	toolPath="${packageTmp}/${androidsdkname}"
	if [[ ! -f "${toolPath}" ]]; then
		wget "https://dl.google.com/android/repository/${androidsdkname}" -P "${packageTmp}"
	fi
	unzip "${toolPath}" -d "${androidsdk}"
	# cd ${androidsdk}
	# toolDir="$(ls | sed -n '1p')"
	# mv "${toolDir}" "tools"
}
# 配置 android sdk 
# android:28,29 sdk版本
# type:install,uninstall,update 操作类型，默认 install
configAndroidsdk() {
	sdkconfig="$packageTmp/config.androidsdk"
	if [[ -f "$sdkconfig" ]]; then
		rm -f "$sdkconfig"
	fi
	configType="--install"
	for argv in $*
	do
		type=${argv%%:*}
		value=${argv#*:}
		if [[ "${type}" == "android" ]]; then
			oldifs="$IFS"
			IFS=","
			sdks=($value)
			IFS="$oldifs"
			for sdk in ${sdks[*]}
			do
				echo "platforms;android-$sdk" >> "$sdkconfig"
			done
		elif [[ "${type}" == "type" ]]; then
			configType="--$value"
		fi
	done
	if [[ -f "$sdkconfig" && $(cat "$sdkconfig" | wc -l) -ge 1 ]]; then
		yes | sdkmanager "--sdk_root=${androidsdk}" "$configType" "--package_file=$sdkconfig"
	fi
}

## 处理打包工具 gradle
gradle="${toolsdir}/gradle"
configGradle() {
	gradledir="${gradle}/gradle-$1"
	if [[ ! -d "${gradledir}" ]]; then
		gradleZipName="gradle-$1-all.zip"
		zipPackage="${packageTmp}/${gradleZipName}"
		if [[ ! -f "${zipPackage}" ]]; then
			wget "https://downloads.gradle-dn.com/distributions/${gradleZipName}" -P "${packageTmp}"
		fi
		unzip "${zipPackage}" -d "${gradle}"
	fi
	add_export "${gradledir}/bin"
}

git="${toolsdir}/git"
configGit() {
	if [[ ! -d "$git" ]]; then
		gitPackage="git-$1.tar.gz"
		localPackagePath="${packageTmp}/${gitPackage}"
		if [[ ! -f "${localPackageDir}" ]]; then
			wget "https://mirrors.edge.kernel.org/pub/software/scm/git/${gitPackage}" -O "${localPackagePath}"
		fi
		tar -xzvf "${localPackagePath}"
	fi
}

# https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.32.0.tar.gz
#wget https://github.com/frekele/oracle-java/releases/download/8u181-b13/jdk-8u181-linux-x64.tar.gz



# 安装 android sdk
# if [[ -z $(getCommandlinetools) ]]; then
# 	installCommandlinetools
# fi
# add_export $(getCommandlinetools)
# configAndroidsdk "android:28"
#
# configGradle "5.4.1"
configGit "2.32.0"