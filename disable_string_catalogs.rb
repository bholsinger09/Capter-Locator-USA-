#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

puts "🔧 Disabling Swift String Catalogs..."

target.build_configurations.each do |config|
  # Disable string catalogs which generate .stringsdata files
  config.build_settings['SWIFT_EMIT_LOC_STRINGS'] = 'NO'
  puts "  ✅ Set SWIFT_EMIT_LOC_STRINGS = NO for #{config.name}"
end

project.save
puts "\n🎉 Build settings updated. Try building now."
