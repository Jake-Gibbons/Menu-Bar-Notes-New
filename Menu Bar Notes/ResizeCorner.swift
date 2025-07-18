// ResizeCorner.swift
import SwiftUI

struct ResizeCorner: View {
    var body: some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
            .foregroundColor(.secondary)
            .opacity(0.6)
            .background(Color.clear)
            .gesture(DragGesture().onChanged { value in
                if let window = NSApp.keyWindow {
                    var frame = window.frame
                    frame.size.width += value.translation.width
                    frame.size.height -= value.translation.height
                    frame.origin.y += value.translation.height
                    window.setFrame(frame, display: true)
                }
            })
    }
}
