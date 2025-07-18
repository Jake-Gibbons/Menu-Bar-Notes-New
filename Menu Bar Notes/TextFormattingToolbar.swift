// TextFormattingToolbar.swift
import SwiftUI
import AppKit

struct TextFormattingToolbar: View {
    @Binding var text: NSAttributedString

    var body: some View {
        HStack(spacing: 12) {
            Button(action: { toggleTrait(.boldFontMask) }) { Image(systemName: "bold") }.help("Bold")
            Button(action: { toggleTrait(.italicFontMask) }) { Image(systemName: "italic") }.help("Italic")
            Button(action: { toggleAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue) }) { Image(systemName: "underline") }.help("Underline")
            Button(action: { toggleAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue) }) { Image(systemName: "strikethrough") }.help("Strikethrough")

            Divider()

            Button(action: { changeFontSize(by: 1) }) { Image(systemName: "textformat.size.larger") }.help("Increase Font Size")
            Button(action: { changeFontSize(by: -1) }) { Image(systemName: "textformat.size.smaller") }.help("Decrease Font Size")

            ColorPicker("", selection: Binding(
                get: { getColorFromSelection() },
                set: { newColor in applyAttribute(.foregroundColor, value: NSColor(newColor)) }
            )).labelsHidden().help("Text Color")
        }
        .buttonStyle(.plain)
    }

    private func getActiveTextView() -> NSTextView? {
        return NSApp.keyWindow?.firstResponder as? NSTextView
    }
    
    private func getSelection() -> NSRange {
        guard let textView = getActiveTextView() else { return NSRange(location: 0, length: 0) }
        return textView.selectedRange()
    }

    private func getColorFromSelection() -> Color {
        guard getSelection().length > 0 else { return .primary }
        let attributes = text.attributes(at: getSelection().location, effectiveRange: nil)
        let color = attributes[.foregroundColor] as? NSColor ?? .labelColor
        return Color(color)
    }

    private func applyAttribute(_ key: NSAttributedString.Key, value: Any) {
        let selection = getSelection()
        guard selection.length > 0, let textView = getActiveTextView() else { return }
        
        let mutableText = NSMutableAttributedString(attributedString: self.text)
        mutableText.addAttribute(key, value: value, range: selection)
        self.text = mutableText
        
        textView.setSelectedRange(selection)
    }

    private func toggleAttribute(_ key: NSAttributedString.Key, value: Any) {
        let selection = getSelection()
        guard selection.length > 0, let textView = getActiveTextView() else { return }

        let attributes = text.attributes(at: selection.location, effectiveRange: nil)
        let mutableText = NSMutableAttributedString(attributedString: self.text)
        
        if attributes[key] != nil {
            mutableText.removeAttribute(key, range: selection)
        } else {
            mutableText.addAttribute(key, value: value, range: selection)
        }
        self.text = mutableText
        textView.setSelectedRange(selection)
    }
    
    private func toggleTrait(_ trait: NSFontTraitMask) {
        let selection = getSelection()
        guard selection.length > 0, let textView = getActiveTextView() else { return }
        
        let fontManager = NSFontManager.shared
        let mutableText = NSMutableAttributedString(attributedString: self.text)
        
        mutableText.enumerateAttribute(.font, in: selection) { value, range, _ in
            let currentFont = value as? NSFont ?? .systemFont(ofSize: 13)
            let hasTrait = fontManager.traits(of: currentFont).contains(trait)
            let newFont = hasTrait ? fontManager.convert(currentFont, toNotHaveTrait: trait) : fontManager.convert(currentFont, toHaveTrait: trait)
            mutableText.addAttribute(.font, value: newFont, range: range)
        }
        
        self.text = mutableText
        textView.setSelectedRange(selection)
    }
    
    private func changeFontSize(by amount: CGFloat) {
        let selection = getSelection()
        guard selection.length > 0, let textView = getActiveTextView() else { return }
        
        let mutableText = NSMutableAttributedString(attributedString: self.text)
        
        mutableText.enumerateAttribute(.font, in: selection) { value, range, _ in
            let currentFont = value as? NSFont ?? .systemFont(ofSize: 13)
            let newSize = max(8, currentFont.pointSize + amount)
            if let newFont = NSFont(descriptor: currentFont.fontDescriptor, size: newSize) {
                mutableText.addAttribute(.font, value: newFont, range: range)
            }
        }
        
        self.text = mutableText
        textView.setSelectedRange(selection)
    }
}
