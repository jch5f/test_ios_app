//
//  ContentView.swift
//  Test iOS App
//
//  Created by Jason Christopher on 12/19/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var model = ContentViewModel()
    @State private var presentedItems: [Item] = []

    var body: some View {
        NavigationStack(path: $presentedItems) {
            List {
                if model.items.isEmpty {
                    Text("No items.")
                }
                ForEach(model.items) { item in
                    NavigationLink(value: item) {
                        RowView(item: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationDestination(for: Item.self) { item in
                DetailView(item: item)
            }
            .navigationTitle("My Items")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .onAppear {
                do {
                    try model.load(context: viewContext)
                    print("appear: \(model.items.count)")
                } catch {
                    print(error)
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            presentedItems.append(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { model.items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

class ContentViewModel: ObservableObject {
    @Published var items: [Item] = []
    
    func load(context: NSManagedObjectContext) throws {
        let request = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)]
        items = try context.fetch(request)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
