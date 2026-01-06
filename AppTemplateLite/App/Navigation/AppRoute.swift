//
//  AppRoute.swift
//  AppTemplateLite
//
//
//

import SwiftUI
import AppRouter

enum AppRoute: DestinationType {
    case detail(title: String)
    case profile(userId: String)
    case settingsDetail

    static func from(path: String, fullPath: [String], parameters: [String: String]) -> AppRoute? {
        switch path {
        case "detail":
            return .detail(title: parameters["title"] ?? "Details")
        case "profile":
            return .profile(userId: parameters["id"] ?? "me")
        case "settings":
            return .settingsDetail
        default:
            return nil
        }
    }
}
