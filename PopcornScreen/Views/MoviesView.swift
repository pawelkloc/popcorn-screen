//
//  MoviesView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct MoviesView: View {
    @StateObject private var viewModel = MoviesViewModel()

    var body: some View {
        NavigationStack {



            List(viewModel.movies) { movie in
                Text(movie.title)
            }
            .navigationTitle("Movies")
            .task {
                viewModel.loadPopularMovies()
            }
        }
    }
}

#Preview {
    MoviesView()
}
