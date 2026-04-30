#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets.first
puts "Target: #{target.name}"
puts "\nAll build files in Compile Sources phase:"

# Group by display name to find duplicates
files_by_name = {}

target.source_build_phase.files.each do |bf|
  if bf.file_ref && bf.file_ref.display_name
    name = bf.file_ref.display_name
    files_by_name[name] ||= []
    files_by_name[name] << bf
  end
end

# Show duplicates
puts "\nDuplicates found:"
duplicates_found = false

files_by_name.each do |name, build_files|
  if build_files.count > 1
    duplicates_found = true
    puts "\n#{name}: #{build_files.count} references"
    build_files.each_with_index do |bf, idx|
      puts "  [#{idx}] #{bf.file_ref.real_path || bf.file_ref.path}"
    end
    
    # Remove all but the first
    puts "  Removing #{build_files.count - 1} duplicate(s)..."
    build_files[1..-1].each do |duplicate|
      target.source_build_phase.remove_build_file(duplicate)
    end
  end
end

if duplicates_found
  project.save
  puts "\nDuplicates removed successfully!"
else
  puts "\nNo duplicates found!"
end
