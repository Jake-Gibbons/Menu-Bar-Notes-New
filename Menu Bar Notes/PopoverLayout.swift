// PopoverLayout.swift
import SwiftUI

enum PopoverLayout: String, CaseIterable, Identifiable {
    case compact, standard, expanded
    var id: String { rawValue }

    var label: String {
        switch self {
        case .compact: return "Compact"
        case .standard: return "Standard"
        case .expanded: return "Expanded"
        }
    }

    var size: CGSize {
        switch self {
        case .compact: return CGSize(width: 300, height: 200)
        case .standard: return CGSize(width: 360, height: 280)
        case .expanded: return CGSize(width: 480, height: 400)
        }
    }
}
