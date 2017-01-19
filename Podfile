
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
inhibit_all_warnings!

target 'Microsoft Tasks' do
    pod 'ADAL'

    target 'Microsoft TasksTests' do
        inherit! :search_paths
    end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        puts "#{target.name}"
    end