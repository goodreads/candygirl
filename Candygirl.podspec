Pod::Spec.new do |s|
  s.name             = "Candygirl"
  s.version          = "1.0.0"
  s.summary          = "Collection of helper classes and functions for iOS development"
  s.description      = <<-DESC
                        Candygirl is a collection of helper classes and functions for iOS development.
                        DESC
  s.homepage         = "https://github.com/goodreads/candygirl"
  s.license          = { :type => "BSD 3-Clause", :file => "LICENSE.md" }
  s.author           = { "Ettore Pasquini" => "Ettore Pasquini" }
  #s.documentation_url = "https://github.com/goodreads/candygirl"
  #s.social_media_url = "https://github.com/goodreads/candygirl"
  #s.source           = { :git => "https://github.com/goodreads/candygirl", :commit => '25d3c34b71c524f9996c1b2ad99a62a65cb3231f' }
  s.ios.deployment_target     = '9.0'
  s.requires_arc = true
  s.source_files     = '**/*.{h,m}'
end
