//
//  ContentView.swift
//  Menu Bar Notes
//
//  Created by Jake Gibbons on 05/07/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [Note]

    var body: some View {
        TextEditor(text: noteBinding)
            .padding()
            .frame(width: 300, height: 200)
            .task { ensureNoteExists() }
    }

    private var noteBinding: Binding<String> {
        Binding {
            notes.first?.text ?? ""
        } set: { newValue in
            if let note = notes.first {
                note.text = newValue
            } else {
                let note = Note(text: newValue)
                modelContext.insert(note)
            }
        }
    }

    private func ensureNoteExists() {
        if notes.isEmpty {
            let note = Note()
            modelContext.insert(note)
        }
    }
}

#Preview {
    ContentView()
}
