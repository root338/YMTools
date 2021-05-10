
tmpPath="$(pwd)/tmp"
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
# 数据纠错，在一些配置中某些参数不能更改
dataCorrection() {
  if [[ ${isBuild} == false ]]; then
    return 0
  fi
  if [[ ${method} != "app-store" ]] && [[ ! ${isAllPlatform} ]]; then
    return 0
  fi
  configuration="Release"
}

# 保存构建状态
saveStatus() {
  _appInfo=$(ruby ~/dev/YMTools/Ruby/PrintAppInfo.rb "projectPath:${WORKSPACE}" bundleShortVersion bundleVersion displayName bundleIdentifier)
  _displayName=$(echo "${_appInfo}" | sed -n '3p')
  _bundleShortVersion=$(echo "${_appInfo}" | sed -n '1p')
  _bundleVersion=$(echo "${_appInfo}" | sed -n '2p')
  _bundleIdentifier=$(echo "${_appInfo}" | sed -n '4p')
  _printFile=~/dev/YMTools/Python/printFile.py
  _APIVersion=$(find "${WORKSPACE}" -name "APIConstant.h" -type f | xargs cat | grep -oE "V[0-9]+" | head -n 1)
  value="""
  {
    \"JOB_NAME\" : \"${JOB_NAME}\",
    \"BUILD_NUMBER\" : \"${BUILD_NUMBER}\",
    \"WORKSPACE\" : \"${WORKSPACE}\",
    \"BUILD_URL\" : \"${BUILD_URL}\",
    \"JOB_URL\" : \"${JOB_URL}\",
    \"LOG_URL\" : \"${BUILD_URL}consoleFull\",

    \"RESULT\" : $1,
    \"isBuild\" : $isBuild,
    \"export_method\" : \"${method}\",
    \"configuration\" : \"${configuration}\",
    \"P.S.\" : \"${postscript}\",
    \"isAllPlatform\" : \"${isAllPlatform}\",

    \"APIVersion\" : \"${_APIVersion}\",
    \"bundleIdentifier\" : \"${_bundleIdentifier}\",
    \"bundleVersion\" : \"${_bundleVersion}\",
    \"bundleShortVersion\" : \"${_bundleShortVersion}\",
    \"displayName\" : \"${_displayName}\"
  }
  """
  exportFolder="$HOME/.jenkinsBuildStatus/${JOB_NAME}"
  if [[ ! -d "${exportFolder}" ]]; then
    mkdir -p "${exportFolder}"
  fi
  exportPath="${exportFolder}/statusInfo.json"
  if [[ ! -f "${exportPath}" ]]; then
    touch "${exportPath}"
  fi
  echo $value > "${exportPath}"
}

dataCorrection

saveStatus 0
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
displayName="displayName:${displayName}"
changeAll="changeAll:true"
log=$(ruby $toolPath "${projectPath}" "${bundleVersion}" "${bundleShortVersion}" "${isAddOne}" "${displayName}" "${changeAll}")
appendMsg "$log"

if [[ -d "${tmpPath}" ]]; then
  rm -fr "${tmpPath}"
fi

if [[ ${isBuild} == false ]]; then
  echo "不打包仅执行修改资源"
  commitGit
  saveStatus 1
  exit 0
fi
fastlaneFolder=$(find ./ -name "fastlane" -type d)
if [[ -n "${fastlaneFolder}" ]]; then
  cd "${fastlaneFolder}"
  cd ..
fi
fastlane haha export_method:${method} configuration:${configuration} clean:${clean} --verbose
commitGit
saveStatus 1
