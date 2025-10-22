//
//  MediaRowView.swift
//  PopcornScreen
//
//  Reusable row for Movies & Series with identical look & feel.
//

import SwiftUI

struct MediaRowView: View {
    let title: String
    let subtitle: String?
    let rating: Double?
    let posterURL: URL?
    let genres: [String]?

    init(
        title: String,
        subtitle: String? = nil,
        rating: Double? = nil,
        posterURL: URL? = nil,
        genres: [String]? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.rating = rating
        self.posterURL = posterURL
        self.genres = genres
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Poster
            ZStack {
                Rectangle().fill(Color.gray.opacity(0.15))
                if let posterURL {
                    AsyncImage(url: posterURL) { img in
                        img.resizable().scaledToFill()
                    } placeholder: { ProgressView() }
                }
            }
            .frame(width: 80, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Texts
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if let genres, !genres.isEmpty {
                    Text(genres.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                if let rating {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                        Text(String(format: "%.1f", rating))
                    }
                    .font(.footnote)
                    .foregroundStyle(.yellow)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    MediaRowView(
        title: "Interstellar",
        subtitle: "2014 • Sci-Fi",
        rating: 8.6,
        posterURL: URL(string: "https://image.tmdb.org/t/p/w185/placeholder.jpg"),
        genres: ["Adventure", "Drama", "Sci‑Fi"]
    )
    .padding()
}
