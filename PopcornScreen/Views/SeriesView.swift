//
//  SeriesView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct SeriesView: View {
    @StateObject private var viewModel = TVShowViewModel()
//    @EnvironmentObject var favoriteManager: FavoriteSeriesManager

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    ProgressView("Loading series…")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if viewModel.filteredTVShows.isEmpty {
                    ContentUnavailableView(
                        "No TV series",
                        systemImage: "tv",
                        description: Text("Try a different search or refresh.")
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(viewModel.filteredTVShows) { show in
                        HStack {Text(show.name)
                            Spacer()
//                            Button(action: {
//                                if favoriteManager.isFavorite(show) {
//                                    favoriteManager.remove(serial: show)
//                                } else {
//                                    favoriteManager.add(serial: show)
//                                }
//                            }, label: {
//                                Image(systemName: favoriteManager.isFavorite(show)
//                                      ? "heart.fill" : "heart")
//                                .foregroundColor(.red)
//                            })
//                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Series")
            .searchable(text: $viewModel.searchText)
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
//        .environmentObject(FavoriteSeriesManager())
}
