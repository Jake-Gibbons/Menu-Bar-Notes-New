import SwiftData
import SwiftUI

// MARK: - NoteRowView
struct NoteRowView: View {
    let item: Item
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.plainText)
                .lineLimit(1)
                .truncationMode(.tail)
            HStack {
                Text(item.timestamp, style: .date)
                Text(item.timestamp, style: .time)
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - ContentView
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    
    @State private var selection: Item?

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(selection: $selection) {
                    ForEach(items) { item in
                        NoteRowView(item: item)
                            .tag(item)
                            .contextMenu {
                                Button {
                                    selection = item
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                
                                Button {
                                    copy(item: item)
                                } label: {
                                    Label("Copy", systemImage: "document.on.document")
                                }
                                
                                Divider()
                                
                                Button(role: .destructive) {
                                    delete(item: item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }

                HStack {
                    Text("Notes Taken: \(items.count)")
                    Spacer()
                    SettingsLink {
                        Image(systemName: "gearshape")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .foregroundStyle(.secondary)
                .font(.footnote)
                .background(Material.thin)
            }
            .navigationTitle("Notes")
            .navigationDestination(for: Item.self) { item in
                // ✅ Replace with actual RichTextDetailView
                VStack(alignment: .leading, spacing: 12) {
                    Text("Detail View")
                        .font(.title2.bold())
                    Text(item.plainText)
                        .font(.body)
                }
                .padding()
            }
        } detail: {
            Text("Select a note")
                .font(.title)
                .foregroundColor(.secondary)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: addItem) {
                    Label("New Note", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: - Actions
    private func addItem() {
        withAnimation {
            let emptyContent = NSAttributedString(string: "New Note")
            do {
                let data = try emptyContent.data(
                    from: NSRange(location: 0, length: emptyContent.length),
                    documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]
                )
                let newItem = Item(timestamp: Date(), attributedContent: data)
                modelContext.insert(newItem)
                selection = newItem
            } catch {
                print("Failed to create new item: \(error)")
            }
        }
    }

    private func delete(item: Item) {
        withAnimation {
            modelContext.delete(item)
        }
    }

    private func copy(item: Item) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.plainText, forType: .string)
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)

    let note1 = NSAttributedString(string: "This is the first note.")
    let note2 = NSAttributedString(string: "This is the second, more recent note.")

    let data1 = try! note1.data(from: NSRange(location: 0, length: note1.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtfd])

    let data2 = try! note2.data(from: NSRange(location: 0, length: note2.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtfd])

    let sampleNote1 = Item(timestamp: .now.addingTimeInterval(-3600), attributedContent: data1)
    let sampleNote2 = Item(timestamp: .now, attributedContent: data2)

    
    
    container.mainContext.insert(sampleNote1)
    container.mainContext.insert(sampleNote2)

    return ContentView()
        .modelContainer(container)

}
