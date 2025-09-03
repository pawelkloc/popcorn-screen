//
//  SavedView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 13/08/2025.
//

import SwiftUI

struct SavedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: FavoriteMovie.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteMovie.title, ascending: true)]
    ) var favorites: FetchedResults<FavoriteMovie>

    var body: some View {
        NavigationStack {
            List(favorites) { movie in
                Text(movie.title ?? "No Title")
            }
            .navigationTitle("Saved")
        }

    }
}

#Preview {
    SavedView()
}
