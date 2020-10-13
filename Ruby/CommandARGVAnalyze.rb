
class CommandARGVAnalyze
  # 冒号分隔，仅返回符合条件的
  def tiskMark(params)
    a, b = tiskMarkFull(params)
    return a
  end
  # 冒号分隔，返回两个变量，第一个符合条件的hash值，第二个不符合条件的源数据
  def tiskMarkFull(params)
    dic = {}
    other = []
    params.each { |obj|
      markStr = ":"
      if !obj.include?(markStr)
        other << obj
        next
      end
      markIndex = obj.index(markStr)
      if markIndex == 0 || markIndex == obj.length
        other << obj
        next
      end
      key = obj[0...markIndex]
      value = obj[markIndex + 1 ... obj.length]
      dic[key] = value
    }
    return dic, other
  end
end
