//
//  MenuBarCalendarApp.swift
//  MenuBarCalendar
//
//  Created by Kevin Ploß on 15.05.24.
//

import SwiftUI
import EventKit
import Foundation

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
    // func action2() {}
    // func action3() {}

    var body: some View {
        Button(action: action1, label: { Text("Action 1") })
    //     Button(action: action2, label: { Text("Action 2") })
    //     // Divider()
    //     Button(action: action3, label: { Text("Action 3") })
    }
}


func getNextEventString() -> String {
    var text = "-"
    
    let eventStore = EKEventStore()
    
    eventStore.requestFullAccessToEvents { (granted, error) in
        if granted {
            print("Zugriff auf Kalender genehmigt")
            // Hier können Sie Ihre Logik ausführen, die auf den Zugriff zugreift
        } else {
            print("Zugriff auf Kalender abgelehnt oder Fehler aufgetreten: \(error?.localizedDescription ?? "Unbekannter Fehler")")
            // Hier können Sie eine Fehlerbehandlung implementieren
            text = "Kein Zugriff"
        }
    }
    
    // Ab hier abändern
    
    // Initialize the store.
    var store = EKEventStore()

    
    let calendar = Calendar.current
    
    // Startdatum festlegen
    var todayComponents = DateComponents()
    todayComponents.day = 0
    let today = calendar.date(byAdding: todayComponents, to: Date(), wrappingComponents: false)
    
    // Enddatum festlegen
    var tomorrowComponents = DateComponents()
    tomorrowComponents.day = +1
    let tomorrow = calendar.date(byAdding: tomorrowComponents, to: Date(), wrappingComponents: false)
    
    // Predicate erstellen
    var predicate: NSPredicate? = nil
    if let anAgo = today, let aNow = tomorrow {
        predicate = eventStore.predicateForEvents(withStart: anAgo, end: aNow, calendars: nil)
    }
    
    // Events abrufen
    var events: [EKEvent]? = nil
    if let aPredicate = predicate {
        events = eventStore.events(matching: aPredicate)
    }
    
    
    
    
    //! Hier gehts weiter
    // ===============================================
    
    
    // Aktuelles Datum und Uhrzeit
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")

    let currentUTCDate = Date()
    let utcDateString = dateFormatter.string(from: currentUTCDate)

    print("Aktuelle UTC-Zeit: \(utcDateString)")
    print("")
    print("")
    
    
    
    
    // Events ausgeben
    if let events = events {
        for event in events {
            // print(event)
            print("Event Properties:")
            print("Title: \(event.title)")
            print("Start Date: \(event.startDate)")
            print("End Date: \(event.endDate)")
            print("")
        }
    } else {
        print("Keine Events gefunden")
    }
    
    return text;
}
