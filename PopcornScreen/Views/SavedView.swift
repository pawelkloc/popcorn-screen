//
//  SavedView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct SavedView: View {
    @EnvironmentObject var favoriteMoviesManager: FavoriteMoviesManager
//    @EnvironmentObject var favoritesSeriesManager: FavoriteSeriesManager

    var body: some View {
        NavigationStack {
            Group {
                if favoriteMoviesManager.favoriteMovies.isEmpty
//                    || favoritesSeriesManager.favoriteSeries.isEmpty
                {
                    ContentUnavailableView(
                        "No favorites",
                        systemImage: "heart",
                        description: Text("Add movies or series to your favorites to see them here.")
                    ).frame(maxWidth: .infinity, alignment: .center)
                } else {
                    List {
                        ForEach(favoriteMoviesManager.favoriteMovies) { movie in
                            Text(movie.title)
                        }
//                        ForEach(favoritesSeriesManager.favoriteSeries) { series in
//                            Text(series.name)
//                        }
                    }
                }
            }
            .navigationTitle("Saved")
        }
    }
}

#Preview {
    SavedView()
        .environmentObject(FavoriteMoviesManager())
//        .environmentObject(FavoriteSeriesManager())
}
