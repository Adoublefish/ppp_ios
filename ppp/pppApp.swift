//
//  pppApp.swift
//  ppp
//
//  Created by 傅煜 on 7/22/25.
//

import SwiftUI

@main
struct pppApp: App {
    @StateObject private var userManager = UserDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userManager)
                .preferredColorScheme(userManager.darkModePreference.preferredColorScheme)
        }
    }
}
