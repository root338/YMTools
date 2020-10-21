
from PIL import Image
from shutil import copyfile
import sys
import os
dir = os.path.dirname(os.path.abspath(__file__))
previousDir = os.path.dirname(dir)
sys.path.append(previousDir)
import fileTool

def replace(path, replacePath, isMust = True):
    oImgs = fileTool.search(path, "*.png", False)
    oSizeDict = imageSizesInfo(oImgs)
    rImgs = fileTool.search(replacePath, "*.png", True)
    rSizeDict = imageSizesInfo(rImgs)
    err = verifySizes(list(oSizeDict.keys()), list(rSizeDict.keys()))
    if err:
        if isMust:
            raise Exception(err)
        else:
            print(err)
            return False
    for key, value in oSizeDict.items():
        rImg = rSizeDict[key][0]
        for oImg in value:
            # os.remove(oImg)
            copyfile(rImg, oImg)
    return True

# 获取所有图片中存在多少不同大小
def imageSizesInfo(images):
    dicts = {}
    for imgFile in images:
        try:
            img = Image.open(imgFile)
            img.verify()
            key = img.size
            if key not in dicts:
                dicts[key] = [imgFile]
            else:
                dicts[key].append(imgFile)
        except Exception as e:
            pass
        else:
            continue
    return dicts

# 遍历 sizes1，对比sizes2中缺少多少同大小的图片
def verifySizes(sizes1, sizes2):
    errs = []
    for size in sizes1:
        if sizes2.count(size) == 0:
            errs.append(f"{size[0]}x{size[1]}.png")
    errC = len(errs)
    if errC == 0:
        return None
    else:
        errMsg = f'缺少{errC}张图片，分别是{",".join(errs)}'
        return errMsg
