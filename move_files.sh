#!/bin/bash

# Move Free Speech feature files to correct Xcode project location

cd /Users/benh/Documents/SwiftChapterUSA_finder

echo "Moving files to correct location..."

# Move model files
mv Models/Incident.swift SwiftChapterUSA_finder/SwiftChapterUSA_finder/Models/
echo "✅ Moved Incident.swift"

# Move protocol files
mv Protocols/IncidentManagerProtocol.swift SwiftChapterUSA_finder/SwiftChapterUSA_finder/Protocols/
echo "✅ Moved IncidentManagerProtocol.swift"

# Move service files
mv Services/IncidentManager.swift SwiftChapterUSA_finder/SwiftChapterUSA_finder/Services/
echo "✅ Moved IncidentManager.swift"

# Move viewmodel files
mv ViewModels/IncidentReporterViewModel.swift SwiftChapterUSA_finder/SwiftChapterUSA_finder/ViewModels/
mv ViewModels/IncidentsMapViewModel.swift SwiftChapterUSA_finder/SwiftChapterUSA_finder/ViewModels/
echo "✅ Moved ViewModel files"

# Move view files
mv Views/FreeSpeechHubView.swift SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/
mv Views/ReportIncidentView.swift SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/
mv Views/IncidentListView.swift SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/
mv Views/IncidentsMapView.swift SwiftChapterUSA_finder/SwiftChapterUSA_finder/Views/
echo "✅ Moved View files"

echo ""
echo "🎉 All files moved successfully!"
echo "Now update the Xcode project references..."
