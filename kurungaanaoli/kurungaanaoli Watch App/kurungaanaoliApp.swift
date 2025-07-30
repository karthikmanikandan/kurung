//
//  kurungaanaoliApp.swift
//  kurungaanaoli Watch App
//
//  Created by Assistant on 27/07/25.
//

import SwiftUI

@main
struct kurungaanaoliApp: App {
    @StateObject private var reelsViewModel = ReelsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(reelsViewModel)
        }
    }
}
