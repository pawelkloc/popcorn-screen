//
//  MoviesView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct MoviesView: View {
    @StateObject private var viewModel = MoviesViewModel()
    @EnvironmentObject var favoriteManager: FavoriteMoviesManager

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    ProgressView("Loading films…")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if viewModel.filteredMovies.isEmpty {
                    ContentUnavailableView(
                        "No movies",
                        systemImage: "film",
                        description: Text("Try a different search or refresh.")
                    )
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(viewModel.filteredMovies) { movie in
                        HStack {
                            Text(movie.title)
                            Spacer()
                            Button(action: {
                                if favoriteManager.isFavorite(movie) {
                                    favoriteManager.remove(movie: movie)
                                } else {
                                    favoriteManager.add(movie: movie)
                                }
                            }, label: {
                                Image(systemName: favoriteManager.isFavorite(movie) ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                            })
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Movies")
            .searchable(text: $viewModel.searchText)
            .onSubmit(of: .search) {
                viewModel.searchMovies(query: viewModel.searchText)
            }
            .task {
                viewModel.loadPopularMovies()
            }
        }
    }
}

#Preview {
    MoviesView()
        .environmentObject(FavoriteMoviesManager())
}
