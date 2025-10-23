//  MoviesView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct MoviesView: View {
    @StateObject var viewModel = MoviesViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchFieldView(
                    searchText: $viewModel.searchText,
                    placeholder: "Search movies",
                    onSubmit: {
                        viewModel.searchMovies(query: viewModel.searchText)
                    },
                    onTextChange: { text in
                        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            viewModel.searchMovies(query: "")
                        }
                    }
                )
                .padding(.vertical, .spacing(.s))

                HStack {
                    Text("Movies")
                        .typography(.header1)

                    Spacer()

                    SortView(
                        currentSort: $viewModel.currentSort,
                        onApply: {
                            viewModel.applySort(viewModel.currentSort)
                        },
                        onReset: {
                            viewModel.applySort(nil)
                        },
                        onReload: {
                            viewModel.loadPopularMovies()
                        }
                    )
                }
                .padding(.vertical, .spacing(.s))

                GenresView(viewModel: viewModel)

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
                        VStack(spacing: .spacing(.xs)) {
                            ForEach(viewModel.filteredMovies) { movie in
                                NavigationLink {
                                    MediaDetailsView(item: movie)
                                        .navigationTitle(movie.title)
                                } label: {
                                    MediaRowView(
                                        title: movie.title,
                                        subtitle: movie.releaseYear.isEmpty ? nil : movie.releaseYear,
                                        rating: movie.voteAverage,
                                        posterURL: movie.posterURL,
                                        genres: viewModel.genres(for: movie).map(\.name)
                                    )
                                }
                            }
                        }
                        .padding(.vertical, .spacing(.s))
                    }
                }
                .refreshable {
                    await viewModel.loadGenres()
                    viewModel.loadPopularMovies()
                }
            }
            .padding(.spacing(.s))
        }
        .task {
            await viewModel.loadGenres()
            viewModel.loadPopularMovies()
        }
    }
}

#Preview {
    MoviesView()
}
