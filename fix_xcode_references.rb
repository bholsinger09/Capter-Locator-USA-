#!/usr/bin/env ruby

# Script to fix Free Speech feature file references in Xcode project
# This removes old incorrect references and adds files with correct paths

require 'xcodeproj'

# Open the Xcode project
project_path = 'SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

puts "🔍 Finding and removing old file references..."

# Files to remove (old incorrect references)
files_to_remove = [
  'Incident.swift',
  'IncidentManagerProtocol.swift',
  'IncidentManager.swift',
  'IncidentReporterViewModel.swift',
  'IncidentsMapViewModel.swift',
  'FreeSpeechHubView.swift',
  'ReportIncidentView.swift',
  'IncidentListView.swift',
  'IncidentsMapView.swift'
]

# Remove old references from all groups
project.main_group.recursive_children.each do |item|
  if item.is_a?(Xcodeproj::Project::Object::PBXFileReference)
    if files_to_remove.include?(item.path)
      puts "🗑️  Removing old reference: #{item.path}"
      item.remove_from_project
    end
  end
end

puts "\n✅ Old references removed. Now adding files with correct paths...\n"

# Get or create groups
models_group = project.main_group.find_subpath('SwiftChapterUSA_finder/SwiftChapterUSA_finder/Models', true)
protocols_group = project.main_group.find_subpath('SwiftChapterUSA_finder/SwiftChapterUSA_finder/Protocols', true)
services_group = project.main_group.find_subpath('SwiftChapterUSA_finder/SwiftChapterUSA_finder/Services', true)
viewmodels_group = project.main_group.find_subpath('SwiftChapterUSA_finder/SwiftChapterUSA_finder/ViewModels', true)
views_group = project.main_group.find_subpath('SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views', true)

# Define files to add with CORRECT paths
files_to_add = [
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/Models/Incident.swift', group: models_group, name: 'Incident.swift' },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/Protocols/IncidentManagerProtocol.swift', group: protocols_group, name: 'IncidentManagerProtocol.swift' },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/Services/IncidentManager.swift', group: services_group, name: 'IncidentManager.swift' },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/ViewModels/IncidentReporterViewModel.swift', group: viewmodels_group, name: 'IncidentReporterViewModel.swift' },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/ViewModels/IncidentsMapViewModel.swift', group: viewmodels_group, name: 'IncidentsMapViewModel.swift' },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/FreeSpeechHubView.swift', group: views_group, name: 'FreeSpeechHubView.swift' },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/ReportIncidentView.swift', group: views_group, name: 'ReportIncidentView.swift' },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/IncidentListView.swift', group: views_group, name: 'IncidentListView.swift' },
  { path: 'SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/IncidentsMapView.swift', group: views_group, name: 'IncidentsMapView.swift' }
]

files_to_add.each do |file_info|
  file_path = file_info[:path]
  group = file_info[:group]
  file_name = file_info[:name]
  
  # Check if file exists
  unless File.exist?(file_path)
    puts "⚠️  File not found: #{file_path}"
    next
  end
  
  # Add file reference to group
  file_ref = group.new_reference(file_path)
  file_ref.name = file_name
  
  # Add to main target
  target.add_file_references([file_ref])
  puts "✅ Added #{file_name}"
end

# Save the project
project.save
puts "\n🎉 Done! Project file updated with correct paths."
puts "\nNext steps:"
puts "1. Open Xcode (it may ask to reload the project)"
puts "2. Clean build folder (Cmd+Shift+K)"
puts "3. Build (Cmd+B)"
puts "4. Run (Cmd+R)"
puts "\n🚀 The Free Speech tab should now appear!"
