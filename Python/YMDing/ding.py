# 同目录下
import dingMessage
import sendDing

# 其它
import sys
import os
userHome = os.environ['HOME']
sys.path.append("../Analyze")
sys.path.append(f"{userHome}/dev/YMConfig")
import commandARGVAnalyze
import dingRobot

params = commandARGVAnalyze.tiskMark(sys.argv[1:])
robot = dingRobot.robot(params)
sign = sendDing.sign(robot)
print(dingMessage.msgBody(params)) 
# result = sendDing.request(sign = sign, jsonBody = dingMessage.msgBody(params))
# print(result)
