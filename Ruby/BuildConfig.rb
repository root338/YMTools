
require 'json'
require_relative 'XcodeProject.rb'

class BuildConfig

  def self.buildConfig(params)
    return BuildConfig.new.buildConfig(params)
  end
  def self.buildConfig(path, params = nil)
    if params == nil
      params = {}
    end
    if params.class != Hash
      puts "params 参数必须 Hash"
    end
    project = XcodeProject.openProject(path)
    params[:scheme] = project.getTargetName
    params[:workspace] = project.getXcodeprojWorkspace
    return BuildConfig.new.buildConfig(params)
  end

  def getDefaultBuildConfig(params)

    if !params.has_key?(:scheme)
      puts "需要项目 scheme "
      return nil
    end
    scheme = params[:scheme]
    export_method = params.has_key?(:export_method) ? params[:export_method] : "ad-hoc"
    configuration = params.has_key?(:configuration) ? params[:export_method] : "Release"
    outputFolder = "~/Documents/Ipa/#{scheme}"
    time = Time.new
    mFormatDate = time.strftime("%Y-%m-%d %H-%M-%S")
    outputFolder = "#{outputFolder}/#{export_method}"
    output_name = "#{scheme}-#{export_method}-#{configuration} #{mFormatDate}"
    return {
      output_directory: outputFolder,
      output_name: output_name,
      configuration: configuration,
      export_method: export_method,
      clean: true,
      export_xcargs: "-allowProvisioningUpdates"
    }
  end

  def buildConfig(params)
    if params == nil || (params.class != String && params.class != Hash)
      puts "必须传入 scheme 值，传入字符串默认表示 scheme。Hash 必须存在 scheme key"
      return nil
    end
    if params.class == String
      params = {
        scheme: params
      }
    end
    defaultConfig = getDefaultBuildConfig(params)
    if params.class != Hash
      return defaultConfig
    end
    return defaultConfig.merge(params)
  end

end

class UploadConfig
  def self.pgyerParams
    configPath = "/Users/apple/dev/YMConfig/pgyerConfig.json"
    if !File.exist?(configPath)
      puts "配置文件#{configPath}不存在"
      return nil
    end
    json = File.read(configPath)
    return JSON.parse(json)
  end
  def self.appStoreParams
    # return {
    #   skip_screenshots: true,
    #   skip_metadata: true,
    # }
  end
end

puts UploadConfig.pgyerParams()
