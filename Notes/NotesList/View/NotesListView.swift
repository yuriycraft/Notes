//
//  NotesListView.swift
//  Notes
//
//  Created by Lol Kek on 31/01/2024.
//

import SwiftUI
import UIKit

struct NotesListView: View {
    @ObservedObject var viewModel: NotesListViewModel
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(viewModel.notes) { item in
                    NavigationLink {
                        CustomTextEditor(attributedText: Binding(
                            get: {
                                item.getAttributedText() ?? NSMutableAttributedString()
                            },
                            set: { newText in
                                item.setAttributedText(newText)
                            }))
                    } label: {
                        Text("\(item.title) \n \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                            .lineLimit(2)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .onAppear {
                viewModel.fetchNotes()
                
            }
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
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            viewModel.addNote()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            viewModel.deleteNotes(offsets: offsets)
        }
    }
}

// #Preview {
////    let itemDataSource = ItemDataSource<Note>()
////    NotesListView(viewModel: NotesListViewModel(dataSource: itemDataSource))
// }
