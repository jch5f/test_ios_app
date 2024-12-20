//
//  DetailView.swift
//  Test iOS App
//
//  Created by Jason Christopher on 12/19/24.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var item: Item
    
    var body: some View {
        Form {
            TextField(
                "Title",
                text: OptionalBinding(
                    $item.title,
                    default: ""
                )
            )
            DatePicker(
                "Date",
                selection: OptionalBinding(
                    $item.timestamp,
                    default: Date()
                )
            )
        }
        .onDisappear {
            do {
                try viewContext.save()
                print("here")
            } catch {
                print(error)
            }
        }
    }
}

func OptionalBinding<T>(
    _ lhs: Binding<Optional<T>>,
    default rhs: T
) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

#Preview {
    let persistence = PersistenceController.preview
    let request = Item.fetchRequest()
    let items = try! persistence.container.viewContext.fetch(request)
    DetailView(item: items[0])
}
