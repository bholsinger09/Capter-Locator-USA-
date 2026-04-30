#!/usr/bin/env ruby

# Script to add Free Speech feature files to Xcode project
# Usage: ruby add_files_to_xcode.rb

require 'xcodeproj'

# Open the Xcode project
project_path = 'SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Get or create groups
models_group = project.main_group['Models'] || project.main_group.new_group('Models')
protocols_group = project.main_group['Protocols'] || project.main_group.new_group('Protocols')
services_group = project.main_group['Services'] || project.main_group.new_group('Services')
viewmodels_group = project.main_group['ViewModels'] || project.main_group.new_group('ViewModels')
views_group = project.main_group['Views'] || project.main_group.new_group('Views')
tests_group = project.main_group['Tests'] || project.main_group.new_group('Tests')

# Define files to add (using correct paths within Xcode project directory)
files_to_add = [
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/Models/Incident.swift', group: models_group },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/Protocols/IncidentManagerProtocol.swift', group: protocols_group },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/Services/IncidentManager.swift', group: services_group },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/ViewModels/IncidentReporterViewModel.swift', group: viewmodels_group },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/ViewModels/IncidentsMapViewModel.swift', group: viewmodels_group },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/FreeSpeechHubView.swift', group: views_group },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/ReportIncidentView.swift', group: views_group },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/IncidentListView.swift', group: views_group },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/IncidentsMapView.swift', group: views_group },
  { path: 'Tests/IncidentManagerTests.swift', group: tests_group, test: true },
  { path: 'Tests/IncidentReporterViewModelTests.swift', group: tests_group, test: true },
  { path: 'Tests/IncidentsMapViewModelTests.swift', group: tests_group, test: true }
]

puts "Adding files to Xcode project..."

files_to_add.each do |file_info|
  file_path = file_info[:path]
  group = file_info[:group]
  is_test = file_info[:test] || false
  
  # Check if file exists
  unless File.exist?(file_path)
    puts "⚠️  Skipping #{file_path} (file not found)"
    next
  end
  
  # Check if file is already in project
  if group.files.any? { |f| f.path == File.basename(file_path) }
    puts "⏭️  Skipping #{file_path} (already in project)"
    next
  end
  
  # Add file reference to group
  file_ref = group.new_file(file_path)
  
  # Add to appropriate target
  if is_test
    test_target = project.targets.find { |t| t.name.include?('Test') }
    if test_target
      test_target.add_file_references([file_ref])
      puts "✅ Added #{file_path} to test target"
    else
      puts "⚠️  No test target found for #{file_path}"
    end
  else
    target.add_file_references([file_ref])
    puts "✅ Added #{file_path}"
  end
end

# Save the project
project.save
puts "\n🎉 Done! Project file updated successfully."
puts "Next steps:"
puts "1. Open Xcode"
puts "2. Clean build folder (Cmd+Shift+K)"
puts "3. Build (Cmd+B)"
puts "4. Run (Cmd+R)"
puts "\nThe Free Speech tab should now appear! 🚀"
