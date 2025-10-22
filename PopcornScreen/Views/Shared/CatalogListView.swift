//
//  CatalogListView.swift
//  PopcornScreen
//
//  Created by Paweł Kloc on 22/10/2025.
//

import SwiftUI

struct CatalogListView<Item: Identifiable, Row: View, Destination: View>: View {
    let items: [Item]
    let row: (Item) -> Row
    let destination: (Item) -> Destination

    init(
        items: [Item],
        @ViewBuilder row: @escaping (Item) -> Row,
        @ViewBuilder destination: @escaping (Item) -> Destination
    ) {
        self.items = items
        self.row = row
        self.destination = destination
    }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(items) { item in
                NavigationLink { destination(item) } label: { row(item) }
            }
        }
    }
}

struct CatalogListView_Previews: PreviewProvider {
    struct Dummy: Identifiable { let id = UUID(); let title: String }

    static var previews: some View {
        let sample: [Dummy] = [
            Dummy(title: "A"),
            Dummy(title: "B")
        ]

        return NavigationStack {
            CatalogListView(items: sample) { (item: Dummy) in
                Text(item.title)
            } destination: { (item: Dummy) in
                Text("Detail: \(item.title)")
            }
            .padding()
        }
    }
}
