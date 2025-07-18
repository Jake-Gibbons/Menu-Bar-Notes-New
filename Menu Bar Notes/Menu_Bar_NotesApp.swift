// Menu_Bar_NotesApp.swift
import SwiftUI
import SwiftData

@main
struct MenuBarNotesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        appDelegate.container = sharedModelContainer
    }

    var body: some Scene {
        // CORRECTED: This scene defines the window that opens when the user
        // selects "Preferences" or "Settings". This is required to fix the crash.
        Settings {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
    }
}
