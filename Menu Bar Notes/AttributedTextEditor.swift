// AttributedTextEditor.swift
import SwiftUI
import AppKit

struct AttributedTextEditor: NSViewRepresentable {
    @Binding var text: NSAttributedString
    var isEditable: Bool = true

    func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()
        textView.isRichText = true
        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.drawsBackground = false
        
        textView.typingAttributes = [
            .font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
            .foregroundColor: NSColor.labelColor
        ]
        
        if !isEditable {
            textView.textContainerInset = NSSize(width: 10, height: 10)
        }

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.documentView = textView
        scrollView.drawsBackground = false

        context.coordinator.textView = textView
        textView.delegate = context.coordinator

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        if textView.attributedString() != text {
            textView.textStorage?.setAttributedString(text)
        }
        
        if textView.isEditable != isEditable {
            textView.isEditable = isEditable
        }
        
        textView.layoutManager?.invalidateDisplay(forCharacterRange: NSRange(location: 0, length: textView.string.count))
        textView.needsDisplay = true
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: NSAttributedString
        weak var textView: NSTextView?

        init(text: Binding<NSAttributedString>) {
            _text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView, textView.isEditable else { return }
            text = textView.attributedString()
        }
    }
}
