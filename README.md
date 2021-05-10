使用说明
文件结构
	{userName}/dev/
					{本仓库根目录}
					{密钥/账号信息配置目录}
		
环境配置
	先配置好 jenkins, fastlane, ruby, python 环境
	
	Jenkins 需要安装的插件
		Git 用于拉取远程仓库 （选择推荐插件时自动安装）
		build user vars 用于每次更新 git 时获取当前操作用户的邮箱和用户名
		Role-based Authorization Strategy 用于管理 jenkins 中的用户权限
		
	
	
Jenkins 项目配置说明	
	This project is parameterized 中可以添加的参数为（其它设置需要自行修改代码添加）
		Git Parameter (设置 git 拉取的信息)
		method (Choice Parameter 选项 导出包的类型)
			ad-hoc 
			app-store
			development
		configuration (Choice Parameter 选项 环境配置)
			Release
			Debug
		clean (Boolean Parameter 选项 build时是否清除下)
		bundleShortVersion (String Parameter 选项 Info.plist 中的 CFBundleShortVersionString key 值（格式必须 0.0.0），优先配置宏设置)
		bundleVersion (String Parameter 选项 Info.plist 中的 CFBundleVersion 值，优先配置宏设置)
		bundleVersionAutoAddOne (Boolean Parameter 选项 编译号是否自动加 1 )
		isBuild (Boolean Parameter 选项 是否进行编译)
		文件路径 (File Parameter 选项，固定值 ./tmp/ImagePath.zip，选择的包必须zip格式压缩包，根据图片像素替换项目的icon和Launch图片)
		isMustIcon (Boolean Parameter 选项 是否必须有 icon 资源)
		isMustLaunch (Boolean Parameter 选项 是否必须有 Launch 资源)
		postscript (String Parameter 选项 发生消息的备注信息)
	构建环境
		勾选 Set jenkins user build variables
	构建
		添加 Execute shell 内部粘贴 Shell/jenkinsConfigTemplate.sh 全部代码(修改内部参数时需要按需修改该 sh 文件)
	构建后操作
		添加 Build other projects 选择项目构建完成后运行其它项目，在该项目中的Shell 中 粘贴 Shell/finishWorkTemplate.sh 设置 projectName （jenkins 中设置的项目名称）

创建好 Jenkins 项目后，找到项目在 Jenkins 的路径（默认情况下 ~/.jenkins/workspace/{项目名}） 进入到 default 目录下，对该项目配置好 fastlane，设置 Fastfile 为粘贴 Ruby/FastlaneTemplate.rb 内容 （需要添加好 git 仓库到忽略文件，否则会同步 fastlane 的配置文件）

密钥/账号信息配置参照 YMConfig 文件夹下的配置模板说明