Pod::Spec.new do |s|
  s.name         = "JSPictureBrowser"
  s.version      = "0.0.1"
  s.summary      = "JoesRain图片浏览器"
  s.homepage     = "https://github.com/JoesRain/JSPictureBrowser"
  s.license      = "MIT"
  s.author       = { "JoesRain" => "505554859@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/JoesRain/JSPictureBrowser.git", :tag => s.version }
  s.source_files  = "BrowerDemo", "BrowerDemo/BrowerDemo/JSPictureBrowser/*.{h,m}"
  s.requires_arc = true
end
