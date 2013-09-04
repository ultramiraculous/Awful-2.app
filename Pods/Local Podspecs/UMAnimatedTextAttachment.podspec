Pod::Spec.new do |s|
  s.name         = "UMAnimatedTextAttachment"
  s.version      = "0.1"
  s.summary      = "A WHATWG-complaint HTML parser in Objective-C."
  s.homepage     = "https://github.com/ultramiraculous/UMAnimatedTextAttachment"
  s.license      = "MIT"
  s.author       = { "Chris Williams" => "ultramiraculous@gmail.com" }
  s.source       = { :git => "https://github.com/ultramiraculous/UMAnimatedTextAttachment.git", :tag => "v0.1" }
  s.source_files = "UMAnimatedTextAttachment/*.{h,m}"
  s.requires_arc = true
end