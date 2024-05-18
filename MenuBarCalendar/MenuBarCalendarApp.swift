//
//  MenuBarCalendarApp.swift
//  MenuBarCalendar
//
//  Created by Kevin Ploß on 15.05.24.
//

import SwiftUI
import EventKit
import Foundation


//* Setting
private let menuBarTextType = 2 // 0: "11:15"; 1: "11:15 - 12:30"; 2: "- 10:30 11:15 -"


class Event {
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String
    var differenct_date: Bool // für die Unterteilung zischen Heute und Morgen
    var most_important_event: Bool  // Event, welches in der MenuBar angezigt wird, hervorheben
    
    init(title: String, startDate: Date, endDate: Date, location: String, differenct_date: Bool, most_important_event: Bool) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.differenct_date = differenct_date
        self.most_important_event = most_important_event
    }
}


private var myEvents = getNextEvents()


// ToDo: Alle 5min neuladen

// ToDo: Settings:
    // menuBarTextType
    // Link zu GitHub
    // Aktualisierungsintervall wählen: 1min 5min 15min

@main
struct CustomApp: App {
    var body: some Scene {
        
        // Icon in MenuBar
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
    // func action2() {}
    // func action3() {}
    func quit() {
        exit(0)
    }
    
    func settings_open() {

    }
    
    
    func getBodyEventElements() -> some View {
        // ToDo Buttons zu Text
        
        return VStack {
            Button(action: action1, label: { Text("Heute").font(.system(size: 14, weight: .bold)) })
            
            ForEach(myEvents.indices, id: \.self) { index in
                // für die Unterteilung zischen Heute und Morgen
                if(myEvents[index].differenct_date) {
                    Divider()
                    Button(action: action1, label: { Text("Morgen").font(.system(size: 14, weight: .bold)) })
                }
                
                if myEvents[index].most_important_event { // Event, welches in der MenuBar angezigt wird, hervorheben
                    Button(action: action1, label: { Text(getActionText(num: index)).underline() })
                } else {
                    Button(action: action1, label: { Text(getActionText(num: index)) })
                }

            }

            // Button(action: action1, label: { Text(getActionText(num: 0)) })
            // Button(action: action1, label: { Text(getActionText(num: 1)) })
            // Button(action: action1, label: { Text(getActionText(num: 2)) })
        }
    }
    
    
    var body: some View {
        Button(action: action1, label: { Text("Termine der nächsten 24h") })
        Divider()
        
        getBodyEventElements()

        Divider()
        Button(action: settings_open, label: { Text("Settings") })
        Button(action: quit, label: { Text("Quit") })
    }
}

func dateOnly(date: Date) -> String { // entfernt die uhrzeit
    if date == nil {
        return ""
    }

    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateLocal = dateFormatter.string(from: date)
    
    return dateLocal.components(separatedBy: " ")[0]
}


func getNextEvents() -> [Event] {
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
    var date1components = DateComponents()
    date1components.day = -1
    let date1 = calendar.date(byAdding: date1components, to: Date(), wrappingComponents: false)
    
    // Enddatum festlegen
    var date2components = DateComponents()
    date2components.day = +1
    let date2 = calendar.date(byAdding: date2components, to: Date(), wrappingComponents: false)
    
    // Predicate erstellen
    var predicate: NSPredicate? = nil
    if let anAgo = date1, let aNow = date2 {
        predicate = eventStore.predicateForEvents(withStart: anAgo, end: aNow, calendars: nil)
    }
    
    // Events abrufen
    var events: [EKEvent]? = nil
    if let aPredicate = predicate {
        events = eventStore.events(matching: aPredicate)
    }
    

    let nowUTC = getUTCnow()
    // let utcDateString = dateFormatter.string(from: nowUTC)
    // print("Aktuelle UTC-Zeit: \(utcDateString)")
    
    
    var nextEvents: [Event] = []

    
    var lastEvent: Event? = nil
    var most_important_event_set = false
    
    // Events ausgeben
    if let events = events {
        for event in events {
            // print(event)
            // print("Title: \(event.title)")
            // print("Start Date: \(event.startDate)")
            // print("End Date: \(event.endDate)")
            // print("")
            
            // if(event.startDate > nowUTC) {
            if(event.endDate > nowUTC) {
                // return event.title
                
                var differenct_date = false // für die Unterteilung zischen Heute und Morgen
                if lastEvent != nil {
                    if (lastEvent != nil) && dateOnly(date: lastEvent!.startDate) != dateOnly(date: event.startDate) {
                        differenct_date = true
                    }
                }
                
                var most_important_event = false // Event, welches in der MenuBar angezigt wird, hervorheben
                let nowUTC = getUTCnow()
                if event.startDate > nowUTC && !most_important_event_set {
                    most_important_event = true
                    most_important_event_set = true
                }
                
                let thisEvent = Event(title: event.title, startDate: event.startDate, endDate: event.endDate, location: event.location ?? "", differenct_date:  differenct_date, most_important_event: most_important_event)
                
                nextEvents.append(thisEvent)
                lastEvent = thisEvent
            }
        }
    } else {
        print("Keine Events gefunden")
    }
    
    return nextEvents;
}


func getMenuBarText() -> String {
    // Sucht den ersten Termin, welcher in der Zukunft beginnt
        // und gibt diesen als "menuBarText" zurück
    
    var nextEvent: Event? = nil
    var lastEvent: Event? = nil
    
    let nowUTC = getUTCnow()
    for i in 0..<myEvents.count {
        if myEvents[i].startDate > nowUTC {
            nextEvent = myEvents[i]
            
            if(i > 0) {
                lastEvent = myEvents[i - 1]
            }
            break
        }
    }
    
    
    var menuBarText: String
    
    if nextEvent != nil && lastEvent != nil {
        menuBarText = eventToMenuBarText(nextEvent: nextEvent!, lastEvent: lastEvent!)
    } else if nextEvent != nil {
        menuBarText = eventToMenuBarText(nextEvent: nextEvent!)
    } else {
        menuBarText = "Keine Termine"
    }
    
    return menuBarText
}

func eventToMenuBarText(nextEvent: Event? = nil, lastEvent: Event? = nil) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    if nextEvent == nil {
        return ""
    }
    
    let startDateLocal = dateFormatter.string(from: nextEvent!.startDate)
    let startDateLocal_components = startDateLocal.components(separatedBy: " ")[1].split(separator: ":")
    let nextStartTime = startDateLocal_components.prefix(2).joined(separator: ":")
    
    let endDateLocal = dateFormatter.string(from: nextEvent!.endDate)
    let endDateLocal_components = endDateLocal.components(separatedBy: " ")[1].split(separator: ":")
    let nextEndTime = endDateLocal_components.prefix(2).joined(separator: ":")
    
    var lastEndTime = ""
    if lastEvent != nil {
        let lastEndDateLocal = dateFormatter.string(from: lastEvent!.endDate)
        let lastEndDateLocal_components = lastEndDateLocal.components(separatedBy: " ")[1].split(separator: ":")
        lastEndTime = lastEndDateLocal_components.prefix(2).joined(separator: ":")
    }
    
    
    if menuBarTextType == 0{ // "11:15"
        return nextStartTime
    } else if menuBarTextType == 1 { // "11:15 - 12:30"
        return "\(nextStartTime)-\(nextEndTime)"
    } else if menuBarTextType == 2 { // "- 10:30 11:15 -"
        if(nextEvent != nil && lastEvent != nil) {
            return "-\(lastEndTime) \(nextStartTime)-"  // "- 10:30 11:15 -"
        } else if (nextEvent != nil) {
            return "\(nextStartTime)-"  // "11:15 -"
        } else if (lastEvent != nil) {
            return "-\(lastEndTime)"  // "- 10:30"
        }
    }
    
    return "?"
}


func getActionText(num: Int) -> String {
    var actionText: String
    
    if myEvents.count <= num {
        actionText = ""
    } else {
        actionText = eventToActionText(event: myEvents[num])
    }
    
    return actionText
}

func eventToActionText(event: Event) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    let startDateLocal = dateFormatter.string(from: event.startDate)
    let startDateLocal_components = startDateLocal.components(separatedBy: " ")[1].split(separator: ":")
    let startTime = startDateLocal_components.prefix(2).joined(separator: ":")
    
    let endDateLocal = dateFormatter.string(from: event.endDate)
    let endDateLocal_components = endDateLocal.components(separatedBy: " ")[1].split(separator: ":")
    let endTime = endDateLocal_components.prefix(2).joined(separator: ":")
    
    let actionText = "\(startTime)-\(endTime) \(event.title) \(event.location)"
    
    return actionText
}

func getUTCnow() -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    let nowUTC = Date()
    return nowUTC
}
