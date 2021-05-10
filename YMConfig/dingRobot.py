# 
# 对应钉钉机器人配置模板说明
# 
# 所有机器人列表，返回类型为 dict { 群名 : { 机器人必要的信息 } }
def allRobots():
    return {
        "group key" : {
            "access_token" : "钉钉机器人 access_token 值",
            "secret" : "钉钉机器人 secret 值"
        },
        "group key" : {
            "access_token" : "钉钉机器人 access_token 值",
            "secret" : "钉钉机器人 secret 值"
        },
    }
# 获取指定机器人，传入参数 如果是 dict 必须包含 groupName 字段，如果为 str 则直接表示群名
def robot(params):
    groupName = None
    if isinstance(params, dict):
        if "groupName" not in params:
            raise Exception(f"输入参数{params}，缺少 groupName")
        groupName = params["groupName"]
    elif isinstance(params, str):
        groupName = params
    robots = allRobots()
    if groupName == None or groupName not in robots:
        raise Exception(f"输入的群名{groupName}不存在机器人信息")
    return robots[groupName]
# 获取群名 传入数据(项目标识符, 结果，包类型(app-store，adhoc...)) 通过 allGroupName() 方法来关联指定项目下
# 在成功/失败后向哪些群发送消息
def groupName(bundleIdentifier, result, method):
    groupKey = "successGroupName" if result else "failureGroupName"
    def handleGroupNameDict(dict):
        group = dict.get(method if method in dict else "default")
        if not group:
            return dict.get(groupKey if groupKey in dict else "groupName")
        return group.get(groupKey if groupKey in group else "groupName")
    def isContains(mObj):
        if isinstance(mObj, str) and mObj == bundleIdentifier:
            return True
        elif isinstance(mObj, tuple) and bundleIdentifier in mObj:
            return True
        # elif isinstance(mObj, list) and mObj.count(bundleIdentifier):
        #     return True
        # elif isinstance(mObj, set) and bundleIdentifier in mObj:
        #     return True
        else:
            return False
    for (key, value) in allGroupName().items():
        if isContains(key):
            return handleGroupNameDict(value)
    return None
# 所有项目在不同类型下发送的群名
def allGroupName():
    return {
        (
            "Bundle Identifier",
            "Bundle Identifier"
        ) : {
            "app-store(上传的渠道)" : {
                "successGroupName" : "group key",
                "failureGroupName" : "group key",
            },
            "default" : {
                "successGroupName" : "group key",
                "failureGroupName" : "group key",
            }
        },
        "Bundle Identifier" : {
            "default" : {
                "successGroupName" : "group key",
                "failureGroupName" : "group key",
            }
        }
    }
