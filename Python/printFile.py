
import os
import sys
from pathlib import Path

dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(f"{dir}/Analyze")

import fileTool
import commandARGVAnalyze

params = commandARGVAnalyze.tiskMark(sys.argv[1:])
if "path" not in params:
    raise Exception("需要目标(path), 可以是文件/目录路径")
if "textRE" not in params:
    raise Exception("需要字符串匹配规则(textRE)")
path = params["path"]
pObj = Path(path)
if not pObj.exists():
    raise Exception(f"目标({path})不存在")
files = []
if pObj.is_dir():
    if "filePattern" not in params:
        raise Exception("传入目录的话需要给出文件检索格式(filePattern)")
    files = fileTool.search(path, pattern=params["filePattern"])
else:
    files = [path]

n = int(params.get("n", "0"))
# line = int(params.get("line", "-1"))

textRE = params["textRE"]
resultList = []
for file in files:
    if Path(file).is_dir():
        continue
    r = fileTool.searchText(file, textRE)
    if not r or len(r) == 0:
        continue
    totalCount = len(r) + len(resultList)
    # isLine = line >= 0 and totalCount > line
    isN = n > 0 and totalCount >= n
    isEnd = isN
    if isEnd:
        resultList.extend(r[:len(r) - (totalCount - n)])
        break
    else:
        resultList.extend(r)
if len(resultList) > 0:
    print("\n".join(resultList))
