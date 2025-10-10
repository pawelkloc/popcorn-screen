//
//  SearchFieldView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 06/10/2025.
//

import SwiftUI

struct SearchFieldView: View {
    @Binding var searchText: String
    var placeholder: String = "Search"
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")

                TextField(placeholder, text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit {

                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Clear search")
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(.separator, lineWidth: 0.5)
            }
            .animation(.snappy, value: searchText.isEmpty)
        }
        .padding(.horizontal, 16)
    }

}

#Preview {
    SearchFieldView(searchText: .constant(""))
}
