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
    var differenct_date: Bool // für die Unterteilung zischen verschiedenen Tagen
    var most_important_event: Bool  // Event, welches in der MenuBar angezigt wird, hervorheben
    var multiple_days_info: String // wenn ein event über mehrere tage geht, dann von bis anzeigen
    
    init(title: String, startDate: Date, endDate: Date, location: String, differenct_date: Bool, most_important_event: Bool, multiple_days_info: String) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.differenct_date = differenct_date
        self.most_important_event = most_important_event
        self.multiple_days_info = multiple_days_info
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
            // oder Buttons lassen, so haben die nämlich einen schönen Hover effect
        
        return VStack {
            
            ForEach(myEvents.indices, id: \.self) { index in
                if(index == 0) {
                    // meistens "Heute"
                    Button(action: action1, label: { Text(date_to_datumName_long(date: myEvents[0].startDate)).font(.system(size: 14, weight: .bold)) })
                }
                
                // für die Unterteilung zischen verschiedenen Tagen
                if(myEvents[index].differenct_date) {
                    // meistens "Morgen"
                    Divider()
                    Button(action: action1, label: { Text(date_to_datumName_long(date: myEvents[index].startDate)).font(.system(size: 14, weight: .bold)) })
                }
                
                if myEvents[index].most_important_event { // Event, welches in der MenuBar angezigt wird, hervorheben
                    Button(action: action1, label: { Text(getActionText(num: index)).underline() })
                } else {
                    Button(action: action1, label: { Text(getActionText(num: index)) })
                }
                
                if(myEvents[index].multiple_days_info != "") {
                    Text(myEvents[index].multiple_days_info)
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

func getNextEvents() -> [Event] {
    let eventStore = EKEventStore()
    
    eventStore.requestFullAccessToEvents { (granted, error) in
        if granted {
            print("Zugriff auf Kalender genehmigt")
        } else {
            print("Zugriff auf Kalender abgelehnt oder Fehler aufgetreten: \(error?.localizedDescription ?? "Unbekannter Fehler")")
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
    
    var nextEvents: [Event] = []
    var lastEvent: Event? = nil
    let now = date_getNow()
    var most_important_event_set = false
    
    // Events ausgeben
    if let events = events {
        for event in events {
            // print(event)
            // print("Title: \(event.title)")
            // print("Start Date: \(event.startDate)")
            // print("End Date: \(event.endDate)")
            // print("")
            
            if(date_to_local(date: event.endDate) > now) {
                // return event.title
                
                var differenct_date = false // für die Unterteilung zischen verschiedenen Tagen
                if lastEvent != nil {
                    if (lastEvent != nil) && date_to_date_string(date: lastEvent!.startDate) != date_to_date_string(date: event.startDate) {
                        differenct_date = true
                    }
                }
                
                var most_important_event = false // Event, welches in der MenuBar angezigt wird, hervorheben
                let now = date_getNow()
                if date_to_local(date: event.startDate) > now && !most_important_event_set {
                    most_important_event = true
                    most_important_event_set = true
                }
                
                var multiple_days_info = ""
                let dateStringStart = date_to_datumName(date: event.startDate)
                let dateStringEnd = date_to_datumName(date: event.endDate)
                if dateStringStart != dateStringEnd {
                    multiple_days_info = " • \(dateStringStart) - \(dateStringEnd)"
                }
                
                
                let thisEvent = Event(title: event.title, startDate: event.startDate, endDate: event.endDate, location: event.location ?? "", differenct_date:  differenct_date, most_important_event: most_important_event, multiple_days_info: multiple_days_info)
                
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
    
    let now = date_getNow()
    for i in 0..<myEvents.count {
        if date_to_local(date: myEvents[i].startDate) > now {
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


//* Basics Date Functions
// =======================================================================
// =======================================================================

func date_to_local(date: Date) -> Date {
    let calendar = Calendar.current
    let timeZone = TimeZone.current
    let components = calendar.dateComponents(in: timeZone, from: date)
    
    return calendar.date(from: components)!
}

func date_getUTCnow() -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let nowUTC = Date()
    return nowUTC
}

func date_getNow() -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let now = Date()
    return now
}

func string_to_date(str: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.date(from: str)!
}

func date_offset(date: Date = date_getNow(), years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0, mitternacht: Bool = false) -> Date {
    var calendar = Calendar.current
    var dateComponents = DateComponents()
    
    dateComponents.year = years
    dateComponents.month = months
    dateComponents.day = days
    dateComponents.hour = hours
    dateComponents.minute = minutes
    dateComponents.second = seconds
    
    guard let newDate = calendar.date(byAdding: dateComponents, to: date) else {
        return date
    }
    
    if mitternacht {
        return calendar.startOfDay(for: newDate)
    }
    
    return newDate
}

func date_to_dateTime_string(date: Date) -> String { // "yyyy-MM-dd HH:mm:ss"
    if date == nil {return ""}
    
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateStringLocal = dateFormatter.string(from: date)
    
    return dateStringLocal
}

func date_to_datumZeit_string(date: Date) -> String { // "dd.MM.yyyy HH:mm:ss"
    if date == nil {return ""}
    
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
    let dateStringLocal = dateFormatter.string(from: date)
    
    return dateStringLocal
}

func date_to_date_string(date: Date) -> String { // "yyyy-MM-dd"
    let dateString = date_to_dateTime_string(date: date)
    
    return dateString.components(separatedBy: " ")[0]
}

func date_to_datum_string(date: Date) -> String { // "dd.MM.yyyy"
    let dateString = date_to_datumZeit_string(date: date)
    
    return dateString.components(separatedBy: " ")[0]
}

func date_to_time_string(date: Date) -> String { // "HH:mm"
    let dateString = date_to_dateTime_string(date: date)
    let dateComponents = dateString.components(separatedBy: " ")[1].components(separatedBy: ":")
    
    return "\(dateComponents[0]):\(dateComponents[1])"
}

func date_to_timeSec_string(date: Date) -> String { // "HH:mm:ss"
    let dateString = date_to_dateTime_string(date: date)
    
    return dateString.components(separatedBy: " ")[1]
}


func date_to_dateName(date: Date) -> String { // ["Yesterday", "Today", "Tomorrow"], "yyyy-MM-dd"
    let dateString = date_to_date_string(date: date)
    let dateStringToday = date_to_date_string(date: date_getNow())
    let dateStringTomorrow = date_to_date_string(date: date_offset(days: 1))
    let dateStringYesterday = date_to_date_string(date: date_offset(days: -1))
    
    if dateString == dateStringToday {
        return "Today"
    } else if dateString == dateStringTomorrow {
        return "Tomorrow"
    } else if dateString == dateStringYesterday {
        return "Yesterday"
    }
    
    return dateString
}

func date_to_datumName(date: Date) -> String { // ["Gestern", "Heute", "Morgen"], "yyyy-MM-dd"
    let dateString = date_to_datum_string(date: date)
    let dateStringToday = date_to_datum_string(date: date_getNow())
    let dateStringTomorrow = date_to_datum_string(date: date_offset(days: 1))
    let dateStringYesterday = date_to_datum_string(date: date_offset(days: -1))
    
    if dateString == dateStringToday {
        return "Heute"
    } else if dateString == dateStringTomorrow {
        return "Morgen"
    } else if dateString == dateStringYesterday {
        return "Gestern"
    }
    
    return dateString
}

func date_to_dateName_long(date: Date) -> String { // ["Yesterday", "Today", "Tomorrow"], "yyyy-MM-dd"
    let dateString = date_to_date_string(date: date)
    let dateStringToday = date_to_date_string(date: date_getNow())
    let dateStringTomorrow = date_to_date_string(date: date_offset(days: 1))
    let dateStringYesterday = date_to_date_string(date: date_offset(days: -1))
    
    if dateString == dateStringToday {
        return "Today \(dateString)"
    } else if dateString == dateStringTomorrow {
        return "Tomorrow \(dateString)"
    } else if dateString == dateStringYesterday {
        return "Yesterday \(dateString)"
    }
    
    return dateString
}

func date_to_datumName_long(date: Date) -> String { // ["Gestern", "Heute", "Morgen"], "yyyy-MM-dd"
    let dateString = date_to_datum_string(date: date)
    let dateStringToday = date_to_datum_string(date: date_getNow())
    let dateStringTomorrow = date_to_datum_string(date: date_offset(days: 1))
    let dateStringYesterday = date_to_datum_string(date: date_offset(days: -1))
    
    if dateString == dateStringToday {
        return "Heute \(dateString)"
    } else if dateString == dateStringTomorrow {
        return "Morgen \(dateString)"
    } else if dateString == dateStringYesterday {
        return "Gestern \(dateString)"
    }
    
    return dateString
}
