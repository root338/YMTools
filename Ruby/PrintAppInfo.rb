
require_relative 'XcodeProject.rb'
require_relative 'CommandARGVAnalyze.rb'

params, other = CommandARGVAnalyze.new.tiskMarkFull(ARGV)
projectPath = params["projectPath"]
if !File.exist?(projectPath)
  raise "项目路径(projectPath)必须存在"
end
if params["target"]
  project.setTargetName = params["target"]
end
if params["configuration"]
  project.configuration = params["configuration"]
end
project = XcodeProject.openProject(projectPath)
other.each { |value|
  if value == "bundleVersion"
    puts project.bundleVersion
  elsif value == "bundleShortVersion"
    puts project.bundleShortVersion
  end
}
