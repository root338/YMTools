
import re
import os
from pathlib import Path

def exists(path):
    p = Path(path)
    return p.exists()

# 搜索指定路径下 正则表达式(pattern)是否存在，返回一个列表
def search(path, pattern, isDepth = True):
    p = Path(path)
    if not p.exists():
        raise Exception(f"路径不存在{path}")
    subs = None
    if isDepth:
        subs = p.rglob(pattern)
    else:
        subs = p.glob(pattern)
    subList = []
    for sub in subs:
        subList.append(sub)
    return subList
def firstSearch(path, pattern, isDepth = True):
    subs = search(path, pattern, isDepth)
    for sub in subs:
        return sub

def searchText(path, pattern):
    if not path or not Path(path).exists():
        raise Exception(f"路径不存在{path}")
    if not pattern:
        return None
    obj = open(path, mode="r")
    text = obj.read()
    result = re.findall(pattern, text)
    obj.close()
    return result

def replaceText(path, new, pattern=None, old=None):
    if not path or not Path(path).exists():
        raise Exception(f"路径不存在{path}")
    if not old and not pattern:
        return False
    if not new:
        return False
    obj = open(path, mode="r")
    text = obj.read()
    obj.close()
    if old:
        if text.find(old) == -1:
            return False
        text = text.replace(old, new)
    else:
        if not re.search(pattern, text).group():
            return False
        text = re.sub(pattern, new, text)
    obj = open(path, mode="w")
    obj.write(text)
    obj.close()
    return True
