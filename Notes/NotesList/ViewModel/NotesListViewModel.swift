//
//  NotesListViewModel.swift
//  Notes
//
//  Created by Lol Kek on 31/01/2024.
//

import SwiftUI

final class NotesListViewModel: ObservableObject {
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @Published var notes: [Note] = []
    private let dataSource: ItemDataSource<Note>
    let sortDesc = SortDescriptor(\Note.timestamp,
                                  order: .reverse)
    init(dataSource: ItemDataSource<Note>) {
        self.dataSource = dataSource

        if isFirstLaunch {
            isFirstLaunch = false
            dataSource.appendItem(item: Note(timestamp: Date(),
                                             id: UUID(),
                                             title: "New note",
                                             completed: false,
                                             attributedTextData: nil))
        }
        fetchNotes()
    }

    func addNote() {
        dataSource.appendItem(item: Note(timestamp: Date(),
                                         id: UUID(),
                                         title: "New note",
                                         completed: false,
                                         attributedTextData: nil))
        fetchNotes()
    }

    func deleteNotes(offsets: IndexSet) {
        for index in offsets {
            dataSource.removeItem(notes[index])
        }
        fetchNotes()
    }

    func fetchNotes() {
        notes = dataSource.fetchItems(sortDesc)
    }

    func forceSaveAllData() {
        dataSource.forceSave()
    }
}
