
# 导入的库
require 'xcodeproj'

# 加载自定义ruby文件
# require_relative "ToolsMethod.rb"
# 或者
$LOAD_PATH << '.'
require 'XcodeProjectDefines.rb'
require 'FileTool.rb'

class XcodeProject

# 配置的环境，默认 Configuration:Release
attr_accessor :configuration
# 改值时改变所有 configuration 下的值
attr_accessor :isChangeAllConfiguration
def self.openProject(projectPath)

  return XcodeProject.new(projectPath)
end
def initialize(projectPath)
  @isChangeAllConfiguration = false
  @configuration = Configuration::Release
  @projectPath = projectPath
end

## 文件搜索
def getFileTool
  if @fileTool
    return @fileTool
  end
  @fileTool = FileTool.new()
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

  @xcodeprojWorkspace = File.basename getXcodeprojFilePath(), ".xcodeproj"
  return @xcodeprojWorkspace
end

## target 处理
def getTargetName
  return @targetName ? @targetName : getDefaultTargetName
end
def setTargetName (targetName)
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
def getBuildConfiguration (configuration = nil)
  if !configuration
    configuration = @configuration
  end
  getTarget.build_configuration_list.build_configurations.each do |buildConfig|
    if buildConfig.name == configuration
      return buildConfig
    end
  end
  return nil
end

def getBuildSetting
  return getBuildConfiguration.build_settings
end

end

project = XcodeProject.openProject("/Users/apple/dev/TestProject/mytest/MyTest")
puts project.getXcodeprojWorkspace
puts project.getBuildSetting()[BuildConfigKey::INFOPLIST_FILE]
