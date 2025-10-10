//
//  SeriesBlockView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 17/09/2025.
//

import SwiftUI

struct SeriesBlockView: View {
    let show: TVShow

    private static let posterSize = CGSize(width: 94, height: 146)

    private func dotDecimal(_ value: Double) -> String {
        // en_US_POSIX guarantee "dot" as separator in float numbers
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.1f", value)
    }

    // Build a full TMDb image URL from a poster path string (e.g. "/abc.jpg")
    private var posterURL: URL? {
        guard let path = show.posterPath, !path.isEmpty else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    // Convenience to parse the Movie.releaseDate (String "yyyy-MM-dd") into Date?
    private var releaseDateParsed: Date? {
        guard let release = show.firstAirDate, !release.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: release)
    }

    // Show genre names if you have them elsewhere; for now, show IDs as comma-separated
    private var genreDisplay: String {
        let ids = show.genreIDs ?? []
        return ids.map { String($0) }.joined(separator: ", ")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: posterURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color.gray.opacity(0.2)
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    ZStack {
                        Color.gray.opacity(0.2)
                        Image(systemName: "photo")
                            .imageScale(.large)
                            .foregroundStyle(.secondary)
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: Self.posterSize.width, height: Self.posterSize.height)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .contentShape(Rectangle())

            VStack(alignment: .leading, spacing: 4) {
                Text(show.name)
                    .foregroundColor(.primary)
                    .typography(.header4)

                // Movie.releaseDate is a String (yyyy-MM-dd). Parse and display if possible.
                if let date = releaseDateParsed {
                    Text(date, format: .dateTime.year().month().day())
                        .foregroundColor(.secondary)
                        .typography(.header4)
                } else {
                    Text("Unknown release date")
                        .foregroundColor(.secondary)
                        .typography(.header4)
                }

                Spacer(minLength: 0)

                Text(genreDisplay)
                    .foregroundColor(.secondary)
                    .typography(.body)

                HStack(spacing: 6) {
                    Image(.rating)
                    Text(dotDecimal(show.voteAverage ?? 0.0))
                        .foregroundColor(.secondary)
                        .typography(.body)
                }
            }
            .padding(.vertical, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: Self.posterSize.height, alignment: .topLeading)
        .padding(.horizontal, 16)
    }
}

#Preview {
    // Preview using the current Movie model shape
    MovieRowView(
        viewModel: MoviesViewModel(), movie: Movie(
            id: 1,
            title: "Sample Movie Title",
            overview: "Overview",
            releaseDate: "2024-06-14",
            posterPath: "/8bcoRX3hQRHufLPSDREdvr3YMXx.jpg",
            backdropPath: "/backdrop.jpg",
            voteAverage: 7.8,
            voteCount: 1000,
            popularity: 123.4,
            genreIDs: [28, 12]
        )
    )
}
