
require 'rexml/document'
include REXML

class XMLTool

  # 转 xml 对象(REXML::Element)
  def toElementWith(value, attrs = nil)
    if value == nil
      return nil
    end
    valueItem = nil
    name = nil
    text = nil
    valueClass = value.class
    if valueClass == String
      name = "string"
      text = value
    elsif valueClass == TrueClass || valueClass == FalseClass
      name = value ? "true" : "false"
    elsif valueClass == Integer
      name = "integer"
      text = value.to_s
    elsif valueClass == Float
      name = "real"
      text = value.to_s
    elsif valueClass == Array
      valueItem = Element.new("array", attrs)
      value.each { |obj|
        valueItem.add_element(toElementWith(obj))
      }
    elsif valueClass == Hash
      valueItem = Element.new("dict", attrs)
      value.each { |key, obj|
        keyItem = Element.new("key")
        keyItem.add_text(key.class == String ? key : key.to_s)
        valueItem.add_element(keyItem)
        valueItem.add_element(toElementWith(obj))
      }
    else
      raise "不支持的类型 #{value}"
    end
    if valueItem
      return valueItem
    end
    valueItem = Element.new(name)
    if attrs
      valueItem.add_attributes(attrs)
    end
    if text
      valueItem.add_text(text)
    end
    return valueItem
  end
  #
  def propertyListToObj(path)
    if !File.exist?(path)
      raise "路径不存在#{path}"
    end
    xmlObj = Document.new(File.new(path))
    keyPath = "plist/dict"
    dict = xmlObj.get_elements(keyPath)
    if dict.size == 1
      return toObjWith(dict[0])
    else
      raise "不是标准的 xcode .plist 文件"
    end
  end
  # xml 对象(REXML::Element)转数据
  def toObjWith(element)
    name = element.name
    text = nil
    if element.has_text?()
      text = element.get_text().to_s
    end
    elementsIsEmpty = !element.has_elements?()
    if name == "string"
      return text
    elsif name == "true" || name == "false"
      return name == "true" ? true : false
    elsif name == "integer"
      return text.to_i
    elsif name == "real"
      return text.to_f
    elsif name == "date"
      return Time.new.strftime("%Y-%m-%dT%H:%M:%SZ")
    elsif name == "array"
      list = []
      if elementsIsEmpty
        return list
      end
      element.elements.each { |item|
        list << toObjWith(item)
      }
    elsif name == "dict"
      dict = {}
      if elementsIsEmpty
        return dict
      end
      key = nil
      element.elements.each { |item|
        if key == nil
          if item.name != "key"
            raise "不是合法字典\n#{element.to_a}"
          end
          key = item.get_text().to_s
        else
          dict[key] = toObjWith(item)
          key = nil
        end
      }
      return dict
    else
      raise "不支持的类型 #{element.to_a}"
    end
  end
end
