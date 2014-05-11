Pod::Spec.new do |s|
  s.name          = "STHTTPRequest"
  s.version       = "1.0.0"
  s.summary       = "A NSURLConnection wrapper for humans"
  s.homepage      = "https://github.com/nst/STHTTPRequest"
  s.license       = { :type => 'BSD', :file => 'LICENSE' }
  s.author        = { "nst" => "XXX@XXX.XXX" }
  s.source        = { :git => "https://github.com/nst/STHTTPRequest.git", :tag => "1.0.0" }
  s.source_files  = 'STHTTPRequest.{h,m}'
  s.requires_arc  = true
end