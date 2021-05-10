#
# app对应渠道下载信息配置说明
#

def appInfoAt(bundleIdentifier):
    if not bundleIdentifier or len(bundleIdentifier) == 0:
        return None
    return allAppInfo()[bundleIdentifier]

def allAppInfo():
    return {
        # 主包
        "Bundle Identifier" : {
            "pgyer" : {
                "url" : "Download URL",
                "password" : "Password"
            },
        },
        # 测试包
        "Bundle Identifier" : {
            "pgyer" : {
                "url" : "Download URL",
                "password" : "Password"
            },
        },
    }
