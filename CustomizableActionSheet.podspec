Pod::Spec.new do |s|
  s.name = "CustomizableActionSheet"
  s.version = "1.2.3"
  s.summary = "Action sheet allows including your custom views and buttons."
  s.homepage = "https://github.com/beryu/CustomizableActionSheet"
  s.screenshots = "https://github.com/beryu/CustomizableActionSheet/raw/master/assets/screenshot1.png"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Ryuta Kibe" => "beryu@blk.jp" }
  s.social_media_url = "https://twitter.com/beryu"
  s.platform = :ios
  s.ios.deployment_target = "8.0"
  s.source = { :git => "https://github.com/beryu/CustomizableActionSheet.git", :tag => s.version }
  s.source_files = "Source/*"
  s.requires_arc = true
end

