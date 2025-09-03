//  SavedViewModel.swift
//  PopcornScreen

import Foundation
import CoreData

@MainActor
class SavedViewModel: ObservableObject {
    @Published var favorites: [FavoriteMovie] = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchFavorites()
    }

    func fetchFavorites() {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FavoriteMovie.title, ascending: true)]
        do {
            favorites = try context.fetch(request)
        } catch {
            print("Error fetching favorites: \(error)")
        }
    }

    func addToFavorites(title: String, id: Int64) {
        let favorite = FavoriteMovie(context: context)
        favorite.title = title
        favorite.id = id
        saveContext()
    }

    func removeFromFavorites(movieID: Int64) {
        if let favorite = favorites.first(where: { $0.id == movieID }) {
            context.delete(favorite)
            saveContext()
        }
    }

    private func saveContext() {
        do {
            try context.save()
            fetchFavorites()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    func isFavorite(_ movieID: Int64) -> Bool {
        favorites.contains(where: { $0.id == movieID })
    }
}
