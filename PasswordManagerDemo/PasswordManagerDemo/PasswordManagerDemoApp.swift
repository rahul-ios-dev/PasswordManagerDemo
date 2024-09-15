//
//  PasswordManagerDemoApp.swift
//  PasswordManagerDemo
//
//  Created by Rahul Acharya on 15/09/24.
//

import SwiftUI

@main
struct TravelDestinationApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeScreenView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
