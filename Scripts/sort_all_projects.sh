#!/bin/sh

#  sort_all_projects.sh
#  wxm-ios
#
#  Created by Pantelis Giazitsis on 19/9/23.
#  

# Sort wxm-ios.xcodeproj
perl ./Scripts/sort-Xcode-project-file ./wxm-ios.xcodeproj/project.pbxproj
# Sort Toolkit.xcodeproj
perl ./Scripts/sort-Xcode-project-file ./wxm-ios/Toolkit/Toolkit.xcodeproj/project.pbxproj
# Sort DataLayer.xcodeproj
perl ./Scripts/sort-Xcode-project-file ./wxm-ios/DataLayer/DataLayer.xcodeproj/project.pbxproj
# Sort DomainLayer.xcodeproj
perl ./Scripts/sort-Xcode-project-file ./wxm-ios/DomainLayer/DomainLayer.xcodeproj/project.pbxproj
