//
//  SearchFieldView.swift
//  PopcornScreen
//
//  Reusable search field with submit & change callbacks.
//

import SwiftUI

struct SearchFieldView: View {
    @Binding var searchText: String
    let placeholder: String

    /// Optional callback fired when the user submits the search (keyboard Search)
    var onSubmit: (() -> Void)? = nil
    /// Optional callback fired whenever the search text changes
    var onTextChange: ((String) -> Void)? = nil

    @FocusState private var isFocused: Bool
    var autofocus: Bool = false

    init(
        searchText: Binding<String>,
        placeholder: String = "Search",
        autofocus: Bool = false,
        onSubmit: (() -> Void)? = nil,
        onTextChange: ((String) -> Void)? = nil
    ) {
        self._searchText = searchText
        self.placeholder = placeholder
        self.autofocus = autofocus
        self.onSubmit = onSubmit
        self.onTextChange = onTextChange
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            TextField(placeholder, text: $searchText)
                .accessibilityLabel("Search field")
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .submitLabel(.search)
                .focused($isFocused)
                .onSubmit {
                    onSubmit?()
                }
                .onChange(of: searchText) { newValue in
                    onTextChange?(newValue)
                }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    onTextChange?("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Clear search")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 24).fill(.regularMaterial))
        .overlay(
            RoundedRectangle(cornerRadius: 24).stroke(.quaternary, lineWidth: 0.5)
        )
        .animation(.snappy, value: searchText.isEmpty)
        .task { if autofocus { isFocused = true } }
    }
}

#Preview {
    @State var query = ""
    return SearchFieldView(
        searchText: $query,
        placeholder: "Search movies or shows",
        autofocus: false,
        onSubmit: { print("Submitted search") },
        onTextChange: { print("Changed to: \($0)") }
    )
    .padding()
}
