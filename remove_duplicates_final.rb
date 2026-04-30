#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'SwiftChapterUSA_finder/SwiftChapterUSA_finder.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets.first
puts "Target: #{target.name}"

# Files that are duplicated
duplicated_files = [
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

duplicated_files.each do |filename|
  # Find all build files with this filename
  build_files = target.source_build_phase.files.select do |bf|
    bf.file_ref && bf.file_ref.path && bf.file_ref.path.end_with?(filename)
  end
  
  puts "\n#{filename}: Found #{build_files.count} references"
  
  if build_files.count > 1
    # Keep the first one, remove the rest
    build_files[1..-1].each do |duplicate|
      puts "  Removing duplicate: #{duplicate.file_ref.real_path}"
      target.source_build_phase.remove_build_file(duplicate)
    end
  end
end

project.save
puts "\nDuplicates removed successfully!"
