#
# 项目信息配置模板说明
#

class YMConfig
  # 蒲公英配置
  def self.pgyer
    return {
      api_key: "API_KEY",
      user_key: "USER_KEY",
      password: "PASSWORD",
      install_type: "2" # "2" 代表需要密码下载，蒲公英现在必须配置密码
    }
  end
  # appStore 配置
  def self.appStore
    return {
      "default" => {
          skip_screenshots: true,
          skip_metadata: true
      },
      "Target Name" => {
        username: "Apple Account"
      }
    }
  end
  # 使用 altool 命令行参数配置
  def self.altool
    return {
      ["Target Name", "Target Name"] => {
        username: "Apple Account",
        password: "生成的 App 专用密码"
      },
      ["Target Name"] => {
        username: "Apple Account",
        password: "生成的 App 专用密码"
      }
    }
  end
end
