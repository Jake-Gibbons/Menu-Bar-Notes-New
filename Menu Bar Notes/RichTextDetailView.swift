// RichTextDetailView.swift
import SwiftUI

struct RichTextDetailView: View {
    @Bindable var item: Item
    
    @State private var attributedString: NSAttributedString = .init()

    var body: some View {
        VStack(spacing: 0) {
            AttributedTextEditor(text: $attributedString, isEditable: true)
            Divider()
            TextFormattingToolbar(text: $attributedString)
                .frame(width: .infinity, height: 30)
        }
        .onAppear { loadContent() }
        .onChange(of: item) { loadContent() }
        .onChange(of: attributedString) { saveContent() }
        .toolbarRole(.editor)
    }
    
    private func loadContent() {
        do {
            self.attributedString = try NSAttributedString(data: item.attributedContent, options: [.documentType: NSAttributedString.DocumentType.rtfd], documentAttributes: nil)
        } catch {
            self.attributedString = NSAttributedString(string: "Error: Could not load note content.")
        }
    }

    private func saveContent() {
        do {
            let data = try attributedString.data(from: .init(location: 0, length: attributedString.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])
            item.attributedContent = data
        } catch {
            print("Failed to save attributed content: \(error)")
        }
    }
}
