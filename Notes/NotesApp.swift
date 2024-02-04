//
//  NotesApp.swift
//  Notes
//
//  Created by Lol Kek on 30/01/2024.
//

import SwiftData
import SwiftUI

@main
struct NotesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Note.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            let itemDataSource = ItemDataSource<Note>(modelContext: sharedModelContainer.mainContext)
            let viewModel = NotesListViewModel(dataSource: itemDataSource)
            NotesListView(viewModel: viewModel)
        }.modelContainer(sharedModelContainer)
    }
}
