//
//  howlalertApp.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import SwiftUI

@main
struct howlalertApp: App {
    var body: some Scene {
        #if os(macOS)
        MenuBarExtra("HowlAlert", systemImage: "bell.badge") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
        #else
        WindowGroup {
            ContentView()
        }
        #endif
    }
}
