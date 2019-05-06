#
# Be sure to run `pod lib lint TMSEntityDataSource.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TMSEntityDataSource'
  s.version          = '0.5.1'
  s.summary          = 'Makes displaying Core Data entities in Table, Collection, and Picker views much easier.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
`TMSEntityDataSource` takes care of fetching the Core Data entities you want to display in a table, collection, or picker view. It also does all of the work  in the respective data source protocols. For picker views it supplies an easy way to get an entity based on an index or an index based on an entity making the delegate methods easy to write.
                       DESC

  s.homepage         = 'https://github.com/theMikeSwan/TMSEntityDataSource'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'theMikeSwan' => 'michaelswan@mac.com' }
  s.source           = { :git => 'https://github.com/theMikeSwan/TMSEntityDataSource.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/_theMikeSwan'

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'TMSEntityDataSource/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TMSEntityDataSource' => ['TMSEntityDataSource/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
