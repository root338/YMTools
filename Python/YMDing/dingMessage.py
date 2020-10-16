
def msgBody(params):
    if "type" not in params:
        raise Exception(f"请输入消息类型(type), 例如: text, link, markdown, actionCard, feedCard")
    type = params["type"]
    def appendAt(msgBody):
        _at = at(params)
        if _at:
            msgBody.update(_at)
        return msgBody
    if type == "text":
        return appendAt(text(params))
    elif type == "link":
        return link(params)
    elif type == "markdown":
        return appendAt(markdown(params))
    else:
        return nil

def msg(keys, mustKeys, params):
    msg = {}
    for key in keys:
        isMust = mustKeys.count(key) > 0
        isExist = key in params
        if not isExist:
            if isMust:
                raise Exception(f"{params} 必须存在 {mustKeys}")
            continue
        value = params[key].strip()
        if len(value) == 0:
            if isMust:
                raise Exception(f"{key} 内容不能为空")
            continue
        msg[key] = value
    return msg

def text(params):
    text = None
    if isinstance(params, dict):
        if "text" not in params:
            raise Exception(f"text类型消息，必须存在文本内容(text)")
        text = params["text"]
    elif isinstance(params, str):
        text = params
    else:
        raise Exception(f"{params} 仅支持 str/dict")
    text = text.strip()
    if len(text) == 0:
        raise Exception(f"text 不能为空")
    return {
        "msgtype": "text",
        "text": {
            "content": text,
        },
    }

def link(params):
    mustKeys = ["title","text","messageUrl"]
    allKeys = mustKeys.copy()
    allKeys.append("picUrl")
    return {
        "msgtype": "link",
        "link" : msg(allKeys, mustKeys, params)
    }
def markdown(params):
    mustKeys = ["title","text"]
    allKeys = mustKeys.copy()
    return {
        "msgtype": "markdown",
        "markdown" : msg(allKeys, mustKeys, params)
    }

def at(params):
    if not isinstance(params, dict):
        raise Exception(f"{params} 仅支持dict")
    if "isAtAll" in params and params["isAtAll"] == "true":
        return {
            "at" : {
                "isAtAll" : True
            }
        }
    if "mobiles" in params:
        return {
            "at" : {
                "atMobiles" : params["mobiles"].split(",")
            }
        }
    return None
