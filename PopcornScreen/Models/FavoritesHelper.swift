//
//  FavoritesHelper.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 28/08/2025.
//

import Foundation
import CoreData

enum FavoritesHelper {
    static func addToFavorites(title: String, id: Int64, context: NSManagedObjectContext) {
        let favorite = FavoriteMovie(context: context)
        favorite.title = title
        favorite.id = id
        do {
            try context.save()
        } catch {
            print("Failed to save favorite movie: \(error)")
        }
    }

    static func removeFromFavorites(_ favorite: FavoriteMovie, context: NSManagedObjectContext) {
        context.delete(favorite)
        do {
            try context.save()
        } catch {
            print("Failed to save favorite movie: \(error)")
        }
    }
}
