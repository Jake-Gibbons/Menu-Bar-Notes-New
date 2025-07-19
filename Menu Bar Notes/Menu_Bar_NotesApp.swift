//
//  Menu_Bar_NotesApp.swift
//  Menu Bar Notes
//
//  Created by Jake Gibbons on 05/07/2025.
//

import SwiftUI
import SwiftData

@main
struct Menu_Bar_NotesApp: App {
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
        MenuBarExtra("Notes", systemImage: "note.text") {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
