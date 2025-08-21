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

            List(viewModel.shows) { show in
                Text(show.name)
            }
            .navigationTitle("Series")
            .task {
                viewModel.loadPopularTV()
            }
        }
    }
}

#Preview {
    SeriesView()
}
