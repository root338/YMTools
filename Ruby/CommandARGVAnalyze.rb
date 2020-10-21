
module CommandAnalyzeKeyType
  Default = "Default"
  String = "String"
end

class CommandARGVAnalyze
  attr_accessor :mark
  attr_accessor :keyType
  def self.default(params = {})
    if !params.has_key?(:keyType)
      params[:keyType] = CommandAnalyzeKeyType::Default
    end
    return CommandARGVAnalyze.new(params)
  end
  def initialize(params = {})
    @mark = params.has_key?(:mark) ? params[:mark] : ":"
    @keyType = params.has_key?(:keyType) ? params[:keyType] : CommandAnalyzeKeyType::String
  end
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
      if obj.class != String || !obj.include?(@mark)
        other << obj
        next
      end
      markIndex = obj.index(@mark)
      if markIndex == 0 || markIndex == obj.length
        other << obj
        next
      end
      key = obj[0...markIndex]
      value = obj[markIndex + 1 ... obj.length]
      if @keyType == CommandAnalyzeKeyType::String
        dic[key] = value
      else
        dic[:"#{key}"] = value
      end
    }
    return dic, other
  end
end
