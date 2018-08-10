#
# Be sure to run `pod lib lint NumericalTextField.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NumericalTextEntry'
  s.version          = '0.1.0'
  s.summary          = 'A text field that specializes in numeric input.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
NumericalTextEntry is a specialized view that allows for numeric input. Input text is first formatted using an input NumberFormatter then displayed using a custom NumberDisplayer.
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
