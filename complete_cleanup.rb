#!/usr/bin/env ruby

# Complete cleanup of Xcode project - remove all Incident/FreeSpeech files and re-add correctly

require 'xcodeproj'

project_path = '/Users/benh/Documents/SwiftChapterUSA_finder/SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

puts "🧹 Complete cleanup of Free Speech feature files...\n"

# Step 1: Remove ALL references to these files from everywhere
file_names_to_remove = ['Incident', 'IncidentManager', 'IncidentReporter', 'IncidentsMap', 'FreeSpeech', 'Report']

puts "Step 1: Removing all old file references..."
project.main_group.recursive_children.select { |item| 
  item.is_a?(Xcodeproj::Project::Object::PBXFileReference) 
}.each do |file_ref|
  if file_names_to_remove.any? { |name| file_ref.display_name.to_s.include?(name) }
    puts "  🗑️  Removing: #{file_ref.display_name}"
    file_ref.remove_from_project
  end
end

# Step 2: Remove from build phases
puts "\nStep 2: Cleaning build phases..."
[target.source_build_phase, target.resources_build_phase].compact.each do |phase|
  phase.files.to_a.each do |build_file|
    begin
      if build_file.file_ref.nil? || build_file.file_ref.missing?
        phase.files.delete(build_file)
        puts "  🗑️  Removed orphaned build file"
      end
    rescue
      # Ignore errors checking missing files
    end
  end
end

puts "\n Step 3: Adding files with correct paths..."

# Base directory where the project file is located
project_dir = File.dirname(project_path)

# Find groups
models_group = project.main_group.recursive_children.find { |c| c.is_a?(Xcodeproj::Project::Object::PBXGroup) && c.display_name == 'Models' }
protocols_group = project.main_group.recursive_children.find { |c| c.is_a?(Xcodeproj::Project::Object::PBXGroup) && c.display_name == 'Protocols' }
services_group = project.main_group.recursive_children.find { |c| c.is_a?(Xcodeproj::Project::Object::PBXGroup) && c.display_name == 'Services' }
viewmodels_group = project.main_group.recursive_children.find { |c| c.is_a?(Xcodeproj::Project::Object::PBXGroup) && c.display_name == 'ViewModels' }
views_group = project.main_group.recursive_children.find { |c| c.is_a?(Xcodeproj::Project::Object::PBXGroup) && c.display_name == 'Views' }

# Add files ONE TIME ONLY with correct relative paths (from project root)
[
  ['SwiftChapterUSA_finder/Models/Incident.swift', models_group, 'Incident.swift'],
  ['SwiftChapterUSA_finder/Protocols/IncidentManagerProtocol.swift', protocols_group, 'IncidentManagerProtocol.swift'],
  ['SwiftChapterUSA_finder/Services/IncidentManager.swift', services_group, 'IncidentManager.swift'],
  ['SwiftChapterUSA_finder/ViewModels/IncidentReporterViewModel.swift', viewmodels_group, 'IncidentReporterViewModel.swift'],
  ['SwiftChapterUSA_finder/ViewModels/IncidentsMapViewModel.swift', viewmodels_group, 'IncidentsMapViewModel.swift'],
  ['SwiftChapterUSA_finder/Views/FreeSpeechHubView.swift', views_group, 'FreeSpeechHubView.swift'],
  ['SwiftChapterUSA_finder/Views/ReportIncidentView.swift', views_group, 'ReportIncidentView.swift'],
  ['SwiftChapterUSA_finder/Views/IncidentListView.swift', views_group, 'IncidentListView.swift'],
  ['SwiftChapterUSA_finder/Views/IncidentsMapView.swift', views_group, 'IncidentsMapView.swift']
].each do |path, group, display_name|
  # Use absolute path to check if file exists
  full_path = File.join(project_dir, path)
  
  if File.exist?(full_path) && group
    # Check if it already exists in the group
    existing = group.files.find { |f| f.display_name == display_name }
    
    if existing
      puts "  ⏭️  Already exists: #{display_name}"
    else
      file_ref = group.new_reference(path)
      file_ref.name = display_name
      target.add_file_references([file_ref])
      puts "  ✅ Added: #{display_name}"
    end
  else
    puts "  ⚠️  Skipped: #{display_name} (#{File.exist?(full_path) ? 'group missing' : 'file missing at: ' + full_path})"
  end
end

project.save
puts "\n🎉 Cleanup complete! Try building now."
