Pod::Spec.new do |s|
  s.name          = "STHTTPRequest"
  s.version       = "1.1.2"
  s.summary       = "Obj-C / Cocoa HTTP requests for humans"
  s.homepage      = "https://github.com/nst/STHTTPRequest"
  s.license       = { :type => 'New BSD', :file => 'LICENSE.txt' }
  s.authors       = 'Nicolas Seriot', 'Alistair Galbraith', 'Cyril Chandelier', 'Doug Ayers', 'Matthias Schmidt', 'Oktawian Chojnacki', 'Stephan Burlot', 'Zach Boyd', 'Torsten Louland'
  s.source        = { :git => "https://github.com/nst/STHTTPRequest.git", :tag => "1.1.2" }
  s.source_files  = 'STHTTPRequest.{h,m}'
  s.requires_arc  = true
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.7'
end
