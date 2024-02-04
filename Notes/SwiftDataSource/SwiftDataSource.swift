//
//  SwiftDataSource.swift
//  Notes
//
//  Created by Lol Kek on 31/01/2024.
//

import SwiftData
import Foundation

final class ItemDataSource<T: PersistentModel> {
    private let modelContext: ModelContext

    @MainActor
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func appendItem(item: T) {
        modelContext.insert(item)
    }

    func fetchItems(_ sortSesc: SortDescriptor<T>) -> [T] {
        do {
            let fetchDesc = FetchDescriptor<T>(sortBy: [sortSesc])
            return try modelContext.fetch(fetchDesc)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func removeItem(_ item: T) {
        modelContext.delete(item)
    }
    
    func forceSave() {
        do {
          try modelContext.save()
        } catch {
            print("Error saving")
        }
       
    }
}
