//
//  SeriesView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct SeriesView: View {
    @StateObject private var viewModel = TVShowViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {

            List(viewModel.shows) { show in
                Text(show.name)
            }
            .navigationTitle("Series")
            .searchable(text: $searchText)
            .onSubmit(of: .search) {
                viewModel.searchTV(query: searchText)
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
