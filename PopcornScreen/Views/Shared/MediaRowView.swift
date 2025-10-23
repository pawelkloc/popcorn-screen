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
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Rectangle().fill(Color.gray.opacity(0.15))
                if let posterURL {
                    AsyncImage(url: posterURL) { img in
                        img.resizable().scaledToFill()
                    } placeholder: { ProgressView() }
                }
            }
            .posterFrame(.small)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: .spacing(.xs)) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if let genres, !genres.isEmpty {
                    Text(genres.joined(separator: ", "))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if let rating {
                    HStack(spacing: .spacing(.xs)) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", rating))
                            .foregroundStyle(.darkGray)
                            .font(.body)
                    }
                    .padding(.vertical, .spacing(.xxs))
                }
            }
            .padding(.vertical, .spacing(.xxs))
            Spacer()
        }
    }
}

#Preview {
    MediaRowView(
        title: "Interstellar",
        subtitle: "2014",
        rating: 8.6,
        posterURL: URL(string: "https://image.tmdb.org/t/p/w185/placeholder.jpg"),
        genres: ["Adventure", "Drama", "Sci‑Fi"]
    )
    .padding()
}
