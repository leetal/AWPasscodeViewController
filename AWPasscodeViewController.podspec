#
# Be sure to run `pod lib lint AWPasscodeViewController.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AWPasscodeViewController"
  s.version          = "1.2.0"
  s.summary          = "A simple iOS 7/8 style Passcode Lock Screen"
  s.description      = <<-DESC
                       Simple to use iOS 7/8 style Passcode with theming support and auto-layout. Compatible from iOS 7 and onwards.
                       DESC
  s.homepage         = "https://github.com/leetal/AWPasscodeViewController"
  s.license          = 'MIT'
  s.author           = { "Alexander Widerberg" => "widerbergaren@gmail.com" }
  s.source           = { :git => "https://github.com/leetal/AWPasscodeViewController.git", :tag => s.version.to_s }
  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.source_files     = 'Pod/Classes'
  s.ios.frameworks   = 'UIKit' , 'QuartzCore', 'Foundation', 'CoreGraphics'
#  s.resource_bundles = {
#    'AWPasscodeBundle' => ['Pod/Assets/*.png']
#  }
end
