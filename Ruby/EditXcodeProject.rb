
require_relative 'XcodeProject.rb'
require_relative 'CommandARGVAnalyze.rb'

class EditXcodeProject

  def self.edit(params)
    params = CommandARGVAnalyze.new.tiskMark(params)
    projectPath = params["projectPath"]
    if projectPath == nil || !File.exist?(projectPath)
      raise "请提供有效项目路径(projectPath), 当前输入值：#{projectPath}"
    end
    editObj = EditXcodeProject.new(projectPath)
    editObj.editProject(params)
  end
  def initialize(projectPath)
    @project = XcodeProject.openProject(projectPath)
  end
  def editProject(params)
    logs = []
    @project.isChangeAllConfiguration = params["changeAll"] == "true" ? true : false
    shortVersion = params["bundleShortVersion"]
    if shortVersion && shortVersion.length > 0
      oldShortVersion = @project.bundleShortVersion()
      @project.bundleShortVersion(shortVersion)
      if oldShortVersion != shortVersion
        logs << "版本号#{oldShortVersion}=>#{shortVersion}"
      end
    end

    oldVersion = @project.bundleVersion()
    bundleVersion = params["bundleVersion"]
    if bundleVersion && bundleVersion.length > 0
      @project.bundleVersion(bundleVersion)
    elsif params["isAddOne"] == "true"
      @project.bundleVersion(@project.bundleVersion().to_i + 1)
    end
    newVersion = @project.bundleVersion()
    if oldVersion != newVersion
      logs << "编译号#{oldVersion}=>#{newVersion}"
    end

    displayName = params["displayName"]
    if displayName && displayName.length > 0
      oldDisplayName = @project.bundleDisplayName()
      if oldDisplayName != displayName
        displayName = @project.bundleDisplayName(displayName)
      end
      if oldDisplayName != displayName
        logs << "app显示名称#{oldDisplayName}=>#{displayName}"
      end
    end

    puts logs.join(",")
  end
end
EditXcodeProject.edit(ARGV)

# if params.has_key? "CFBundleShortVersionString"
#
# end
