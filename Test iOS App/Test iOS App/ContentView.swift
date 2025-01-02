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
    @State private var refreshID = UUID()
    @State private var model = ContentViewModel()
    @State private var presentedItems: [Item] = []
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default
    ) private var items: FetchedResults<Item>

    var body: some View {
        NavigationStack(path: $presentedItems) {
            List {
                if items.isEmpty {
                    Text("No items.")
                }
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        RowView(item: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }

            .navigationDestination(for: Item.self) { item in
                DetailView(item: item,onSave: { refreshID = UUID() })
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
                    do {
                            let request: NSFetchRequest<Item> = Item.fetchRequest()
                            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
                            let results = try viewContext.fetch(request)
                        } catch {
                            print("Fetch error: \(error)")
                        }
                } catch {
                    print(error)
                }
            }
        }.id(refreshID)

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
               for index in offsets {
                   let itemToDelete = model.items[index]
                   viewContext.delete(itemToDelete)
               }
               do {
                   try viewContext.save()
                   model.items.remove(atOffsets: offsets)
               } catch {
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
