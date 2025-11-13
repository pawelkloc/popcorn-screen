//
//  SearchView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

enum SearchSegment: String, CaseIterable, Identifiable {
    case movies = "Movies"
    case series = "Series"
    var id: Self { self }
}

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var selected: SearchSegment = .movies

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Category", selection: $selected) {
                    ForEach(SearchSegment.allCases) { seg in
                        Text(seg.rawValue).tag(seg)
                    }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])

                Group {
                    if viewModel.isSearching {
                        ProgressView("Searching…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.query.isEmpty {
                        ContentUnavailableView(
                            "Search",
                            systemImage: "magnifyingglass",
                            description: Text("Type a title to search")
                        )
                    } else {
                        if selected == .movies {
                            resultsList(movies: viewModel.movies, shows: [])
                        } else {
                            resultsList(movies: [], shows: viewModel.shows)
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .toolbar {
                if !viewModel.query.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear") { viewModel.clearResults() }
                    }
                }
            }
        }
        .searchable(
            text: $viewModel.query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Movies or Series…"
        )
    }

    @ViewBuilder
    private func resultsList(movies: [Movie], shows: [TVShow]) -> some View {
        if movies.isEmpty && shows.isEmpty {
            ContentUnavailableView(
                "No results",
                systemImage: "questionmark.folder",
                description: Text("Try a different title")
            )
        } else {
            List {
                if !movies.isEmpty {
                    ForEach(movies) { movie in
                        Text(movie.title)
                    }
                }
                if !shows.isEmpty {
                    ForEach(shows) { show in
                        Text(show.name)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

#Preview {
    SearchView()
}
