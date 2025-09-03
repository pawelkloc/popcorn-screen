//  MoviesView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct MoviesView: View {
    @StateObject private var viewModel = MoviesViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var savedViewModel = SavedViewModel(
        context: PersistenceController.shared.container.viewContext
    )

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
                                if savedViewModel.isFavorite(Int64(movie.id)) {
                                    savedViewModel.removeFromFavorites(movieID: Int64(movie.id))
                                } else {
                                    savedViewModel.addToFavorites(title: movie.title, id: Int64(movie.id))
                                }
                            }, label: {
                                Image(systemName: savedViewModel.isFavorite(Int64(movie.id))
                                    ? "star.fill"
                                    : "star"
                                )
                                .foregroundColor(.yellow)
                            })
                            .buttonStyle(PlainButtonStyle())
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
}
