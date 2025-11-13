import SwiftUI

struct SortView: View {
    @Binding var currentSort: TMDBSortOption?
    var onApply: (() -> Void)? = nil
    var onReset: (() -> Void)? = nil
    var onReload: (() -> Void)? = nil

    var body: some View {
        Menu {
            Text("Sort by")
                .typography(.header2)
                .disabled(true)

            triStateSortRow(.alphabetical, title: "Alphabetical order")
            triStateSortRow(.releaseDate, title: "Release date")
            triStateSortRow(.rating, title: "Rating")

            Divider()

            Button {
                currentSort = nil
                onReset?()
                onReload?()
            } label: {
                Label("Reset", systemImage: "arrow.uturn.left")
            }
        } label: {
            Label("Filters", image: "filters")
                .labelStyle(.titleAndIcon)
                .foregroundColor(.darkGray)
        }
    }

    private enum Category {
        case alphabetical, releaseDate, rating
    }

    private enum SortState { case none, asc, desc }

    private func options(for category: Category) -> (asc: TMDBSortOption, desc: TMDBSortOption) {
        switch category {
        case .alphabetical:
            return (.alphabeticalAscending, .alphabeticalDescending)
        case .releaseDate:
            return (.releaseDateAscending, .releaseDateDescending)
        case .rating:
            return (.ratingAscending, .ratingDescending)
        }
    }

    private func state(for category: Category) -> SortState {
        let pair = options(for: category)
        switch currentSort {
        case pair.asc:
            return .asc
        case pair.desc:
            return .desc
        default:
            return .none
        }
    }

    private func icon(for state: SortState) -> String {
        switch state {
        case .asc: return "ascending"
        case .desc: return "descending"
        case .none: return "sort-default"
        }
    }

    private func toggleCategory(_ category: Category) {
        let pair = options(for: category)
        let current = state(for: category)

        switch current {
        case .none:
            currentSort = pair.asc
        case .asc:
            currentSort = pair.desc
        case .desc:
            currentSort = nil
        }

        onApply?()
    }

    @ViewBuilder
    private func triStateSortRow(_ category: Category, title: String) -> some View {
        let current = state(for: category)
        Button {
            toggleCategory(category)
        } label: {
            Label(title, image: icon(for: current))
        }
    }
}

#Preview {
    @State var sort: TMDBSortOption? = nil
    return SortView(currentSort: $sort)
}
