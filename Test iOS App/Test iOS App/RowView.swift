//
//  RowView.swift
//  Test iOS App
//
//  Created by Jason Christopher on 12/19/24.
//

import SwiftUI
extension Item {
    // Remove `ObservableObject` conformance from here
    public override func willChangeValue(forKey key: String) {
        objectWillChange.send()
        super.willChangeValue(forKey: key)
    }
}
struct RowView: View {
    
    let item: Item
    
    var body: some View {
        VStack {
            HStack {
                Text(item.title ?? "Untitled")
                    .font(.title)
                Spacer()
            }
            HStack {
                Text(item.timestamp!, formatter: itemFormatter)
                    .font(.subheadline)
                Spacer()
            }
        }
    }    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    let persistence = PersistenceController.preview
    let request = Item.fetchRequest()
    let items = try! persistence.container.viewContext.fetch(request)
    RowView(item: items[0])
}
