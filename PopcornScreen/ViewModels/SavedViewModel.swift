//  SavedViewModel.swift
//  PopcornScreen

import Foundation
import CoreData

@MainActor
class SavedViewModel: ObservableObject {
    @Published var favorites: [FavoriteMovie] = []

}
