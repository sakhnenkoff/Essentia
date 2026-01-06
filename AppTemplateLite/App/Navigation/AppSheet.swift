//
//  AppSheet.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import AppRouter

enum AppSheet: SheetType {
    case paywall
    case settings
    case debug

    var id: Int {
        hashValue
    }
}
