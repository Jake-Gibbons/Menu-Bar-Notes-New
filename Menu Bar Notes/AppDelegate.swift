// AppDelegate.swift
import Cocoa
import SwiftData
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover?
    var mainWindow: NSWindow?
    var container: ModelContainer!

    @AppStorage("popoverLayout") private var popoverLayoutRaw: String = PopoverLayout.standard.rawValue
    @AppStorage("popoverBelowMenuBar") private var popoverBelowMenuBar: Bool = true
    @AppStorage("accentColorHex") private var accentColorHex: String = "#007aff"

    private var popoverLayout: PopoverLayout { PopoverLayout(rawValue: popoverLayoutRaw) ?? .standard }
    private var accentColor: Color { Color(hex: accentColorHex) ?? .accentColor }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        NotificationCenter.default.addObserver(self, selector: #selector(openMainWindow), name: .didRequestMainWindow, object: nil)
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "note.text.badge.plus", accessibilityDescription: "Notes")
            button.target = self
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc private func statusItemClicked(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            showMenu()
        } else {
            togglePopover()
        }
    }

    private func togglePopover() {
        if let popover = popover, popover.isShown {
            popover.performClose(nil)
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        if popover == nil {
            let view = QuickNotePopover().modelContainer(container)
            let hostingController = NSHostingController(rootView: view)
            let newPopover = NSPopover()
            newPopover.contentViewController = hostingController
            newPopover.behavior = .transient
            self.popover = newPopover
        }
        popover?.contentSize = popoverLayout.size
        if let button = statusItem.button {
            let edge: NSRectEdge = popoverBelowMenuBar ? .minY : .maxY
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: edge)
            popover?.contentViewController?.view.window?.becomeKey()
        }
    }
    
    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: "Open App", action: #selector(openMainWindow), keyEquivalent: "")
        menu.addItem(withTitle: "Preferences…", action: #selector(openSettings), keyEquivalent: ",")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func openMainWindow() {
        // CORRECTED: Activate the app first to bring it to the foreground.
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        if mainWindow == nil {
            let view = ContentView().modelContainer(container).accentColor(accentColor)
            let hostingController = NSHostingController(rootView: view)
            let window = NSWindow(contentViewController: hostingController)
            window.title = "Notes"
            window.setContentSize(NSSize(width: 700, height: 450))
            window.delegate = self
            mainWindow = window
        }
        // Then, ensure the window is key and ordered front.
        mainWindow?.makeKeyAndOrderFront(nil)
    }

    @objc private func openSettings() {
        // CORRECTED: Activate the app first to ensure the settings window
        // opens in the foreground.
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }

    func windowWillClose(_ notification: Notification) {
        // This improved logic correctly reverts the app to a menu bar accessory
        // only when the last visible window is closed.
        if (notification.object as? NSWindow) == mainWindow {
            mainWindow = nil
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let hasVisibleWindows = NSApp.windows.contains { $0.isVisible && $0.canBecomeMain }
            if !hasVisibleWindows {
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
}
