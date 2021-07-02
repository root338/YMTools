
require_relative 'CommandARGVAnalyze.rb'
require_relative 'BuildUpload.rb'

params = CommandARGVAnalyze.new.tiskMark(ARGV)
apkPath = params["apk"]
if apkPath == nil || !File.exist?(apkPath)
  raise "请提供有效 apk 路径(apk), 当前输入值：#{apk}"
end

uploadObj = UploadApp.new
uploadObj.toPgyer(
  ipa: apkPath
)