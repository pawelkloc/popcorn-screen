//
//  FavoriteSeriesManager.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 27/08/2025.
//

import Foundation

@MainActor
class FavoriteSeriesManager: ObservableObject {
    @Published private(set) var favoriteSeries: [TVShow] = []

    func add(serial: TVShow) {
        guard !favoriteSeries.contains(where: { $0.id == serial.id }) else { return }
        favoriteSeries.append(serial)
    }

    func remove(serial: TVShow) {
        favoriteSeries.removeAll { $0.id == serial.id }
    }

    func isFavorite(_ serial: TVShow) -> Bool {
        favoriteSeries.contains(where: { $0.id == serial.id })
    }
}
