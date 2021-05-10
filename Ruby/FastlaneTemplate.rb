$LOAD_PATH << '~/dev/YMTools/Ruby'
require 'BuildUpload.rb'

default_platform(:ios)

platform :ios do

  lane :haha do |params|

    params = BuildConfig.buildConfig(
      "../",
      params
    )
    build_app(params)
    UploadApp.default(
      export_method: params[:export_method],
      ipa: lane_context[SharedValues::IPA_OUTPUT_PATH],
      scheme: params[:scheme]
    )
  end

end