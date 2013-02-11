Pod::Spec.new do |s|
  s.name         = "TimesSquare"
  s.version      = "1.0.1"
  s.summary      = "TimesSquare is an Objective-C calendar view for your apps."
  s.homepage     = "https://github.com/square/objc-TimesSquare"
  s.license      = 'Apache License, Version 2.0'
  s.author       = { "Square" => "http://squareup.com" }
  s.source       = { :git => "https://github.com/square/objc-TimesSquare.git", :branch => "master", :tag => s.version.to_s }
  s.platform     = :ios, '5.0'
  s.source_files = 'TimesSquare/*.{h,m}'
  s.preserve_paths = 'TimesSquare.xcodeproj', 'TimesSquareResources'
  s.requires_arc = true

  def s.post_install(target)
    puts "\nGenerating TimesSquare resources bundle\n".yellow if config.verbose?
    Dir.chdir File.join(config.project_pods_root, 'TimesSquare') do
      command = "xcodebuild -project TimesSquare.xcodeproj -target TimesSquareResources CONFIGURATION_BUILD_DIR=../Resources"
      command << " 2>&1 > /dev/null" unless config.verbose?
      unless system(command)
        raise ::Pod::Informative, "Failed to generate TimesSquare resources bundle"
      end

      File.open(File.join(config.project_pods_root, target.target_definition.copy_resources_script_name), 'a') do |file|
        file.puts "install_resource 'Resources/TimesSquareResources.bundle'"
      end
    end
  end
end