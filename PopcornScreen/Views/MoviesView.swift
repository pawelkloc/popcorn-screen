//  MoviesView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct MoviesView: View {
    @StateObject private var viewModel = MoviesViewModel()
    @State private var selectedGenres: Set<String> = []

    private static let posterSize = CGSize(width: 94, height: 146)

    private func dotDecimal(_ value: Double) -> String {
        // Use C-style formatting which guarantees a dot as the decimal separator with the default C locale
        return String(format: "%.1f", value)
    }

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
                                // TODO: Push to a MovieDetailsView(movie:) when available
                                MovieBlockView(movie: movie)
                                    .navigationTitle(movie.title)
                            } label: {
                                MovieBlockView(movie: movie)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Movies")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Sort by") {
                            Button {
                                viewModel.applySort(.alphabeticalAscending)
                            } label: {
                                Label("Alphabetical order", image: "ascending")
                            }
                            Button {
                                viewModel.applySort(.alphabeticalDescending)
                            } label: {
                                Label("Alphabetical order", image: "descending")
                            }
                            Button {
                                viewModel.applySort(.releaseDateAscending)
                            } label: {
                                Label("Release date", image: "ascending")
                            }
                            Button {
                                viewModel.applySort(.releaseDateDescending)
                            } label: {
                                Label("Release date", image: "descending")
                            }
                            Button {
                                viewModel.applySort(.ratingAscending)
                            } label: {
                                Label("Rating", image: "ascending")
                            }
                            Button {
                                viewModel.applySort(.ratingDescending)
                            } label: {
                                Label("Rating", image: "descending")
                            }
                        }
                        if viewModel.currentSort != nil {
                            Section {
                                Button(role: .destructive) { viewModel.applySort(nil) } label: {
                                    Label("Clear sort", systemImage: "xmark.circle")
                                }
                            }
                        }
                    } label: {
                        Label("Sort", image: "sort-default")
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search for movies...")
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
