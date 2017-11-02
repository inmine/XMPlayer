#
#  Be sure to run `pod spec lint XMPlayer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
s.name         = 'XMPlayer'
s.version      = '0.0.1'
s.summary      = 'A short description of XMPlayer.'
s.homepage     = 'https://github.com/inmine/XMPlayer'
s.license      = 'MIT'
s.authors      = {'inmine' => '287916135@qq.com'}
s.platform     = :ios, '8.0'
s.source       = {:git => 'https://github.com/inmine/XMPlayer.git', :tag => s.version}
s.source_files = 'XMPlayer/**/*'
s.requires_arc = true
end


