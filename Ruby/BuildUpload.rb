
require 'json'
$LOAD_PATH << '~/dev/YMConfig'
require 'YMConfig.rb'
require_relative 'XcodeProject.rb'

class BuildConfig

  def self.buildConfig(params)
    return BuildConfig.new.buildConfig(params)
  end
  # 传入项目路径，获取与工作空间同名的 scheme
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
  # 默认编译配置，fastlane action gym 的参数值
  # 必须传入 :scheme 值
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
    return YMConfig.pgyer
  end
  def self.appStoreParams(targetName)
    appStoreConfig = YMConfig.appStore()
    defaultConfig = appStoreConfig["default"]
    targetConfig = appStoreConfig[targetName]
    if targetConfig
      return defaultConfig.merge(targetConfig)
    end
    return defaultConfig
  end
  def self.altoolParams(targetName)
    YMConfig.altool().each { |key, value|
      if key.include?(targetName)
        return value
      end
    }
  end
end

class UploadApp
  # 使用默认配置进行上传
  def self.default(params)
    result = false
    if params[:export_method] == "app-store"
      puts "uploading to App Store"
      result = toAppStore(
        scheme: params[:scheme],
        ipa: params[:ipa],
      )
    else
      puts "uploading to pgyer"
      result = toPgyer(
        ipa: params[:ipa],
      )
    end
    if !result
      raise "upload Error"
    end
  end

  def self.toAppStore(params)
    upload = UploadApp.new()
    return upload.toAppStore(params)
  end
  def self.toPgyer(params)
    upload = UploadApp.new()
    return upload.toPgyer(params)
  end

  def toAppStore(params)
    scheme = params[:scheme]
    if !params.has_key?(:username) && !params.has_key?(:password) && scheme
      params = params.merge(UploadConfig.altoolParams(scheme))
    end
    if !params.has_key?(:username) || !params.has_key?(:password) || !params.has_key?(:ipa)
      raise "必须存在 username(用户名), password(密码), ipa(ipa文件路径)，源数据: #{params}"
    end
    result = system "xcrun altool" " --upload-app -f '#{params[:ipa]}' -t ios -u '#{params[:username]}' -p '#{params[:password]}'"
    return result
  end

  def verifyPayer(params)
    requiredKeys = [
      :ipa,
      :user_key,
      :api_key,
      :install_type,
      :password,
    ]
    requiredKeys.each { |key|
      if !params.has_key?(key)
        raise "必须包含#{requiredKeys}，源数据: #{params}"
      end
    }
  end

  def runUploadingPgyer(params)
    verifyPayer(params)
    return system "curl" " -F 'file=@#{params[:ipa]}' -F 'uKey=#{params[:user_key]}' -F '_api_key=#{params[:api_key]}' -F 'installType=#{params[:install_type]}' -F 'password=#{params[:password]}' https://upload.pgyer.com/apiv1/app/upload"
  end

  def toPgyer(params)
    if params.has_key?(:ipa) && params.length == 1
      params = params.merge(UploadConfig.pgyerParams)
    end
    result = runUploadingPgyer(params)
    if !result
      # 重试一次
      result = runUploadingPgyer(params)
    end
    return result
  end
end

# puts UploadConfig.altoolParams("MyTest")
# file = "/Users/apple/Documents/Ipa/QuickAskCommunity/ad-hoc/QuickAskCommunity-ad-hoc-ad-hoc 2020-10-29 16-33-00.ipa"
# result = UploadApp.toPgyer(
#   ipa: file
# )
# puts result
