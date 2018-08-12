Pod::Spec.new do |s|
  s.name             = 'NumericalTextEntry'
  s.version          = '0.1.3'
  s.summary          = 'A text field that specializes in numeric input.'

  s.description      = <<-DESC
NumericalTextEntry is a specialized view that allows for numeric input. Input text is first formatted using an input NumberFormatter then displayed using a custom NumberDisplayer. Full description is available on GitHub.
                       DESC

  s.homepage         = 'https://github.com/Chris-Perkins/NumericalTextEntry'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'chrisfromtemporaryid@gmail.com' => 'chrisfromtemporaryid@gmail.com' }
  s.source           = { :git => 'https://github.com/Chris-Perkins/NumericalTextEntry.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'NumericalTextEntry/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'ClingConstraints', '~> 1.0.1'
  s.dependency 'PrettyButtons', '~> 0.1.0'
end
