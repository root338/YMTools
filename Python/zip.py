
# import io
# import sys
# 系统默认编码方式
# print(sys.getdefaultencoding())
# sys.stdout = io.TextIOWrapper(sys.stdout.buffer,encoding='unicode_escape')

import zipfile
from pathlib import Path
from pathlib import PurePath
from os.path import dirname
import pathTool

def verify(filename):
    return zipfile.is_zipfile(filename)

def removeAll(path):
    pathObj = Path(path)
    if not pathObj.exists():
        return
    if not pathObj.is_dir():
        pathObj.unlink()
        return
    for subObj in pathObj.iterdir():
        subPath = PurePath(path).joinpath(subObj)
        removeAll(subPath)
    pathObj.rmdir()
#
def unzip(filePath, isReplace=False, unzipPath = None):
    if not verify(filePath):
        raise Exception(f"{filePath} 不是一个有效的zip压缩文件")
    if not unzipPath:
        unzipPath = dirname(filePath)
    fileObj = zipfile.ZipFile(filePath, 'r')
    originDirs = []
    for file in fileObj.namelist():
        if file.startswith("__MACOSX/"):
            continue
        if isReplace:
            removeAll(pathTool.pathAppend(file, unzipPath))
        newAbspath = pathTool.pathAppend(file.encode('cp437').decode('utf-8'), unzipPath)
        if isReplace:
            removeAll(newAbspath)
        extractPath = fileObj.extract(file, path=unzipPath)
        Path(extractPath).rename(newAbspath)
        # file 是目录时在最后会拼上/, 而 zipfile.ZipFile.extract 解压时如果是目录则没有 /
        if not newAbspath.startswith(extractPath):
            originDirs.append(extractPath)
    for dir in originDirs:
        removeAll(dir)
    return unzipPath

# unzip("/Users/apple/Downloads/iOS四个包-双十一/主包iOS-icon+启动页.zip", True)
# unzip("/Users/apple/Documents/YMMainAppIcon/11.11.zip")
