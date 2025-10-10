import SwiftUI

struct SortView: View {
    @ObservedObject var viewModel: MoviesViewModel

    var body: some View {
        Menu {
            // Custom header that respects app typography
            Text("Sort by")
                .typography(.header2)
                .disabled(true)

            Button { viewModel.applySort(.alphabeticalAscending) } label: {
                Label("Alphabetical order", image: "ascending")
            }

            Button { viewModel.applySort(.releaseDateAscending) } label: {
                Label("Release date", image: "ascending")
            }

            Button { viewModel.applySort(.ratingAscending) } label: {
                Label("Rating", image: "ascending")
            }

            Divider()

            if viewModel.currentSort != nil {
                Section {
                    Button(role: .destructive) { viewModel.applySort(nil) } label: {
                        Label("Clear sort", systemImage: "xmark.circle")
                    }
                }
            }
        } label: {
            Label("Filter by", image: "filters")
                .labelStyle(.titleAndIcon)
                .foregroundColor(.darkGray)
        }
    }
}

#Preview {
    SortView(viewModel: .init())
}
