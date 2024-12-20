//
//  Test_iOS_AppApp.swift
//  Test iOS App
//
//  Created by Jason Christopher on 12/19/24.
//

import SwiftUI

@main
struct Test_iOS_AppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
