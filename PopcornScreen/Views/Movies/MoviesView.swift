//  MoviesView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct MoviesView: View {
    @StateObject var viewModel = MoviesViewModel()

    private static let posterSize = CGSize(width: 94, height: 146)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchFieldView(searchText: $viewModel.searchText)

                HStack {
                    Text("Movies")
                        .typography(.header1)
                        .padding(16)

                    Spacer()

                    SortView(viewModel: viewModel)
                        .padding(16)
                }

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
                        VStack(spacing: 12) {
                            ForEach(viewModel.filteredMovies) { movie in
                                NavigationLink {
                                    MovieDetailsView()
                                        .navigationTitle(movie.title)
                                } label: {
                                    MovieRowView(viewModel: viewModel, movie: movie)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
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
