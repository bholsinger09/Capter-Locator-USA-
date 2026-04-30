#!/usr/bin/env ruby

# Remove duplicate file references from Xcode project

require 'xcodeproj'

project_path = 'SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

puts "🔍 Finding and removing duplicate file references...\n"

# Get the source build phase
sources_phase = target.source_build_phase

# Group files by name
files_by_name = {}
sources_phase.files.each do |build_file|
  next unless build_file.file_ref
  name = build_file.file_ref.display_name
  files_by_name[name] ||= []
  files_by_name[name] << build_file
end

# Remove duplicates
duplicate_count = 0
files_by_name.each do |name, build_files|
  if build_files.length > 1
    puts "⚠️  Found #{build_files.length} copies of #{name}"
    # Keep first one, remove the rest
    build_files[1..-1].each do |duplicate|
      sources_phase.files.delete(duplicate)
      duplicate_count += 1
      puts "   🗑️  Removed duplicate"
    end
  end
end

project.save

if duplicate_count > 0
  puts "\n✅ Removed #{duplicate_count} duplicate file references!"
  puts "\nNow rebuild in Xcode or run:"
  puts "  xcodebuild clean build"
else
  puts "\n✅ No duplicates found!"
end
