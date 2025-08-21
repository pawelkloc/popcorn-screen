//
//  MoviesView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct MoviesView: View {
    @StateObject private var viewModel = MoviesViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {

            List(viewModel.movies) { movie in
                Text(movie.title)
            }
            .navigationTitle("Movies")
            .searchable(text: $searchText, prompt: "Search movies")
            .onSubmit(of: .search, {
                viewModel.searchMovies(query: searchText)
            })
            .task {
                viewModel.loadPopularMovies()
            }
        }
    }
}

#Preview {
    MoviesView()
}
