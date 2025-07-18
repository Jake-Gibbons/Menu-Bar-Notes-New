// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @AppStorage("accentColorHex") private var accentColorHex: String = "#007aff"
    @AppStorage("popoverLayout") private var popoverLayoutRaw: String = PopoverLayout.standard.rawValue
    @AppStorage("popoverBelowMenuBar") private var popoverBelowMenuBar: Bool = true
    @AppStorage("savePath") private var savePath: String = ""

    private var popoverLayout: Binding<PopoverLayout> {
        Binding(
            get: { PopoverLayout(rawValue: popoverLayoutRaw) ?? .standard },
            set: { popoverLayoutRaw = $0.rawValue }
        )
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("Save Location", text: $savePath)
                        .disabled(true) // Disable manual editing for safety.
                    
                    // CORRECTED: The Button now has a valid action and label.
                    Button("Choose...") {
                        chooseSavePath()
                    }
                }
            } header: {
                Text("App Settings")
            }
            
            Divider()
            
            Section {
                ColorPicker("Accent Color", selection: Binding(
                    get: { Color(hex: accentColorHex) ?? .accentColor },
                    set: { accentColorHex = $0.hexString }
                ))

                Picker("Popover Layout", selection: popoverLayout) {
                    ForEach(PopoverLayout.allCases) { layout in
                        Text(layout.label).tag(layout)
                    }
                }
                .pickerStyle(.segmented)
                
                Toggle("Show Popover Below Menu Bar", isOn: $popoverBelowMenuBar)
            } header: {
                Text("Appearance")
            }
        }
        .padding()
        .frame(width: 360)
    }
    
    // This new function handles opening the panel to select a folder.
    private func chooseSavePath() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.title = "Choose a location to save your notes"
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                // Update the save path if the user selects a folder.
                self.savePath = url.path
            }
        }
    }
}

#Preview {
    SettingsView()
    
}
