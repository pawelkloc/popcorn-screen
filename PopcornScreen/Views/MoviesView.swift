//  MoviesView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct MoviesView: View {
    @StateObject private var viewModel = MoviesViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
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
                    LazyVStack(spacing: 12, pinnedViews: []) {
                        ForEach(viewModel.filteredMovies) { movie in
                            NavigationLink {
//                                MovieDetailsView(movie: movie)
                            } label: {
                                MovieBlockView(movie: movie)
                            }
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
