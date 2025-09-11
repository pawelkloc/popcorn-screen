//
//  MovieBlockView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 08/09/2025.
//

import SwiftUI

struct MovieBlockView: View {
    let movie: Movie

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

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: movie.posterURL) { phase in
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
                Text(movie.title)
                    .foregroundColor(.primary)
                    .typography(.header4)

                if let date = movie.releaseDate {
                    Text(date, format: .dateTime.year())
                        .foregroundColor(.secondary)
                        .typography(.header4)
                } else {
                    Text("Unknown release date")
                        .foregroundColor(.secondary)
                        .typography(.header4)
                }

                Spacer(minLength: 0)

                Text(movie.genres.joined(separator: ", "))
                    .foregroundColor(.secondary)
                    .typography(.body)

                HStack(spacing: 6) {
                    Image(.rating)
                    Text(dotDecimal(movie.averageRating ?? 0.0))
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
    MovieBlockView(
        movie: Movie(
            id: 1,
            title: "Sample Movie Title",
            posterURL: URL(string: "https://image.tmdb.org/t/p/w500/8bcoRX3hQRHufLPSDREdvr3YMXx.jpg"),
            releaseDate: Calendar.current.date(from: DateComponents(year: 2024, month: 6, day: 14)),
            genres: ["Action", "Adventure"],
            averageRating: 7.8
        )
    )
}
