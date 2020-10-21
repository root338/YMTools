
# 导入的库
require 'xcodeproj'

# 加载自定义ruby文件
# require_relative "ToolsMethod.rb"
require_relative 'XcodeProjectDefines.rb'
require_relative 'FileTool.rb'
# 或者
# $LOAD_PATH << '.'
# require 'xxx.rb'

class XcodeProject

# 配置的环境，默认 Configuration:Release
attr_accessor :configuration
# 改值时改变所有 configuration 下的值
attr_accessor :isChangeAllConfiguration
attr_accessor :isDepthSearch
def self.openProject(argv)
  if argv.class == String
    return XcodeProject.new(argv)
  elsif argv.class == Hash
    project = XcodeProject.new(argv[:projectPath])
    project.config(project)
    return project
  end
  return nil
end
def initialize(projectPath)
  if !projectPath || projectPath.class != String || !File.exist?(projectPath)
    raise "项目路径必须存在"
  end
  @isChangeAllConfiguration = false
  @configuration = Configuration::Release
  @projectPath = projectPath
  @isDepthSearch = true
end

def config(params)
  if !params || params.class != Hash
    raise "必须是 Hash 类型"
  end
  if params.empty?
    return
  end
  if params.has_key?(:configuration)
    project.configuration = params[:configuration]
  end
  if params.has_key?(:isChangeAllConfiguration)
    project.isChangeAllConfiguration = params[:isChangeAllConfiguration]
  end
  if params.has_key?(:isDepthSearch)
    project.isDepthSearch = params[:isDepthSearch]
  end
  if params.has_key?(:targetName)
    project.setTargetName(params[:targetName])
  end
end

## 文件搜索
def getFileTool
  if @fileTool
    if @fileTool.isDepth != @isDepthSearch
      @fileTool.isDepth = @isDepthSearch
    end
    return @fileTool
  end
  @fileTool = FileTool.new()
  @fileTool.isDepth = @isDepthSearch
  return @fileTool
end
# 获取项目路径
def getXcodeprojFilePath
  if @xcodeprojPath
    return @xcodeprojPath
  end
  @xcodeprojPath = getFileTool().find(
    path: @projectPath,
    searchRule: /^*\.xcodeproj$/,
  )
  return @xcodeprojPath
end
# 项目对象
def project
  if @project
    return @project
  end
  @project = Xcodeproj::Project.open(getXcodeprojFilePath())
  return @project
end
# 获取项目名
def getXcodeprojWorkspace
  if @xcodeprojWorkspace
    return @xcodeprojWorkspace
  end
  @xcodeprojWorkspace = File.basename getFileTool().find(
    path: @projectPath,
    searchRule: /^*\.xcworkspace$/,
  )
  return @xcodeprojWorkspace
end

## target 处理
def getTargetName
  return @targetName ? @targetName : getDefaultTargetName()
end
def setTargetName (targetName)
  if !targetName || targetName.class != String
    raise "target 不能为空，且必须为字符串"
  end
  @targetName = targetName
end
# 获取默认 target name
def getDefaultTargetName
  if @defaultTargetName
    return @defaultTargetName
  end
  fileName = getXcodeprojWorkspace
  project().targets.each do |target|
    if fileName == target
      return target.name
    end
  end
  if project().targets.count == 0
    return nil
  end
  @defaultTargetName = project().targets[0].name
  return @defaultTargetName
end
# 返回target 类型 PBXNativeTarget
def getTarget (targetName = nil)
  if !targetName
    targetName = getTargetName
  end
  project().native_targets.each do |target|
    if target.name == targetName
      return target
    end
  end
  return nil
end
# 获取 target 下配置参数
def getBuildConfiguration ()
  getTarget.build_configuration_list.build_configurations.each do |buildConfig|
    if buildConfig.name == @configuration
      return buildConfig
    end
  end
  return nil
end

def getBuildSetting()
  return getBuildConfiguration().build_settings
end

def setBuildSetting(key, value)
  if @isChangeAllConfiguration
    getTarget().build_configuration_list.set_setting(key, value)
  else
    getBuildSetting()[key] = value
  end
end

# 获取 info.plist 绝对路径
def getInfoAbsolutePath
  infoPath = getBuildSetting()[BuildConfigKey::INFOPLIST_FILE]
  if infoPath.start_with?('/')
    # 绝对路径
    return infoPath
  else
    xcodeprojDir = File.dirname getXcodeprojFilePath()
    return "#{xcodeprojDir}/#{infoPath}"
  end
end

def readInfo
  infoPath = getInfoAbsolutePath()
  return Xcodeproj::Plist.read_from_path(infoPath)
end

def writeInfo(hash)
  Xcodeproj::Plist.write_to_path(hash, getInfoAbsolutePath())
end
# 对 info.plist 文件单个 key 进行写入
def writeInfoKey(key, hash)
  info = readInfo()
  info[key] = hash
  writeInfo(info)
end
# 自动对 info.plist 文件单个 key 进行写入,如果是宏则改变宏对应的值
# hash 为 nil, 读取指定 key 的值，hash不为空写入指定hash值
def infoKey(key, hash = nil)
  info = readInfo()
  oldValue = info[key]
  macroValue = macroVariable(oldValue)
  if hash
    if macroValue
      setBuildSetting(macroValue, hash)
      project().save()
    elsif oldValue != hash
      info[key] = hash
      writeInfo(info)
    end
    return hash
  else
    if macroValue
      return getBuildSetting()[macroValue]
    else
      return info[key]
    end
  end
end
# 修改target 下值，并且同步修改 dependencies(包含的扩展) 下相同的值
def infoKey_syncDependencies(key, value = nil)
  oldValue = infoKey(key)
  dependencies = getTarget().dependencies
  if value && dependencies.count > 0
    oldTargetName = @targetName
    dependencies.each do |dependencie|
      @targetName = dependencie.target.name
      infoKey_syncDependencies(key, value)
    end
    @targetName = oldTargetName
  end
  return infoKey(key, value)
end

# 修改当前 target 的唯一标识，且修改 dependencies 下的所有唯一标识
def bundleIdentifier(value = nil)
  if value && value.class != String
    puts "必须是 String 类型值"
    return nil
  end
  key = InfoKey::CFBundleIdentifier
  oldvalue = infoKey(key)
  dependencies = getTarget().dependencies
  if value && dependencies.count > 0
    oldTargetName = @targetName
    dependencies.each do |dependencie|
      @targetName = dependencie.target.name
      dependencieValue = infoKey(key)
      dependencieValue = dependencieValue.gsub(oldvalue, value)
      bundleIdentifier(dependencieValue)
    end
    @targetName = oldTargetName
  end
  return infoKey(key, value)
end

def bundleShortVersion(value = nil)
  if value
    if value.class != String || !(value =~ /^[0-9]+\.[0-9]+\.[0-9]+$/)
      raise "版本号必须是 0.0.0 形式的字符串#{value}"
    end
  end
  key = InfoKey::CFBundleShortVersionString
  return infoKey_syncDependencies(key, value)
end
def bundleVersion(value = nil)
  if value.class == Integer
    value = value.to_s
  end
  if value
    if value.class != String || !(value =~ /^[0-9]+$/)
      raise "编译号必须是 String/Integer 类型纯数字"
    end
  end
  key = InfoKey::CFBundleVersion
  return infoKey_syncDependencies(key, value)
end
def bundleDisplayName(value = nil)
  key = InfoKey::CFBundleDisplayName
  if value && value.class != String
    puts "必须是 String 类型值"
    return nil
  end
  if value
    writeInfoKey(key, value)
    return value
  else
    return readInfo()[key]
  end
end

# 辅助方法
# 判断传入参数是否是 $(...) 值
def macroVariable(value)
  if value.class != String
    return nil
  end
  regexp = /^\$\([\s\S]*\)$/
  if value =~ regexp
    return value[2...(value.size - 1)]
  else
    return nil
  end
end

end

# project = XcodeProject.openProject("/Users/apple/dev/TestProject/mytest/MyTest")
# project.isChangeAllConfiguration = true
# project.bundleIdentifier("com.RubyTest.010")
