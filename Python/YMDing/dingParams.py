
import sys
import os
userHome = os.environ['HOME']
sys.path.append(f"{userHome}/dev/YMConfig")
import YMAppConfig
import dingRobot

def handleDingInfo(params, statusInfo):
    handleGroupName(params, statusInfo)
    hanleMsgBody(params, statusInfo)

def handleGroupName(params, statusInfo):
    result = statusInfo.get("RESULT", False)
    method = statusInfo.get("export_method", "ad-hoc")
    groupName = dingRobot.groupName(statusInfo.get("bundleIdentifier"), result, method)
    if not dingRobot:
        raise Exception("没有指定的群发送消息")
    params["groupName"] = groupName

def hanleMsgBody(params, statusInfo):
    result = statusInfo.get("RESULT", False)
    displayName = statusInfo.get("displayName", "Unknown")
    def appInfo():
        return f"> ###### 接口号: {statusInfo['APIVersion']}\n> ###### 版本信息: {statusInfo['bundleShortVersion']}({statusInfo['bundleVersion']})\n> ###### 环境: {statusInfo['configuration']}\n"
    if result:
        method = statusInfo.get("export_method", "ad-hoc")
        if method == "app-store":
            title = f"【{displayName}】已上传 App Store"
            params["type"] = "markdown"
            params["title"] = title
            params["text"] = f"#### {title}\n{appInfo()}> ###### [App Store Connect](https://appstoreconnect.apple.com/)"
            params["isAtAll"] = "true"
        else:
            title = f"【{displayName}】已上传 蒲公英"
            params["type"] = "markdown"
            params["title"] = title
            try:
                info = pgyerInfo(statusInfo["bundleIdentifier"])
                password = info["password"]
                url = info["url"]
                params["text"] = f"#### {title}\n> ###### 蒲公英密码: {password}\n{appInfo()}> ###### [下载地址]({url})"
            except Exception as e:
                raise
                params["text"] = f"#### {title}\n{appInfo()}> ###### 请与开发者联系以获取新包如何安装"
            params["isAtAll"] = "true"
            # params["type"] = "actionCard"
            # params["title"] = f"{params['displayName']}"
            # params["text"] = f"""### {params['displayName']}已上传到蒲公英
            # ##### 密码：aaa111"""
            # params["singleTitle"] = "下载"
            # params["singleURL"] = "https://www.pgyer.com/Omkn"
    else:
        title = f"【{displayName}】构建失败"
        params["type"] = "markdown"
        params["title"] = title
        params["text"] = f"#### {title}\n{appInfo()}> ###### 构建号：{statusInfo['BUILD_NUMBER']}\n> ###### [构建日志]({statusInfo['LOG_URL']})"
        params["isAtAll"] = "true"
        # params["type"] = "link"
        # params["title"] = f"{params['displayName']}打包失败"
        # params["text"] = f"构建 {statusInfo['BUILD_NUMBER']} 时失败，请相关开发者解决问题"
        # params["messageUrl"] = f"{statusInfo['BUILD_URL']}consoleFull"

def pgyerInfo(bundleIdentifier):
    if not bundleIdentifier:
        raise Exception("必须存在 bundleIdentifier")
    appInfo = YMAppConfig.appInfoAt(bundleIdentifier)
    if not appInfo or "pgyer" not in appInfo:
        raise Exception("不存在蒲公英下载信息")
    return appInfo["pgyer"]
