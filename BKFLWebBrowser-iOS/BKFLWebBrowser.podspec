#
# Be sure to run `pod lib lint BKFLWebBrowser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'BKFLWebBrowser'

    s.version         = "1.0.0"
    s.summary          = 'BKFLWebBrowser是贝壳Flutter容灾降级容器'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

    s.description      = <<-DESC
    BKFLWebBrowser是贝壳Flutter容灾降级容器
    DESC

    s.homepage         = 'https://github.com/LianjiaTech'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { '李翔宇' => 'lixiangyu' }
    s.source           = { :git => "", :tag => s.name.to_s + "-" + s.version.to_s }
    s.ios.deployment_target = '9.0'
    s.default_subspec = 'Browser'
    
    s.preserve_paths = "#{s.name}/Classes/**/*",
                       "#{s.name}/Framework/**/*",
                       "#{s.name}/Assets/**/*"
                    
    s.dependency 'Flutter' 
    s.dependency 'WebViewJavascriptBridge'
    s.dependency 'RSSwizzle', '~>0.1.0'

    s.pod_target_xcconfig = {
        'GCC_PREPROCESSOR_DEFINITIONS' => "BKWEBBROWSER_FRAMEWORK=#{s.name} BKWEBBROWSER_FRAMEWORK_VERSION=#{s.version}",
        'OTHER_LDFLAGS' => "-weak_framework Flutter"
    }

    _Browser = {
        :spec_name => 'Browser',
        :resource_bundles => {
            "#{s.name}_Browser" => ["#{s.name}/Assets/flutter_channel_js/Foundation/*.js"]
        },
        :dependency => [{:name => 'Masonry'},
                        {:name => 'RSSwizzle'}],
        :frameworks => ['WebKit']
    }
    
    _Module = {
        :spec_name => 'Module',
        :sub_dependency => [_Browser],
    }

    _BridgeEnvConfig = {
        :spec_name => 'BridgeEnvConfig'
    }
    
    _Bridge = {
        :spec_name => 'Bridge',
        :sub_dependency => [_BridgeEnvConfig, _Browser],
        :dependency => [{:name => 'WebViewJavascriptBridge'}],
        :resource_bundles => {
            "#{s.name}_Bridge" => ["#{s.name}/Assets/flutter_channel_js/Bridge/*.js"]
        }
    }
    
    _FlutterEnvConfig = {
        :spec_name => 'FlutterEnvConfig'
    }
    
    _FlutterChannelsHook = {
        :spec_name => '_FlutterChannelsHook',
        :requires_arc => false,
    }
    
    _Flutter = {
        :spec_name => 'Flutter',
        :source_files => "#{s.name}/Classes/Flutter/*.{h,m,mm,c,cpp}",
        :public_header_files => "#{s.name}/Classes/Flutter/*.h",
        :sub_dependency => [_FlutterEnvConfig, _FlutterChannelsHook, _Browser, _Bridge],
        :resource_bundles => {
            "#{s.name}_Flutter" => ["#{s.name}/Assets/flutter_channel_js/Flutter/Channel/iOS/*.js",
                                    "#{s.name}/Assets/flutter_channel_js/Flutter/Context/*.js"]
        }
    }
    
    _Tool = {
        :spec_name => 'Tool',
        :source_files => "#{s.name}/Classes/Tool/*.{h,m,mm,c,cpp}",
        :public_header_files => "#{s.name}/Classes/Tool/*.h",
    }
    
    _Flutter2Web = {
        :spec_name => 'Flutter2Web',
        :source_files => "#{s.name}/Classes/Flutter2Web/*.{h,m,mm,c,cpp}",
        :public_header_files => "#{s.name}/Classes/Flutter2Web/*.h",
        :sub_dependency => [_BridgeEnvConfig, _Flutter, _Module, _Tool]
    }
    

    #subspec的集合
    _subspecs = [_Browser, _BridgeEnvConfig, _Bridge, _FlutterEnvConfig, _FlutterChannelsHook, _Flutter, _Flutter2Web, _Module, _Tool]
    
    if ENV["IS_RELEASE"] || ENV["#{s.name}_RELEASE"]
        configuration = "Release"
    else
        configuration = "Debug"
    end
    



    _subspecs.each do |spec|
        if spec.delete(:noSource)
            next
        end
        
        if ENV["#{s.name}_#{spec[:spec_name]}_SOURCE"] || ENV['IS_SOURCE'] || spec[:spec_name] == "EnvConfig" || spec[:spec_name] == "BridgeEnvConfig" || spec[:spec_name] == "AjaxHookEnvConfig" || spec[:spec_name] == "FlutterEnvConfig"
            
            if spec[:source_files].nil?
                spec[:source_files] = "#{s.name}/Classes/#{spec[:spec_name]}/**/*.{h,m,mm,c,cpp}"
            end
            
            if spec[:public_header_files].nil?
                spec[:public_header_files] = "#{s.name}/Classes/#{spec[:spec_name]}/**/*.h"
            end
        else
            spec[:source_files] = "#{s.name}/Framework/#{spec[:spec_name]}/#{configuration}/*.h"
            spec[:public_header_files] = "#{s.name}/Framework/#{spec[:spec_name]}/#{configuration}/*.h"
            spec[:vendored_frameworks] = "#{s.name}/Framework/#{spec[:spec_name]}/#{configuration}/*.framework"
        end
    end
    
    _subspecs.each do |spec|
        s.subspec spec[:spec_name] do |ss|
            if spec[:source_files]
                ss.source_files = spec[:source_files]
            end
            
            if spec[:public_header_files]
                ss.public_header_files = spec[:public_header_files]
            end
            
            if spec[:vendored_libraries]
                ss.vendored_libraries = spec[:vendored_libraries]
            end
            
            if spec[:vendored_frameworks]
                ss.vendored_frameworks = spec[:vendored_frameworks]
            end
            
            if spec[:resources]
                ss.resources = spec[:resources]
            end
            
            if spec[:resource_bundles]
                ss.resource_bundles = spec[:resource_bundles]
            end
            
            if spec[:sub_dependency]
                spec[:sub_dependency].each do |dep|
                    ss.dependency "#{s.name}/#{dep[:spec_name]}"
                end
            end
            
            if spec[:dependency]
                spec[:dependency].each do |dep|
                    if dep.has_key?(:version)
                        ss.dependency dep[:name], dep[:version]
                    else
                        ss.dependency dep[:name]
                    end
                end
            end
            
            if spec[:libraries]
                ss.libraries = spec[:libraries]
            end
            
            if spec[:frameworks]
                ss.frameworks = spec[:frameworks]
            end
            
            if spec[:weak_frameworks]
                ss.weak_frameworks = spec[:weak_frameworks]
            end
            
            if spec[:pod_target_xcconfig]
                ss.pod_target_xcconfig = spec[:pod_target_xcconfig]
            end
            
            if spec[:requires_mrc]
                ss.requires_arc = false
            end
            
            if spec.has_key?(:requires_arc)
                ss.requires_arc = spec[:requires_arc]
            end
        end
    end
end
