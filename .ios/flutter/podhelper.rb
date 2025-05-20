require 'fileutils'
require 'json'

def install_all_flutter_pods(flutter_application_path)
  flutter_ios_engine_podspec = File.expand_path(File.join(flutter_application_path, '.ios', 'Flutter', 'engine', 'Flutter.podspec'))

  if File.exist?(flutter_ios_engine_podspec)
    pod 'Flutter', :podspec => flutter_ios_engine_podspec
  else
    pod 'Flutter', :path => File.join(flutter_application_path, '.ios', 'Flutter')
  end

  symlinks_dir = File.join(__dir__, '..', '.symlinks')
  FileUtils.mkdir_p(symlinks_dir)

  plugins_file = File.join(flutter_application_path, '.flutter-plugins-dependencies')
  if File.exist?(plugins_file)
    plugin_pods = JSON.parse(File.read(plugins_file))["plugins"]["ios"]
    plugin_pods.each do |plugin|
      name = plugin["name"]
      path = plugin["path"]
      symlink = File.join(symlinks_dir, "plugins", name)
      FileUtils.mkdir_p(File.dirname(symlink))
      FileUtils.ln_sf(path, symlink)
      pod name, :path => File.join(symlink, "ios")
    end
  end
end

def flutter_post_install(installer)
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end