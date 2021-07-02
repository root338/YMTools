
import re
import sys
import os
dir = os.path.dirname(os.path.abspath(__file__))
previousDir = os.path.dirname(dir)
pythonDir = f"{previousDir}/Python"
sys.path.append(pythonDir)
sys.path.append(f"{pythonDir}/Analyze")

import fileTool
import zip
import commandARGVAnalyze

params = commandARGVAnalyze.tiskMark(sys.argv[1:])
projectPath = params.get("projectPath")

configPath = params.get("APIVersionPath", fileTool.firstSearch(projectPath, pattern="ymconfig.gradle", isDepth=False))

def text(contentRE, valueRE, value, path=None):
    if not path:
        path = configPath
    contentList = fileTool.searchText(path, contentRE)
    if len(contentList) == 0:
        return False
    content = contentList[0]
    oldValue = re.findall(valueRE, content)[0]
    if oldValue != value:
        newContent = content.replace(oldValue, value)
        fileTool.replaceText(path, new=newContent, old=content)
    return True
def getContent(contentRE, valueRE, path=None):
    if not path:
        path = configPath
    contentList = fileTool.searchText(path, contentRE)
    if len(contentList) == 0:
        return None
    content = contentList[0]
    return re.findall(valueRE, content)[0]

numberRE = r'[0-9]+'
isAllNumberRE = r"^[0-9]+$"

# 修改接口号
def handleAPI():
    APIValue = params.get("APIVersion", "").strip()
    APIFullRE = r'[\s]*versonCode[\s]*=[\s]*\"[0-9]+\"[\s]*'
    if len(APIValue) > 0:
        if not re.match(isAllNumberRE, APIValue):
            raise Exception(f'接口号{APIVersion}必须全由数字组成')
        text(APIFullRE, numberRE, APIValue)
    print(getContent(APIFullRE, numberRE))

# 修改编译号
def handleVersion():
    versionCode = params.get("bundleVersion", "").strip()
    isAutoAddVersionCode = params.get("isAddOne", "").strip() == "true"
    versionFullRE = r'[\s]*versionCode[\s]*:[\s]*[0-9]+[\s]*,[\s]*'
    if len(versionCode) > 0 or isAutoAddVersionCode:
        if len(versionCode) == 0:
            versionCode = str(int(getContent(versionFullRE, numberRE)) + 1)
        if not re.match(isAllNumberRE, versionCode):
            raise Exception(f'编译号{versionCode}必须全由数字组成')
        text(versionFullRE, numberRE, versionCode)
    print(getContent(versionFullRE, numberRE))

def handleVersionNumber():
    bundleShortVersion = params.get("bundleShortVersion", "").strip()
    bundleShortVersionRE = r"[0-9]+\.[0-9]+\.[0-9]+"
    versionFullRE = r'[\s]*versionName[\s]*:[\s]*\"[0-9]+\.[0-9]+\.[0-9]+\"[\s]*'
    if len(bundleShortVersion) > 0:
        if not re.match(r"^[0-9]+\.[0-9]+\.[0-9]+$", bundleShortVersion):
            raise Exception(f'版本号{bundleShortVersion}必须是 0.0.0 这种结构')
        text(versionFullRE, bundleShortVersionRE, bundleShortVersion)
    print(getContent(versionFullRE, bundleShortVersionRE))

handleAPI()
handleVersion()
handleVersionNumber()