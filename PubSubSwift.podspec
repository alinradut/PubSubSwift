#
# Be sure to run `pod lib lint PubSub.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PubSubSwift'
  s.version          = '0.3.0'
  s.summary          = 'A type-safe implementation Swift of PubSub/event hub/event bus that can be used as a replacement for the NotificationCenter'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A type-safe implementation Swift of PubSub/event hub/event bus that can be used as a replacement for the NotificationCenter.

Allows subscription based on receipts and observers.
                       DESC

  s.homepage         = 'https://github.com/alinradut/PubSubSwift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alin Radut' => '...' }
  # s.source           = { :git => 'https://github.com/alinradut/PubSubSwift.git', :tag => s.version.to_s }
  s.source           = { :git => 'https://github.com/alinradut/PubSubSwift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_versions        = '5.1'

  s.source_files = 'PubSub/Classes/**/*'
  
  # s.resource_bundles = {
  #   'PubSub' => ['PubSub/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
