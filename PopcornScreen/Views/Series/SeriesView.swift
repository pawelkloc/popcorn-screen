//
//  SeriesView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct SeriesView: View {
    @StateObject private var viewModel = TVShowViewModel()

    private static let posterSize = CGSize(width: 94, height: 146)

    private func dotDecimal(_ value: Double) -> String {
        // en_US_POSIX guarantee "dot" as separator in float numbers
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.1f", value)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Loading TV Series…")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if viewModel.filteredTVShows.isEmpty {
                    ContentUnavailableView(
                        "No series found.",
                        systemImage: "film",
                        description: Text("Try a different search or refresh.")
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    LazyVStack(spacing: 12, pinnedViews: []) {
                        ForEach(viewModel.filteredTVShows) { show in
                            NavigationLink {
                                // TODO: Push to a SeriesDetailsView(movie:) when available
                                SeriesBlockView(show: show)
                                    .navigationTitle(show.name)
                            } label: {
                                SeriesBlockView(show: show)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Series")
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
                                HStack {
                                    Text("Release date")
                                    Image("descending")
                                }
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
            .searchable(text: $viewModel.searchText, prompt: "Search for series...")
            .onSubmit(of: .search) {
                viewModel.searchTV(query: viewModel.searchText)
            }
            .task {
                viewModel.loadPopularTV()
            }
        }
    }
}

#Preview {
    SeriesView()
}
