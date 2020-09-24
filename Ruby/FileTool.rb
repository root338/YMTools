
class FileTool
  attr_accessor :ignoreFiles
  attr_accessor :isDepth
  attr_accessor :searchRule
  def self.openPath(path)
    tool = FileTool.new(path)
    return tool
  end
  def self.find(params)
    path = params[:path]
    if !params[:key] || !path
      return nil
    end
    tool = FileTool.new(params)

  end
  def initialize(params)
    @path = params[:path]
    @ignoreFiles = params.has_key?(:ignoreFiles) ? params[:ignoreFiles] : [
      /^\.[*]*$/
    ]
    isDepth = params.has_key?(:isDepth) ? params[:isDepth] : false
    @searchRule = params[:searchRule]
  end

  def find

  end
end

## 文件搜索
# rule 文件的正则匹配表达式
# isDepth 是否进行子目录匹配
# ignoreFiles 一个数组，可以包含正则表达式，也可以是 字符串
def find(path: , rule: , isDepth: isDepth = false, ignoreFiles: ignoreFiles)
  folderArr = nil
  if isDepth
    folderArr = Array.new()
  end
  puts @_fileRule.class
  @isRE = @_fileRule.class.name == "Regexp"
  puts "是否正则匹配 #{@isRE}"
  def isIgnore(file)
    if @_ignoreFiles && @_ignoreFiles.size > 0
      @_ignoreFiles.each do |chr|
        if chr.class.name == "Regexp"
          if file =~ chr
            return true
          end
        elsif file == chr
          return true
        end
      end
    end
    return false
  end
  def isEqual(file)
    if @isRE
      puts "正则匹配 #{file} , #{@_fileRule}"
      return file =~ @_fileRule
    else
      return file == @_fileRule
    end
  end

  Dir.foreach(path) { |file|
    #puts "#{file} 被忽略 #{isIgnore file}"
    if isIgnore file
      next
    end
    filePath = File.expand_path(file, path)
    if isEqual(file)
      return filePath
    end
    if folderArr && File.directory?(filePath)
      folderArr << filePath
    end
  }
  if !isDepth || folderArr.size == 0
    return nil
  end

  # puts "-------------"
  # puts folderArr
  folderArr.lazy.each do |subpath|
    result = find(
      path: subpath,
      rule: @_fileRule,
      isDepth: isDepth,
      ignoreFiles: @ignoreFiles
    )
    if result
      puts "哈哈哈"
      return result
    end
    puts subpath
  end
  return nil
end

class Test
  def initialize(argument)

    return nil
    @argument = argument
    test
  end
  def test
    puts "哈哈"
  end
end

def testfind(param)

 puts param.has_key?(:key)
end

puts Test.new("")

# puts find(
#   path: "/Users/apple/dev/TestProject/mytest",
#   rule: /^*.xcodeproj$/,
#   isDepth: true
# )

# if ( "condition" =~ "/*on/" )
#   puts "true"
# else
#   puts "false"
# end
