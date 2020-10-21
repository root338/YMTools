
tmpPath="$(pwd)/tmp"
# cd 到项目主目录
projectName="MyTest"

logMsg=""
# 提交git
commitGit() {
  if [[ -n "${logMsg}" ]]; then
    echo "修改日志：${logMsg}"
  fi
  tagInfo=""
  if [[ ${method} == "app-store" ]] && [[ ${isBuild} == true ]]; then
    tagInfo=$(ruby ~/dev/YMTools/Ruby/PrintAppInfo.rb projectPath:$(pwd) bundleShortVersion)
  fi
  sh ymGitForJenkins.sh remoteBranch=${branch} "commitMsg=${logMsg}" "author=J-${BUILD_USER}<${BUILD_USER_EMAIL}>" "addTag=${tagInfo}"
}
# 拼接修改日志
appendMsg() {
  for obj in "$@"
  do
    if [[ -n "${obj}" ]]; then
      if [[ -n "${logMsg}" ]]; then
        logMsg="${logMsg},${obj}"
      else
        logMsg="${obj}"
      fi
    fi
  done
}

if [[ -n ${projectName} ]]; then
  cd ./${projectName}
fi

# 修改接口号,AppIcon,LaunchImage资源
imagePath="imagePath:${tmpPath}/ImagePath.zip"
version="APIVersion:${APIVersion}"
projectPath="projectPath:$(pwd)"
isMustAppIcon="isMustAppIcon:${isMustIcon}"
isMustLaunch="isMustLaunch:${isMustLaunch}"
toolPath=~/dev/YMTools/YMEditResources/editResources.py
log=$(python3 "$toolPath" "${projectPath}" "${version}" "${imagePath}" "${isMustAppIcon}" "${isMustLaunch}")
appendMsg "$log"

# 修改项目配置，比如：版本号，编译号
toolPath=~/dev/YMTools/Ruby/EditXcodeProject.rb
bundleVersion="bundleVersion:${bundleVersion}"
bundleShortVersion="bundleShortVersion:${bundleShortVersion}"
isAddOne="isAddOne:${bundleVersionAutoAddOne}"
changeAll="changeAll:true"
log=$(ruby $toolPath "${projectPath}" "${bundleVersion}" "${bundleShortVersion}" "${isAddOne}" "${changeAll}")
appendMsg "$log"

if [[ -d "${tmpPath}" ]]; then
  rm -fr "${tmpPath}"
fi

if [[ ${isBuild} == false ]]; then
  echo "不打包仅执行修改资源"
  commitGit
  exit 0
fi

fastlane haha export_method:${method} configuration:${configuration} clean:${clean} --verbose
commitGit
