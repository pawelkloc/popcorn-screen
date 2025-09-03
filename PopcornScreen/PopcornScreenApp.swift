//
//  PopcornScreenApp.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 04/08/2025.
//

import SwiftUI

@main
struct PopcornScreenApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
