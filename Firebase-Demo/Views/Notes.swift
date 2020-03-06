//
//  Notes.swift
//  Firebase-Demo
//
//  Created by Margiett Gil on 3/3/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
/*
 1. you click on the project in xcode to get the bundle id and change the to your name.
 In xcode project go to info.plist
 It needs to be in the git ignore file. So need to push the file first and create git info
 Go to git hub
 New file .gitignore file and on the bottom type both files.
 .DS_Store
 GoogleService-Info.plist
 Go to termial
 Go to file
 Check the gitignore is there
 Right click on info plist already inside of xcode
 The add new files (the google plist file)
 Then go to terminal and follow instructions on firebase to download the pod
 Pod init - creates a pod file
  ls   -should see Podfile
 Add :  under the line below
  # Pods for Firebase-Demo
  * pod 'Firebase/Analytics' * // this file is the one from the firebase instructions so double check that its correct
   Pod install  - to install the pod we just said to add from above
  Close the project
 Go to the folder for the file and open the Firebase-Demo.xcworkspace -this one has the pods inside the other project will not have the pods with it.
 */
