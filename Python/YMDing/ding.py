
import json
from pathlib import Path
# 同目录下
import dingMessage
import sendDing

# 其它
import sys
import os
userHome = os.environ['HOME']
dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(f"{os.path.dirname(dir)}/Analyze")
sys.path.append(f"{userHome}/dev/YMConfig")
import commandARGVAnalyze
import dingRobot
import dingParams

params = commandARGVAnalyze.tiskMark(sys.argv[1:])
statusPath = params.get("statusPath")
if not statusPath or not Path(statusPath).exists():
    raise Exception("缺少状态文件(statusPath)，或路径不存在")
statusInfo = json.load(open(statusPath, mode="r"))
if not statusInfo.get("isBuild", False):
    print("没有执行编译，无法获取包的信息")
    exit(0)
# dingParams.handleDingInfo(params, statusInfo)
# robot = dingRobot.robot(params)
# sign = sendDing.sign(robot)
# msgBody = dingMessage.msgBody(params)
# print(msgBody)
# result = sendDing.request(sign = sign, jsonBody = msgBody)
# print(result)

msgList = dingParams.msgList(params, statusInfo)
for msg in msgList:
    robot = dingRobot.robot(msg)
    sign = sendDing.sign(robot)
    msgBody = dingMessage.msgBody(msg)
    result = sendDing.request(sign = sign, jsonBody = msgBody)
