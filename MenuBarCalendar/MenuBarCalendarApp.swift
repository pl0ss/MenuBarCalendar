//
//  MenuBarCalendarApp.swift
//  MenuBarCalendar
//
//  Created by Kevin Ploß on 15.05.24.
//

import SwiftUI
import EventKit
import Foundation


class Event {
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String
    
    init(title: String, startDate: Date, endDate: Date, location: String) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
    }
}

let nextEvents = getNextEvents(numberOfEvents: 3) // nächsten X Events


// ToDo: Alle 5min neuladen

@main
struct CustomApp: App {
    var body: some Scene {
        
        // Icon in MenuBar
        // Text statt icon: systemImage entfernen
        // MenuBarExtra("UtilityApp", systemImage: "hammer") {
            // AppMenu()
        // }
        
        
        // Text in MenuBar
        MenuBarExtra(getMenuBarText()) {
            AppMenu()
        }
    }
}

struct AppMenu: View {
    func action1() {}
    func action2() {}
    func action3() {}
    func quit() {
        exit(0)
    }
    
    var body: some View { // ToDo Buttons zu Text
        Button(action: action1, label: { Text(getActionText(num: 0)) })
        Button(action: action2, label: { Text(getActionText(num: 1)) })
        Button(action: action3, label: { Text(getActionText(num: 2)) })
        Divider()
        Button(action: quit, label: { Text("Quit") })
    }
}


func getNextEvents(numberOfEvents: Int) -> [Event] {
    let eventStore = EKEventStore()
    
    eventStore.requestFullAccessToEvents { (granted, error) in
        if granted {
            print("Zugriff auf Kalender genehmigt")
            // Hier können Sie Ihre Logik ausführen, die auf den Zugriff zugreift
        } else {
            print("Zugriff auf Kalender abgelehnt oder Fehler aufgetreten: \(error?.localizedDescription ?? "Unbekannter Fehler")")
            // Hier können Sie eine Fehlerbehandlung implementieren
        }
    }
    
    
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
    

    
    // Aktuelles Datum und Uhrzeit
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    let nowUTC = Date()
    // let utcDateString = dateFormatter.string(from: nowUTC)

    // print("Aktuelle UTC-Zeit: \(utcDateString)")
    // print("")
    // print("")
    
    
    var nextEvents: [Event] = []

    
    // Events ausgeben
    if let events = events {
        for event in events {
            // print(event)
            // print("Title: \(event.title)")
            // print("Start Date: \(event.startDate)")
            // print("End Date: \(event.endDate)")
            // print("")
            
            
            if(event.startDate > nowUTC) {
                // return event.title
                
                let thisEvent = Event(title: event.title, startDate: event.startDate, endDate: event.endDate, location: event.location ?? "")
                
                nextEvents.append(thisEvent)
                if(nextEvents.count == numberOfEvents) {
                    break
                }
            }
        }
    } else {
        print("Keine Events gefunden")
    }
    
    return nextEvents;
}


func getMenuBarText() -> String {
    var menuBarText: String
    
    if nextEvents.isEmpty {
        menuBarText = "Keine Termine"
    } else {
        menuBarText = eventToMenuBarText(event: nextEvents[0])
    }
    
    return menuBarText
}

func eventToMenuBarText(event: Event) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let localDateString = dateFormatter.string(from: event.startDate)
    
    let components = localDateString.components(separatedBy: " ")[1].split(separator: ":")
    let startTime = components.prefix(2).joined(separator: ":")
    return startTime
}


func getActionText(num: Int) -> String {
    var actionText: String
    
    if nextEvents.count <= num {
        actionText = ""
    } else {
        actionText = eventToActionText(event: nextEvents[num])
    }
    
    return actionText
}

func eventToActionText(event: Event) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let localDateString = dateFormatter.string(from: event.startDate)
    
    let components = localDateString.components(separatedBy: " ")[1].split(separator: ":")
    let startTime = components.prefix(2).joined(separator: ":")
    
    let actionText = "\(startTime) \(event.title) \(event.location)"
    
    return actionText
}
