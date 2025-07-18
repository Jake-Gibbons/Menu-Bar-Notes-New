// QuickNotePopover.swift
import SwiftUI

struct QuickNotePopover: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("accentColorHex") private var accentColorHex: String = "#007aff"
    @State private var text: NSAttributedString = NSAttributedString(string: "")
    @State private var isMarkdownPreview = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 12) {
                AttributedTextEditor(text: $text)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                HStack(spacing: 12) {
                    // CORRECTED: Replaced the old Button with the modern SettingsLink.
                    SettingsLink {
                        Image(systemName: "gearshape")
                    }
                    .help("Open Preferences")
                    
                    Button(action: openMainWindow) { Image(systemName: "note.text") }.help("Open Full Notes App")

                    Spacer()
                    Button(action: undo) { Image(systemName: "arrow.uturn.backward") }.help("Undo")
                    Button(action: redo) { Image(systemName: "arrow.uturn.forward") }.help("Redo")
                    Button(action: { isMarkdownPreview.toggle() }) { Image(systemName: isMarkdownPreview ? "doc.richtext" : "doc.plaintext") }.help("Toggle Markdown Preview")
                    Button(action: saveNote) { Image(systemName: "square.and.arrow.down") }.help("Save Note")
                }
                .buttonBorderShape(.circle)
            }
            .padding()
            ResizeCorner()
        }
        .accentColor(Color(hex: accentColorHex) ?? .accentColor)
        .frame(minWidth: 360, minHeight: 280)
        .background(VisualEffectView(material: .underWindowBackground, blendingMode: .withinWindow))
    }
    
    private func saveNote() {
        guard text.length > 0 else { return }
        do {
            let data = try text.data(from: NSRange(location: 0, length: text.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])
            let newItem = Item(timestamp: .now, attributedContent: data)
            modelContext.insert(newItem)
            text = NSAttributedString(string: "")
        } catch {
            print("Failed to save note: \(error)")
        }
    }

    private func openMainWindow() { NotificationCenter.default.post(name: .didRequestMainWindow, object: nil) }
    private func undo() { NSApp.sendAction(Selector(("undo:")), to: nil, from: nil) }
    private func redo() { NSApp.sendAction(Selector(("redo:")), to: nil, from: nil) }
}
