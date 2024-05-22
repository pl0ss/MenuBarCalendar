//
//  MenuBarCalendarApp.swift
//  MenuBarCalendar
//
//  Created by Kevin Ploß on 15.05.24.
//

import SwiftUI
import EventKit
import Foundation
import Combine


// ToDo: Settings:
    // Versionsnummer
    // Link zu GitHub
    // Eigene Text festlegen zB “:)” [On / Off]
    // Toggle um unnötiges auszublenden: "MenuBarCalendar", "Termine der nächsten 24h", "Refresh", "Quit"
        // Refreshbutton und Quit in den Einstellungen

    // Calendar mode
        // [On / Off]
        // Aktualisierungsintervall [1 / 5 / 15 / 60] min
        // menuBarTextType mit Erkläerung [0, 1, 2]
        // Su- und Prefix
        // Text, wenn Kalender leer ist
        // Toggle, ob man die Color Dots haben will
        // locationReplace festlegen und togglen können
    
    // API mode
        // [On / Off]
        // Request interval [1 / 5 / 15 / 60] min
        // Erwartet
            // Text: String
            // ShortText: String
            // sendNotification: bool
            // ShortText in der MenuBar angezeigt [vor / nach Datum]
                // Langer Text angezeigen, wenn MenuBar anklicken [vor / nach Datum]
        // Su - und Prefix

    // Tricker hinzufügen:
        // wenn ein String auftaucht (SuchStrings als Array angeben) (und wo: Titel, Location),
        // dann möglichkeit zum Ersetzen
            // zB für [",Technische Hochschule Ingolstadt"]
        // oder Emoji in MenuBar Platzieren
            // zB wenn Titel ["Geburtstag", "Birtday"] enthalt
            // dann zB "🎂" Emoji in MenuBar platzieren und bei dem Termin
            // als "gelesen" markieren können, sodass dieser Emoji für heute nicht mehr angezeigt wird


// ToDo: in info.plist Application is agent auf YES stellen
    // falls deaktiviert (NO)
// ToDo: weitern Timer auf Beginnuhrzeit des Termins bzw der Enduhrzeit des aktuellen Termins stellen und dann View Refreshen und danach Timer erneut stellen


//* Setting
private var menuBarTextType = 3 // [0: "11:15", 1: "11:15 - 12:30", 2: "- 10:30 11:15 -", 3: "- 10:30 11:15 -"] 3 ist Kompaktere Version von 2
private var refreshInterval = 300 // in sec
private var showColorDots = 1; // [0: neineDots, 1: kleineDots: ⦁, 2: große Dots: ●]
private var locationReplace = [",Technische Hochschule Ingolstadt"]



class Event {
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String
    var color: NSColor
    var differenct_date: Bool // für die Unterteilung zischen verschiedenen Tagen
    var most_important_event: Bool  // Event, welches in der MenuBar angezigt wird, hervorheben
    var multiple_days_info: String // wenn ein event über mehrere tage geht, dann von bis anzeigen
    
    init(title: String, startDate: Date, endDate: Date, location: String, color: NSColor, differenct_date: Bool, most_important_event: Bool, multiple_days_info: String) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.color = color
        self.differenct_date = differenct_date
        self.most_important_event = most_important_event
        self.multiple_days_info = multiple_days_info
    }
}


@main
struct CustomApp: App {
    @StateObject private var eventManager = EventManager()
    
    var body: some Scene {
        // Icon in MenuBar
        // MenuBarExtra("UtilityApp", systemImage: "hammer") {
            // AppMenu()
        // }
        
        
        // Text in MenuBar

        MenuBarExtra(getMenuBarText(events: eventManager.events)) {
            AppMenu(eventManager: eventManager, events: eventManager.events)
                // "eventManager: eventManager" ist für "eventManager.refresh()" in "struct AppMenu"
        }
    }
}

struct AppMenu: View {
    @ObservedObject var eventManager: EventManager
    
    var events: [Event]
    
    func action1() {
        refresh()
    }
    
    func quit() {
        exit(0)
    }
    
    func refresh() {
        eventManager.refresh()
    }
    
    func settings_open() {
        
    }
    
    
    func getBodyEventElements() -> some View {
    // ToDo Buttons zu Text
        //* oder Buttons lassen, so haben die nämlich einen schönen Hover effect
        
        var dotShow: String = ""
        if showColorDots == 1 {
            dotShow = "⦁ " // <- Der ist größer als dieser "•"
        } else if showColorDots == 2 {
            dotShow = "● "
        }
        
        return VStack { // Auflistung der Termine
            ForEach(events.indices, id: \.self) { index in
                if index == 0 {
                    // meistens "Heute"
                    Button(action: action1, label: { Text(date_to_datumName_long(date: events[0].startDate)).font(.system(size: 14, weight: .bold)) })
                }
                
                // für die Unterteilung zischen verschiedenen Tagen
                if events[index].differenct_date {
                    // meistens "Morgen"
                    Divider()
                    Button(action: action1, label: { Text(date_to_datumName_long(date: events[index].startDate)).font(.system(size: 14, weight: .bold)) })
                }
                
                // Einzenler Termin
                if events[index].most_important_event { // Event, welches in der MenuBar angezigt wird, hervorheben
                    if showColorDots == 0 {
                        Button(action: action1, label: { Text(eventToActionText(event: events[index])).underline() })
                    } else {
                        Button(action: action1, label: { Text(dotShow).foregroundColor(Color(events[index].color)) + Text(eventToActionText(event: events[index])).underline() })
                    }
                } else {
                    if showColorDots == 0 {
                        Button(action: action1, label: { Text(eventToActionText(event: events[index])) })
                    } else {
                        Button(action: action1, label: { Text(dotShow).foregroundColor(Color(events[index].color)) + Text(eventToActionText(event: events[index])) })
                    }
                }
                
                if events[index].multiple_days_info != "" {
                    Text(events[index].multiple_days_info)
                }

            }

            // Button(action: action1, label: { Text(eventToActionText(num: 0)) })
            // Button(action: action1, label: { Text(eventToActionText(num: 1)) })
            // Button(action: action1, label: { Text(eventToActionText(num: 2)) })
        }
    }

    
    var body: some View {
        VStack {
            Button(action: action1, label: { Text("MenuBarCalendar").font(.system(size: 14, weight: .bold)) })
            Button(action: action1, label: { Text("Termine der nächsten 24h") })
            Divider()
            getBodyEventElements()
            Divider()
            Button(action: refresh, label: { Text("Refresh") })
            Button(action: settings_open, label: { Text("Settings") })
            Button(action: quit, label: { Text("Quit") })
        }
    }
}



// GPT
class EventManager: ObservableObject {
    @Published var events: [Event] = []
    
    private var timer: Timer?
    private let eventStore = EKEventStore()
    private let updateInterval: TimeInterval
    
    init(updateInterval: TimeInterval = TimeInterval(refreshInterval)) { // Default is 5 minutes (300 seconds)
        self.updateInterval = updateInterval
        requestAccess()
        startTimer()
        fetchEvents()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func requestAccess() {
        eventStore.requestFullAccessToEvents { (granted, error) in
            if granted {
                print("Zugriff auf Kalender genehmigt")
                self.fetchEvents()
            } else {
                print("Zugriff auf Kalender abgelehnt oder Fehler aufgetreten: \(error?.localizedDescription ?? "Unbekannter Fehler")")
            }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            self.fetchEvents()
        }
    }
    
    func fetchEvents() {
        let nowUTC = Date()
        let end = Calendar.current.date(byAdding: .day, value: 1, to: nowUTC)!
        
        let predicate = eventStore.predicateForEvents(withStart: nowUTC, end: end, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)
        
        var lastEvent: EKEvent? = nil
        let now = date_getNow()
        var most_important_event_set = false
        
        DispatchQueue.main.async {
            self.events = ekEvents.map { thisEvent in
                
                let title = thisEvent.title.trimmingCharacters(in: .whitespacesAndNewlines)
                
                var location = thisEvent.location ?? ""
                for str in locationReplace {
                    location = location.replacingOccurrences(of: str, with: "")
                }
                
                var differenct_date = false // für die Unterteilung zischen verschiedenen Tagen
                if (lastEvent != nil) && date_to_date_string(date: lastEvent!.startDate) != date_to_date_string(date: thisEvent.startDate) {
                    differenct_date = true
                }
                
                var most_important_event = false // Event, welches in der MenuBar angezigt wird, hervorheben
                if date_to_local(date: thisEvent.startDate) > now && !most_important_event_set {
                    most_important_event = true
                    most_important_event_set = true
                }
                
                var multiple_days_info = ""
                let dateStringStart = date_to_datumName(date: thisEvent.startDate)
                let dateStringEnd = date_to_datumName(date: thisEvent.endDate)
                if dateStringStart != dateStringEnd {
                    multiple_days_info = "   \(dateStringStart) - \(dateStringEnd)"
                }
                
                lastEvent = thisEvent

                
                return Event(
                    title: title,
                    startDate: thisEvent.startDate,
                    endDate: thisEvent.endDate,
                    location: location,
                    color: thisEvent.calendar.color,
                    differenct_date: differenct_date,
                    most_important_event: most_important_event,
                    multiple_days_info: multiple_days_info
                )
            }
        }
    }
    
    func refresh() {
        fetchEvents()
    }
}


func getMenuBarText(events: [Event]) -> String {
    // Sucht den ersten Termin, welcher in der Zukunft beginnt
        // und gibt diesen als "menuBarText" zurück
    
    var nextEvent: Event? = nil
    var lastEvent: Event? = nil
    
    let now = date_getNow()
    for i in 0..<events.count {
        if date_to_local(date: events[i].startDate) > now {
            nextEvent = events[i]
            
            if i > 0 {
                lastEvent = events[i - 1]
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

    var lastStartTime = ""
    if lastEvent != nil {
        let lastStartDateLocal = dateFormatter.string(from: lastEvent!.endDate)
        let lastStartDateLocal_components = lastStartDateLocal.components(separatedBy: " ")[1].split(separator: ":")
        lastStartTime = lastStartDateLocal_components.prefix(2).joined(separator: ":")
    }
    
    var lastEndTime = ""
    if lastEvent != nil {
        let lastEndDateLocal = dateFormatter.string(from: lastEvent!.endDate)
        let lastEndDateLocal_components = lastEndDateLocal.components(separatedBy: " ")[1].split(separator: ":")
        lastEndTime = lastEndDateLocal_components.prefix(2).joined(separator: ":")
    }
    
    var nextStartTime = ""
    if nextEvent != nil {
        let startDateLocal = dateFormatter.string(from: nextEvent!.startDate)
        let startDateLocal_components = startDateLocal.components(separatedBy: " ")[1].split(separator: ":")
        nextStartTime = startDateLocal_components.prefix(2).joined(separator: ":")
    }
    
    var nextEndTime = ""
    if nextEvent != nil {
        let endDateLocal = dateFormatter.string(from: nextEvent!.endDate)
        let endDateLocal_components = endDateLocal.components(separatedBy: " ")[1].split(separator: ":")
        nextEndTime = endDateLocal_components.prefix(2).joined(separator: ":")
    }

    
    
    if menuBarTextType == 0{ // "11:15"
        return nextStartTime
    } else if menuBarTextType == 1 { // "11:15-12:30"
        return "\(nextStartTime)-\(nextEndTime)"
    }
    // "menuBarTextType == 2" zeigt relevante Infos zum nächsten Termin an, falls vorhanden, wenn nicht dann Infos zum aktuellen
    else if menuBarTextType == 2 { // ["-10:30 11:15-", "11:15-12:30", "09:00-10:30"]
        if nextEvent != nil && lastEvent != nil {
            // in einem Termin und ein weiter Folgt
            return "-\(lastEndTime) \(nextStartTime)-"  // "-10:30 11:15-"
        } else if nextEvent != nil {
            // in keinem Termin und ein Termin folgt
            // return "\(nextStartTime)-"  // "11:15-"
            return "\(nextStartTime)-\(nextEndTime)"  // "11:15-12:30"
        } else if lastEvent != nil {
            // in einem Termin und kein weiter Folgt
            // return "-\(lastEndTime)"  // "-10:30"
            return "\(lastStartTime)-\(lastEndTime)"  // "09:00-10:30"
        }
    }
    // "menuBarTextType == 3" ist eine kompaktere Version von "menuBarTextType == 2"
    else if menuBarTextType == 3 { // ["-10:30 11:15-", "11:15-", "-10:30"]
        if nextEvent != nil && lastEvent != nil {
            // in einem Termin und ein weiter Folgt
            return "-\(lastEndTime) \(nextStartTime)-"  // "-10:30 11:15-"
        } else if nextEvent != nil {
            // in keinem Termin und ein Termin folgt
            return "\(nextStartTime)-"  // "11:15-"
        } else if lastEvent != nil {
            // in einem Termin und kein weiter Folgt
            return "-\(lastEndTime)"  // "-10:30"
        }
    }
    
    return "?"
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
