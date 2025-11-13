import SwiftUI

struct MediaDetailsView: View {
    let item: any MediaDisplayable
    private let genreOverride: String?

    init(item: any MediaDisplayable, genreNames: String? = nil) {
        self.item = item
        self.genreOverride = genreNames
    }

    private var genreText: String {
        let raw = (genreOverride?.isEmpty == false) ? genreOverride! : item.genreNames
        return raw.replacingOccurrences(of: ",", with: " • ")
    }

    @State private var isFavorite = false

    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                if let url = item.posterURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                .ignoresSafeArea()
                                .blur(radius: 30)
                                .opacity(0.5)
//                                .clipped()
                        default:
                            Color.clear.frame(height: 260)
                        }
                    }
                }

                VStack(spacing: .spacing(.m)) {
                    if let url = item.posterURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                                    .scaledToFill()
                                    .posterFrame(.large)
                                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large.rawValue))
                                    .shadow(radius: 6)
                            default:
                                RoundedRectangle(cornerRadius: CornerRadius.large.rawValue)
                                    .fill(.secondary.opacity(0.2))
                            }
                        }
                    }

                    HStack(alignment: .center) {
                        Text(item.titleText)
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button {
                            isFavorite.toggle()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .imageScale(.large)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                    }

                    if !genreText.isEmpty {
                        Text(genreText)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack(spacing: .spacing(.s)) {
                        if let date = item.releaseDateText, !date.isEmpty { MetaChip(text: date) }
                        if let run  = item.runtimeText,  !run.isEmpty  { MetaChip(text: run)  }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: .spacing(.s)) {
                        Section(title: "Description")
                        if item.overviewText.isEmpty {
                            Text("No description available.").foregroundStyle(.secondary)
                        } else {
                            Text(item.overviewText)
                        }

                        Section(title: "Language")
                        if let lang = item.language, !lang.isEmpty {
                            Text(lang)
                        } else {
                            Text("No language available.").foregroundStyle(.secondary)
                        }

                        Section(title: "Production Companies")
                        if let companies = item.productionCompaniesText, !companies.isEmpty {
                            Text(companies)
                        } else {
                            Text("No production companies available.").foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.spacing(.m))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Movie details") {
    struct MockMedia: MediaDisplayable {
        var id = 1
        var titleText = "Blade Runner 2049"
        var genreNames = "Science fiction, Drama"
        var releaseDateText: String? = "Oct 2017"
        var runtimeText: String? = "2h 44m"
        var overviewText = "Thirty years after the events of the first film..."
        var posterURL: URL? = URL(string: "https://image.tmdb.org/t/p/w500/8.jpg")
        var language: String? = "English"
        var productionCompaniesText: String? = "Alcon Entertainment, Columbia Pictures, Scott Free Productions"
    }
    return MediaDetailsView(item: MockMedia())
}
