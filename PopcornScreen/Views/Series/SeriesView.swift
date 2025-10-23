//
//  SeriesView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct SeriesView: View {
    @StateObject var viewModel = SeriesViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchFieldView(
                    searchText: $viewModel.searchText,
                    placeholder: "Search series",
                    onSubmit: {
                        viewModel.searchSeries(query: viewModel.searchText)
                    },
                    onTextChange: { text in
                        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            viewModel.searchSeries(query: "")
                        }
                    }
                )
                .padding(.vertical, .spacing(.s))

                HStack {
                    Text("Series")
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
                            // Ponowne pobranie oryginalnej listy po Reset
                            viewModel.loadPopularSeries()
                        }
                    )
                }
                .padding(.vertical, .spacing(.s))

                GenresView(viewModel: viewModel)

                ScrollView {
                    if viewModel.isLoading {
                        ProgressView("Loading series…")
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if viewModel.filteredSeries.isEmpty {
                        ContentUnavailableView(
                            "No series",
                            systemImage: "tv",
                            description: Text("Try a different search or refresh.")
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        VStack(spacing:.spacing(.xs)) {
                            ForEach(viewModel.filteredSeries) { show in
                                NavigationLink {
                                    MediaDetailsView(item: show)
                                        .navigationTitle(show.name)
                                } label: {
                                    MediaRowView(
                                        title: show.name,
                                        subtitle: (show.firstAirYear?.isEmpty ?? true) ? nil : show.firstAirYear,
                                        rating: show.voteAverage,
                                        posterURL: show.posterURL,
                                        genres: viewModel.genres(for: show).map(\.name)
                                    )
                                }
                            }
                        }
                        .padding(.vertical, .spacing(.s))
                    }
                }
                .refreshable {
                    await viewModel.loadGenres()
                    viewModel.loadPopularSeries()
                }
            }
            .padding(.spacing(.s))
        }
        .task {
            await viewModel.loadGenres()
            viewModel.loadPopularSeries()
        }
    }
}

#Preview {
    SeriesView()
}
