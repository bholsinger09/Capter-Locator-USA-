#!/usr/bin/env ruby

# Simpler script to fix file references

require 'xcodeproj'

project_path = 'SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

puts "🔍 Cleaning up old references..."

# Remove any existing references to these files
project.main_group.recursive_children.each do |item|
  if item.is_a?(Xcodeproj::Project::Object::PBXFileReference) && item.path
    if item.path.include?('Incident') || item.path.include?('FreeSpeech')
      puts "🗑️  Removing: #{item.path}"
      item.remove_from_project
    end
  end
end

puts "\n✅ Adding files with correct paths...\n"

# Find existing groups by searching
def find_group(main_group, name)
  main_group.recursive_children.find { |child| child.is_a?(Xcodeproj::Project::Object::PBXGroup) && child.display_name == name }
end

models_group = find_group(project.main_group, 'Models')
protocols_group = find_group(project.main_group, 'Protocols')
services_group = find_group(project.main_group, 'Services')
viewmodels_group = find_group(project.main_group, 'ViewModels')
views_group = find_group(project.main_group, 'Views')

# Add files
[
  ['SwiftChapterUSA_finder/SwiftChapterUSA_finder/Models/Incident.swift', models_group],
  ['SwiftChapterUSA_finder/SwiftChapterUSA_finder/Protocols/IncidentManagerProtocol.swift', protocols_group],
  ['SwiftChapterUSA_finder/SwiftChapterUSA_finder/Services/IncidentManager.swift', services_group],
  ['SwiftChapterUSA_finder/SwiftChapterUSA_finder/ViewModels/IncidentReporterViewModel.swift', viewmodels_group],
  ['SwiftChapterUSA_finder/SwiftChapterUSA_finder/ViewModels/IncidentsMapViewModel.swift', viewmodels_group],
  ['SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/FreeSpeechHubView.swift', views_group],
  ['SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/ReportIncidentView.swift', views_group],
  ['SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/IncidentListView.swift', views_group],
  ['SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/IncidentsMapView.swift', views_group]
].each do |path, group|
  if File.exist?(path) && group
    file_ref = group.new_file(path)
    target.add_file_references([file_ref])
    puts "✅ Added #{File.basename(path)}"
  else
    puts "⚠️  Skipped #{File.basename(path)} - #{'file missing' unless File.exist?(path)}#{'group missing' unless group}"
  end
end

project.save
puts "\n🎉 Project updated! Now build in Xcode."
