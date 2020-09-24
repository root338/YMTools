#
# 加载ruby文件
# require_relative "ToolsMethod.rb"
# 或者
$LOAD_PATH << '.'
require 'XcodeProjectDefines.rb'
require 'xcodeproj'

class XcodeProject

# 配置的环境，默认 Configuration:Release
attr_accessor :configuration
# 改值时改变所有 configuration 下的值
attr_accessor :isChangeAllConfiguration
def self.openProject(projectPath)
  return XcodeprojTool.new(projectPath)
end
def initialize(projectPath)
  if ! File.directory? projectPath
    return nil
  end
  @isChangeAllConfiguration = false
  @configuration = Configuration::Release
  @projectPath = projectPath
  @project = Xcodeproj::Project.open(projectPath)
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

  fileName, ext = File.basename @targetPath
  @project.targets.each do |target|
    if fileName == target
      return target.name
    end
  end
  if @project.targets.count == 0
    return nil
  end
  @defaultTargetName = @project.targets[0].name
  return @defaultTargetName
end
# 返回target 类型 PBXNativeTarget
def getTarget (targetName = nil)
  if !targetName
    targetName = getTargetName
  end
  @project.native_targets.each do |target|
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

def testTool
  puts "xodeprojTool test"
end
