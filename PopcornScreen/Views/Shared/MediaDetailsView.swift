//
//  MediaDetailsView.swift
//  PopcornScreen
//
//  Unified details screen for Movies & TV Series.
//

import SwiftUI

// MARK: - Protocol for items that can be shown on the details screen
protocol MediaDetailsDisplayable {
    var detailsTitle: String { get }
    var detailsSubtitle: String? { get }   // year or similar
    var overview: String { get }
    var posterURL: URL? { get }
    var voteAverage: Double? { get }
}

// MARK: - Conformances
extension Movie: MediaDetailsDisplayable {
    var detailsTitle: String { title }
    var detailsSubtitle: String? { releaseYear.isEmpty ? nil : releaseYear }
}

extension TVShow: MediaDetailsDisplayable {
    var detailsTitle: String { name }
    var detailsSubtitle: String? {
        if let year = firstAirYear, !year.isEmpty {
            return year
        } else {
            return nil
        }
    }
}

// MARK: - Unified View
struct MediaDetailsView<Item: MediaDetailsDisplayable>: View {
    let item: Item
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Poster
                if let url = item.posterURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 300)
                            .overlay(ProgressView())
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Title and subtitle (year)
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.detailsTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(3)
                    
                    if let sub = item.detailsSubtitle, !sub.isEmpty {
                        Text(sub)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Rating
                if let rating = item.voteAverage {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.headline)
                    }
                }
                
                // Overview
                if !item.overview.isEmpty {
                    Text(item.overview)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Movie") {
    MediaDetailsView(item: Movie(
        id: 1,
        title: "Interstellar",
        overview: "A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival.",
        releaseDate: "2014-11-07",
        posterPath: "/nBNZadXqJSdt05SHLqgT0HuC5Gm.jpg",
        backdropPath: nil,
        voteAverage: 8.6,
        voteCount: 10000,
        popularity: 100.0,
        genreIds: [12, 18, 878]
    ))
}

#Preview("TV Show") {
    MediaDetailsView(item: TVShow(
        id: 100,
        name: "Dark",
        overview: "A family saga with a supernatural twist.",
        posterPath: "/poster.jpg",
        firstAirDate: "2017-12-01",
        genreIds: [18, 9648, 10765],
        firstAirDateFormatted: nil,
        voteAverage: 8.8
    ))
}
