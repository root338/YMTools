
# 文件工具
# 参数说明:
# ignoreFiles: 一个数组，一个忽略文件列表，可以是字符串或正则表达式，默认忽略 .开头的所有文件
# isDepth: 是否递归子目录搜索，默认 false
# searchRule: 搜索的文件规则，可以是字符串或正则表达式
class FileTool
  attr_accessor :ignoreFiles
  attr_accessor :isDepth
  attr_accessor :searchRule

  def self.find(params)
    path = params[:path]
    if !params[:searchRule] || !path
      return nil
    end
    tool = FileTool.new(params)
    return tool.find(path)
  end

  def initialize(*params)
    if !params || params.class != Hash
      params = {}
    end
    @ignoreFiles = params.has_key?(:ignoreFiles) ? params[:ignoreFiles] : [
      /^\.[\d\D]*$/
    ]
    @isDepth = params.has_key?(:isDepth) ? params[:isDepth] : false
    @searchRule = params[:searchRule]
  end

  ## 文件搜索
  def find (params)
    if params.class == Hash
      beginFind(params)
      path = params[:path]
      result = nil
      if shouldFind(path)
        result = _find(path)
      end
      endFind()
      return result
    elsif params.class == String
      if !shouldFind(params)
        return nil
      end
      return _find(params)
    else
      puts "not support #{params.class}， only support String/Hash"
      return nil
    end
  end
# -------------
# 私有方法
# -------------
  def beginFind (params)
    @cacheAtt = {
      ignoreFiles: @ignoreFiles,
      isDepth: @isDepth,
      searchRule: @searchRule
    }
    setSearchParams(params)
  end

  def endFind ()
    setSearchParams(@cacheAtt)
    @cacheAtt = nil
  end

  def setSearchParams(params)
    if params.has_key?(:ignoreFiles)
      @ignoreFiles = params[:ignoreFiles]
    end
    if params.has_key?(:isDepth)
      @isDepth = params[:isDepth]
    end
    if params.has_key?(:searchRule)
      @searchRule = params[:searchRule]
    end
  end

  def shouldFind (targetPath)
    if targetPath == nil || !File.exist?(targetPath)
      puts "需要提供有效的搜索文件路径"
      return false
    end
    if @searchRule == nil
      puts "searchRule is not nil"
      return false
    end
    return true
  end

  def _find (path)

    folderArr = nil
    if @isDepth
      folderArr = Array.new()
    end
    Dir.foreach(path) { |file|
      #puts "#{file} 被忽略 #{isIgnore file}"
      if shouldIgnore file
        next
      end
      filePath = File.expand_path(file, path)
      if isInclude(file, @searchRule)
        return filePath
      end
      if folderArr && File.directory?(filePath)
        folderArr << filePath
      end
    }
    if !@isDepth || folderArr.size == 0
      return nil
    end

    folderArr.lazy.each do |subpath|
      result = find(subpath)
      if result
        return result
      end
    end
    return nil
  end

  # 是否忽略文件
  def shouldIgnore (fileName)
    if @ignoreFiles == nil || @ignoreFiles.size == 0
      return false
    end
    @ignoreFiles.each do |chr|
      if isInclude(fileName, chr)
        return true
      end
    end
    return false
  end
  # 是否包含
  # value 需要判断的值
  # condition 条件，可以是字符串或正则表达式
  def isInclude(value, condition)
    if condition.class == Regexp
      return value =~ condition
    else
      return value == condition
    end
  end

  private :_find, :shouldIgnore, :isInclude, :shouldFind
  private :setSearchParams, :endFind, :beginFind
end

# puts FileTool.find(
#   path: "/Users/apple/dev/TestProject/mytest",
#   searchRule: /^*.xcodeproj$/,
#   isDepth: true
# )

# file = "/path/to/xyz.mp4"
#
# comp = File.basename file        # => "xyz.mp4"
# extn = File.extname  file        # => ".mp4"
# name = File.basename file, extn  # => "xyz"
# path = File.dirname  file        # => "/path/to"
