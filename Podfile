source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

workspace 'Candygirl'
project 'Candygirl'

target 'Candygirl' do
  pod 'ASIHTTPRequest', '~> 1.8.2' #, :inhibit_warnings => true
end


post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end
