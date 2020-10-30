
import re
from PIL import Image
import sys
import os
dir = os.path.dirname(os.path.abspath(__file__))
previousDir = os.path.dirname(dir)
pythonDir = f"{previousDir}/Python"
sys.path.append(pythonDir)
sys.path.append(f"{pythonDir}/Analyze")
sys.path.append(f"{pythonDir}/Xcode")
import fileTool
import zip
import xcodeImage
import commandARGVAnalyze

params = commandARGVAnalyze.tiskMark(sys.argv[1:])
projectPath = params.get("projectPath")
log = []

versionValue = params.get("APIVersion", "").strip()
if len(versionValue) > 0:
    if not re.match(r"^[0-9]+$", versionValue):
        raise Exception(f'接口号{versionValue}必须全由数字组成')
    path = params.get("APIVersionPath", fileTool.firstSearch(projectPath, pattern="APIConstant.h"))
    versionRE = r'V[0-9]+'
    oldValues = fileTool.searchText(path, versionRE)
    new = f'V{versionValue}'
    if len(oldValues) == 0:
        raise Exception('没有符合的接口号值')
    oldValue = oldValues[0]
    if oldValue != new:
        fileTool.replaceText(path, new=new, pattern=versionRE)
        log.append(f"接口号{oldValue}=>{new}")

if "imagePath" in params and fileTool.exists(params["imagePath"]):
    imagePath = params["imagePath"]
    if not zip.verify(imagePath):
        zip.removeAll(imagePath)
        raise Exception(f"{imagePath} 不是一个有效的zip压缩文件")
    imagePath = zip.unzip(imagePath, True)
    isMust = "true"
    # 处理 AppIcon
    isMustAppIcon = params.get("isMustAppIcon", isMust) == isMust
    appIconPath = params.get("appIconPath", fileTool.firstSearch(projectPath, pattern="AppIcon.appiconset"))
    if appIconPath:
        result = xcodeImage.replace(appIconPath, imagePath, isMustAppIcon)
        if result:
            log.append("修改AppIcon")
    elif isMustAppIcon:
        raise Exception("必须包含 appIconPath 路径，或传入的 projectPath 路径中包含 AppIcon.appiconset")
    # 处理 LaunchImage
    isMustLaunch = params.get("isMustLaunch", isMust) == isMust
    launchPath = params.get("launchPath", fileTool.firstSearch(projectPath, pattern="LaunchImage.launchimage"))
    if launchPath:
        result = xcodeImage.replace(launchPath, imagePath, isMustLaunch)
        if result:
            log.append("修改LaunchImage")
    elif isMustLaunch:
        raise Exception("必须包含 launchPath 路径，或传入的 projectPath 路径中包含 LaunchImage.launchimage")
    # 处理 YMLaunchADBackgroundImage.bundle
    launchBackgroundPath = params.get("launchAdPath", fileTool.firstSearch(projectPath, pattern="YMLaunchADBackgroundImage.bundle"))
    if isMustLaunch and launchBackgroundPath:
        xcodeImage.replace(launchBackgroundPath, imagePath, True)

if len(log) > 0:
    print(",".join(log))
else:
    print("")
