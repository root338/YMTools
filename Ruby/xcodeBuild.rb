
require 'rexml/document'
require 'fileutils'
include REXML
require_relative 'BuildUpload.rb'
require_relative 'XMLTool.rb'
require_relative 'fileExtension.rb'

class XcodeBuild
  def exportIpa(params)
    # xcodebuild -exportArchive -archivePath <xcarchivepath> [-exportPath <destinationpath>] -exportOptionsPlist <plistpath>
    if !params.has_key?(:archivePath)
      raise "必须设置归档路径(archivePath)"
    end
    exception = nil
    tmpDir = nil
    tmpExportOptionsPlistPath = nil
    begin
      exportOptionsPlistKey = :exportOptionsPlist
      if !params.has_key?(exportOptionsPlistKey) || !File.exist?(params[exportOptionsPlistKey])
        tmpExportOptionsPlistPath = generateDefaultExportOptionsPlist(params)
        params[exportOptionsPlistKey] = tmpExportOptionsPlistPath
      end
      appInfo = archiveAppInfo(params)
      exportPathKey = :exportPath
      if !params.has_key?(exportPathKey)
        tmpDir = FileE.mkdir("~/Library/Caches/YMTools/.#{rand(9999999).to_s}")
        params[exportPathKey] = tmpDir
      end
      commandName = "xcodebuild"
      argv = " -exportArchive"
      argvParams = params.slice(:archivePath, exportOptionsPlistKey, exportPathKey)
      argvParams.each { |key, value|
        argv += " -#{key.to_s} '#{value.to_s}'"
      }
      if params.key? :export_xcargs
        argv += " #{params[:export_xcargs]}"
      end
      result = system "#{commandName}" "#{argv}"
      if !result
        raise "导出 ipa 失败"
      end
      ipaPath = nil
      if tmpDir
        ipaPath = FileE.mkdir(File.join(appInfo[:output_directory], appInfo[:output_name]), true)
        FileUtils.mv(File.join(tmpDir, "#{appInfo[:scheme]}.ipa"), ipaPath)
      else
        ipaPath = FileE.mkdir(File.join(params[exportPathKey], "#{appInfo[:scheme]}.ipa"))
      end
      puts "Exported QuickAskCommunity to: #{ipaPath}"
      return appInfo
    rescue
      exception = $!
    ensure
      if tmpExportOptionsPlistPath
        File.delete(tmpExportOptionsPlistPath)
      end
      if tmpDir
        FileUtils.rm_rf(tmpDir)
      end
    end
    if exception
      raise exception
    end
  end
  # 生成默认的导出包的配置文件
  def generateDefaultExportOptionsPlist(params = nil)
    filePath = FileE.mkdir("~/Library/Caches/YMTools/.#{rand(9999999).to_s}.plist", true)
    file = File.new(filePath, "w+")
    defaultParams = {
      uploadBitcode: false,
      uploadSymbols: true,
      method: params.has_key?(:export_method) ? params[:export_method] : "ad-hoc"
    }
    params = defaultParams.merge(params)
    content = generatePropertyList(params)
    file.puts(content)
    file.close()
    return filePath
  end
  # 生成 xcode property list 文件
  def generatePropertyList(params)
    if params.class != Hash || params.empty?
      raise "不能生成 xml 内容"
    end
    xmlStr = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
</plist>
EOF
    xmlTool = XMLTool.new()
    xmlObj = Document.new(xmlStr)
    xmlObj.elements.each("plist") { |mainElement|
      mainElement.add_element(xmlTool.toElementWith(params))
    }
    output = ""
    xmlObj.write(
      output: output,
      indent: 1,
    )
    return output
  end

  def archiveAppInfo(params)
    xmlTool = XMLTool.new()
    info = xmlTool.propertyListToObj(File.join(params[:archivePath], "Info.plist"))
    method = params.fetch(:export_method, xmlTool.propertyListToObj(params[:exportOptionsPlist])["method"])
    config = {
      scheme: info["SchemeName"],
      workspace: info["Name"],
      export_method: method
    }.compact
    if params.has_key?(:configuration)
      config = params[:configuration]
    end
    appInfo = BuildConfig.new().buildConfig(config)
    appInfo.merge()
    return appInfo
  end
end
