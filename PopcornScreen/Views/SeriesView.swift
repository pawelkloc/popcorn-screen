//
//  SeriesView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct SeriesView: View {
    @StateObject private var viewModel = TVShowViewModel()

    var body: some View {
        NavigationStack {

            List(viewModel.filteredTVShows) { show in
                Text(show.name)
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
}
