//
//  MenuBarCalendarApp.swift
//  MenuBarCalendar
//
//  Created by Kevin Ploß on 15.05.24.
//

import SwiftUI

@main
struct CustomApp: App {
    var body: some Scene {
        
        // Icon in MenuBar
        // Text statt icon: systemImage entfernen
        // MenuBarExtra("UtilityApp", systemImage: "hammer") {
            // AppMenu()
        // }
        
        // Text in MenuBar
        MenuBarExtra(getNextEventString()) {
            AppMenu()
        }
    }
}

struct AppMenu: View {
    func action1() {}
    func action2() {}
    func action3() {}

    var body: some View {
        Button(action: action1, label: { Text("Action 1") })
        Button(action: action2, label: { Text("Action 2") })
        
        // Divider()

        Button(action: action3, label: { Text("Action 3") })
    }
}

func getNextEventString() -> String {
    return "Hello"
}
