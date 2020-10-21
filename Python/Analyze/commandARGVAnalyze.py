
import sys

def tiskMark(params, mark = ":"):
    return tiskMarkFull(params, mark)[0]

def tiskMarkFull(params, mark = ":"):
    dic = {}
    other = []
    for obj in params:
        index = obj.find(mark)
        if index == -1 or index == 0 or index == len(obj):
            other.append(obj)
            continue
        key = obj[0 : index]
        value = obj[index + 1 : len(obj)]
        dic[key] = value
    return (dic, other)
