Pod::Spec.new do |s|
  s.name             = "Candygirl"
  s.version          = "1.0.1"
  s.summary          = "Collection of helper classes and functions for iOS development"
  s.description      = <<-DESC
                        Candygirl is a collection of helper classes and functions for iOS development.
                        DESC
  s.homepage         = "https://github.com/goodreads/candygirl"
  s.license          = { :type => "BSD 3-Clause", :file => "LICENSE.md" }
  s.author           = { "Ettore Pasquini" => "Ettore Pasquini" }
  #s.documentation_url = "https://github.com/goodreads/candygirl"
  #s.social_media_url = "https://github.com/goodreads/candygirl"
  s.source           = { :git => "https://github.com/goodreads/candygirl.git", :tag => s.version }
  s.ios.deployment_target     = '8.0'
  s.requires_arc = true
  s.source_files     = '**/*.{h,m}'

   s.pod_target_xcconfig = {

	  # Warn about the use of deprecated functions, variables, and types (as indicated by the 'deprecated' attribute).
	  'GCC_WARN_ABOUT_DEPRECATED_FUNCTIONS' => 'NO',
	  'CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS' => 'NO'
  	}
end
