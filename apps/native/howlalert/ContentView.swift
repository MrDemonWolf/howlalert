//
//  ContentView.swift
//  howlalert
//
//  Created by Nathanial Henniges on 3/17/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(macOS)
        VStack(spacing: 12) {
            Image(systemName: "bell.badge")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("HowlAlert")
                .font(.headline)
            Text("Monitoring Claude Code usage")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 280)
        #elseif os(iOS)
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "bell.badge")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(.largeTitle)
                Text("HowlAlert")
                    .font(.title)
                Text("Claude Code usage monitor")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("HowlAlert")
        }
        #elseif os(watchOS)
        VStack {
            Image(systemName: "bell.badge")
                .foregroundStyle(.tint)
            Text("HowlAlert")
                .font(.headline)
        }
        #endif
    }
}

#Preview {
    ContentView()
}
