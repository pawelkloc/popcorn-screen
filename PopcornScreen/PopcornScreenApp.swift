//
//  PopcornScreenApp.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 04/08/2025.
//

import SwiftUI

@main
struct PopcornScreenApp: App {
    @StateObject private var favoriteMoviesManager = FavoriteMoviesManager()
//    @StateObject private var favoriteSeriesManager = FavoriteSeriesManager()

    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(favoriteMoviesManager)
//                .environmentObject(favoriteSeriesManager)
        }
    }
}
