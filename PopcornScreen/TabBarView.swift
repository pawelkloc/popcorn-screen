//  ContentView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 04/08/2025.
//

import SwiftUI

enum Tab: Hashable {
    case movies, series, search, saved, settings
}

struct TabBarView: View {
    @State private var selection: Tab = .movies
    var body: some View {
        TabView(selection: $selection) {
            MoviesView()
                .tabItem {
                    Label("Movies", image: "movies")
                }
                .tag(Tab.movies)

            SeriesView()
                .tabItem {
                    Label("Series", image: "series")
                }
                .tag(Tab.series)

            SearchView()
                .tabItem {
                    Label("Search", image: "search")
                }
                .tag(Tab.search)

            SavedView()
                .tabItem {
                    Label("Saved", image: "favorite")
                }
                .tag(Tab.saved)

            SettingsView()
                .tabItem {
                    Label("Settings", image: "settings")
                }
                .tag(Tab.settings)

        }
        .tint(.primary)
    }
}

#Preview {
    TabBarView()
}
