#!/usr/bin/env ruby

require 'xcodeproj'

project_path = '/Users/benh/Documents/SwiftChapterUSA_finder/SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

puts "🔧 Removing duplicate file references from Compile Sources...\n"

# Get the source build phase
source_build_phase = target.source_build_phase

# Track files we've seen
seen_files = {}
duplicates_removed = 0

# Iterate through all build files
source_build_phase.files.to_a.each do |build_file|
  next unless build_file.file_ref
  
  file_path = build_file.file_ref.real_path.to_s rescue nil
  next unless file_path
  
  if seen_files[file_path]
    # This is a duplicate - remove it
    puts "  🗑️  Removing duplicate: #{File.basename(file_path)}"
    source_build_phase.files.delete(build_file)
    duplicates_removed += 1
  else
    # First time seeing this file
    seen_files[file_path] = build_file
  end
end

project.save

if duplicates_removed > 0
  puts "\n✅ Removed #{duplicates_removed} duplicate file reference(s)"
else
  puts "\n✅ No duplicates found"
end
