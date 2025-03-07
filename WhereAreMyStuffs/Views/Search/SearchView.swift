//
//  SearchView.swift
//  WhereAreMyStuffs
//
//  Created by lws on 4/3/2025.
//

import SwiftUI
import CoreData

struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let searchText: String
    let excludeDeleted: Bool
    
    @FetchRequest var items: FetchedResults<Item>
    
    init(searchText: String, excludeDeleted: Bool = false) {
        self.searchText = searchText
        self.excludeDeleted = excludeDeleted
        
        // Create the fetch request with a filter for the search text
        let request = NSFetchRequest<Item>(entityName: "Item")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.name, ascending: true)]
        
        // Build the predicate
        var predicates: [NSPredicate] = []
        
        // Search predicate
        if !searchText.isEmpty {
            let nameFilter = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
            let descFilter = NSPredicate(format: "itemDescription CONTAINS[cd] %@", searchText)
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [nameFilter, descFilter]))
        }
        
        // Deleted filter
        if excludeDeleted {
            predicates.append(NSPredicate(format: "storageArea.aDeleted == NO"))
        }
        
        // Combine predicates if needed
        if !predicates.isEmpty {
            if predicates.count > 1 {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            } else {
                request.predicate = predicates[0]
            }
        }
        
        _items = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink(destination: SearchResultDetailView(item: item)) {
                    SearchResultCell(item: item)
                }
            }
        }
        .navigationTitle("Search Results")
        .overlay(
            Group {
                if items.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label("No Results", systemImage: "magnifyingglass")
                        },
                        description: {
                            Text("Try searching for something else")
                        }
                    )
                }
            }
        )
    }
}
