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
        // menuBarTextType mit Erkläerung [0, 1, 2, 3]
            // möglichkeit für eigenes Format
        // Su- und Prefix
        // Text, wenn Kalender leer ist
        // Toggle, ob man die Color Dots haben will
        // locationReplace festlegen und togglen können

        // Events ingonieren
            // Sodass diese nicht in der MenuBar angezeigt werden (aber Trotzdem in der Event Liste)
            // Option: Alle ganztägigen Termine oder welche die einen Bestimmten String behinhalten
                // zB ["Geburtstag", "Birtday"]
    
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
        // für bestimmten Kalender (calendarName) oder alle
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
private var menuBarTextType = 2
    // 0: "11:15"
    // 1: "- 10:30 11:15 -"  // zeigt immer Zwei zeiten an
    // 2: "- 10:30 11:15 -" // Zeigt nur Zwei zeiten an, wenn beide Zeiten in der Zukunft liegen (2 ist Kompaktere Version von 1)
    // 3: "-10:30" // Zeigt nur eine Uhrzeit an (3 ist Kompaktere Version von 2)
private var refreshInterval = 300 // in sec
private var showColorDots = 1; // [0: neineDots, 1: kleineDots: ⦁, 2: große Dots: ●]
private var eventNameReplace = [["IB_", ""]]
private var eventLocationReplace = [[",Technische Hochschule Ingolstadt", ""]]
private var noEventString = ":)" // kein kein Termin in den nächsten 24h
private var calendarDate: Date?; // Von wann die Kalenderdaten sind


class Event {
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String
    var color: NSColor
    var calendarName: String
    var differenct_date: Bool // für die Unterteilung zischen verschiedenen Tagen
    var most_important_event: Bool  // Event, welches in der MenuBar angezigt wird, hervorheben
    var multiple_days_info: String // wenn ein event über mehrere tage geht, dann von bis anzeigen
    
    init(title: String, startDate: Date, endDate: Date, location: String, color: NSColor, calendarName: String, differenct_date: Bool, most_important_event: Bool, multiple_days_info: String) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.color = color
        self.calendarName = calendarName
        self.differenct_date = differenct_date
        self.most_important_event = most_important_event
        self.multiple_days_info = multiple_days_info
    }
}

//* VIEWS
// =======================================================================
// =======================================================================


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
    
    
    func getViewEventList() -> some View {
    // ToDo Buttons zu Text
        //* oder Buttons lassen, so haben die nämlich einen schönen Hover effect

        
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
                    Button(action: action1, label: { Text(getDOT_ele()).foregroundColor(Color(events[index].color)) + Text(getEVENT_ele(event: events[index])).underline() })
                } else {
                    Button(action: action1, label: { Text(getDOT_ele()).foregroundColor(Color(events[index].color)) + Text(getEVENT_ele(event: events[index])) })
                }
                
                if events[index].multiple_days_info != "" {
                    Text(events[index].multiple_days_info)
                }

            }
        }

    }

    func getViewEventListTexts() -> some View {
        let lines = getEventList_texts().enumerated().map { index, line in
            (index, line.trimmingCharacters(in: .whitespacesAndNewlines))
        }
            // sodass ich einen index für die id bekomme
                // den jedes element darf nur einmal vorkommen, da es sonst einen Warnung in xcode gibt
        
        return VStack {
            ForEach(lines, id: \.0) { index, line in

                if(line == "$DIVIDER") {
                    Divider().id(index)
                } else if(line == "$EMPTYLINE") {
                    Button(action: action1, label: { Text("") }).id(index)
                } else if(line != "") {
                    Button(action: action1, label: { Text(line) }).id(index)
                }
            }
        }
    }

    
    var body: some View {
        VStack {
            Button(action: action1, label: { Text("MenuBarCalendar").font(.system(size: 14, weight: .bold)) })

            getViewEventListTexts()

            getViewEventList()

            Divider()
            Button(action: refresh, label: { Text("Refresh") })
            Button(action: settings_open, label: { Text("Settings") })
            Button(action: quit, label: { Text("Quit") })
        }
    }
}

func getEventList_texts() -> [String] {
    var return_string = ""
    
    //* return_string = "$DEFAULT" // Default
    //* return_string = "$DIVIDER$IMPORTANT$DIVIDER$APISHORT$LINEBREAK$APILONG" // zeige API Text
    // return_string = "$DIVIDERStand: $CALENDARDATE Uhr$DIVIDERHi$EMPTYLINE$EMPTYLINE$LINEBREAK$DEFAULT$DIVIDER$APISHORT$LINEBREAK$APILONG" // einfach ein test

    return_string += "$DIVIDER" // sodass immer mit eine div beendet wird

    while return_string.contains("$DIVIDER$DIVIDER") {
        return_string.replace("$DIVIDER$DIVIDER", with: "$DIVIDER")
    }

    //                    "$LINEBREAK"
    return_string.replace("$DEFAULT", with: "Termine der nächsten 24h")
    return_string.replace("$APISHORT", with: getAPISHORT_ele())
    return_string.replace("$APILONG", with: getAPILONG_ele())
    return_string.replace("$APIDATE", with: getAPIDATE())
    return_string.replace("$CALENDARDATE", with: getCALENDARDATE())
    return_string.replace("$IMPORTANT", with: getIMPORTANT_ele()) //* $IMPORTANT umbennen?
    return_string.replace("$DIVIDER", with: "$LINEBREAK$DIVIDER$LINEBREAK") // sodass $DIVIDER ein einzelnes element im array ist
    return_string.replace("$EMPTYLINE", with: "$LINEBREAK$EMPTYLINE$LINEBREAK") 

    var lines = return_string.components(separatedBy: "$LINEBREAK")
    if lines.first == "" {
        lines.removeFirst()
    }
    if lines.last == "" {
        lines.removeLast()
    }

    return lines
}

//* Kaländer auslesen
// =======================================================================
// =======================================================================

//* von GPT
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
        calendarDate = date_getNow()
        
        let nowUTC = Date()
        let end = Calendar.current.date(byAdding: .day, value: 1, to: nowUTC)!
        
        let predicate = eventStore.predicateForEvents(withStart: nowUTC, end: end, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)
        
        var lastEvent: EKEvent? = nil
        let now = date_getNow()
        var most_important_event_set = false
        
        DispatchQueue.main.async {
            self.events = ekEvents.map { thisEvent in
                
                var title = thisEvent.title.trimmingCharacters(in: .whitespacesAndNewlines)
                for ele in eventNameReplace {
                    title = title.replacingOccurrences(of: ele[0], with: ele[1])
                }
                
                var location = thisEvent.location ?? ""
                for ele in eventLocationReplace {
                    location = location.replacingOccurrences(of: ele[0], with: ele[1])
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
                    calendarName: thisEvent.calendar.title,
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


//* get Functions
// =======================================================================
// =======================================================================


func getMenuBarText(events: [Event]) -> String {
    var return_string = "$APISHORT $IMPORTANT $TIMES"

    //* $IMPORTANT umbennen?
    return_string.replace("$APISHORT", with: getAPISHORT_ele())
    return_string.replace("$APILONG", with: getAPILONG_ele())
    return_string.replace("$IMPORTANT", with: getIMPORTANT_ele())
    return_string.replace("$TIMES", with: getTIMES_ele(events: events))
    
    return return_string
}

func getTIMES_ele(events: [Event]) -> String {
    // Sucht den ersten Termin, welcher in der Zukunft beginnt
        // und gibt diesen als "menuBarText" zurück
    
    var currentEvent: Event? = nil
    var nextEvent: Event? = nil
    
    let now = date_getNow()
    for i in 0..<events.count {
        if date_to_local(date: events[i].startDate) > now {
            nextEvent = events[i]
            
            if i > 0 {
                currentEvent = events[i - 1]
            }
            break
        }
    }

    
    
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    if nextEvent == nil {
        return ""
    }

    var currentEventStartTime = ""
    if currentEvent != nil {
        let lastStartDateLocal = dateFormatter.string(from: currentEvent!.endDate)
        let lastStartDateLocal_components = lastStartDateLocal.components(separatedBy: " ")[1].split(separator: ":")
        currentEventStartTime = lastStartDateLocal_components.prefix(2).joined(separator: ":")
    }
    
    var currentEventEndTime = ""
    if currentEvent != nil {
        let lastEndDateLocal = dateFormatter.string(from: currentEvent!.endDate)
        let lastEndDateLocal_components = lastEndDateLocal.components(separatedBy: " ")[1].split(separator: ":")
        currentEventEndTime = lastEndDateLocal_components.prefix(2).joined(separator: ":")
    }
    
    var nextEventStartTime = ""
    if nextEvent != nil {
        let startDateLocal = dateFormatter.string(from: nextEvent!.startDate)
        let startDateLocal_components = startDateLocal.components(separatedBy: " ")[1].split(separator: ":")
        nextEventStartTime = startDateLocal_components.prefix(2).joined(separator: ":")
    }
    
    var nextEventEndTime = ""
    if nextEvent != nil {
        let endDateLocal = dateFormatter.string(from: nextEvent!.endDate)
        let endDateLocal_components = endDateLocal.components(separatedBy: " ")[1].split(separator: ":")
        nextEventEndTime = endDateLocal_components.prefix(2).joined(separator: ":")
    }
    
    var return_string = "$EMPTY" // $START, $END, $NEXTSTART, $NEXTEND, $EMPTY (wenn kein Event mehr in den nächsten 24h)
    
    
    // Zeigt nur BeginnUhrzeit, falls ein Termin Vorhanden ist
    if menuBarTextType == 0 {// ["11:15", "-"]
       if nextEvent != nil && currentEvent != nil {
           // in einem Termin und ein weiter Folgt // "11:15"
           return_string = "$NEXTSTART"
       } else if nextEvent != nil {
           // in keinem Termin und ein Termin folgt
           return_string = "$NEXTSTART" // "11:15"
       } else if currentEvent != nil {
           // in einem Termin und kein weiter Folgt // "-"
           return_string = "$EMPTY"
       }
    }
    // "menuBarTextType == 1" zeigt relevante Infos zum nächsten Termin an, falls vorhanden, wenn nicht dann Infos zum aktuellen
    else if menuBarTextType == 1 { // ["-10:30 11:15-", "11:15-12:30", "09:00-10:30"]
        if nextEvent != nil && currentEvent != nil {
            // in einem Termin und ein weiter Folgt // "-10:30 11:15-"
            return_string = "-$END $NEXTSTART-"
        } else if nextEvent != nil {
            // in keinem Termin und ein Termin folgt // "11:15-12:30"
            return_string = "$NEXTSTART-$NEXTEND"
        } else if currentEvent != nil {
            // in einem Termin und kein weiter Folgt // "-10:30"
            return_string = "$START-$END"
        }
    }
    // "menuBarTextType == 2" ist eine kompaktere Version von "menuBarTextType == 1"
    else if menuBarTextType == 2 { // ["-10:30 11:15-", "11:15-", "-10:30"]
        if nextEvent != nil && currentEvent != nil {
            // in einem Termin und ein weiter Folgt // "-10:30 11:15-"
            return_string = "-$END $NEXTSTART-"
        } else if nextEvent != nil {
            // in keinem Termin und ein Termin folgt // "11:15-"
            return_string = "$NEXTSTART-"
        } else if currentEvent != nil {
            // in einem Termin und kein weiter Folgt // "-10:30"
            return_string = "-$END"
        }
    }
    // "menuBarTextType == 3" ist eine kompaktere Version von "menuBarTextType == 2"
    else if menuBarTextType == 3 { // ["11:15-", "11:15-", "-10:30"]
        if nextEvent != nil && currentEvent != nil {
            // in einem Termin und ein weiter Folgt // "11:15-"
            return_string = "$NEXTSTART-"
        } else if nextEvent != nil {
            // in keinem Termin und ein Termin folgt // "11:15-"
            return_string = "$NEXTSTART-"
        } else if currentEvent != nil {
            // in einem Termin und kein weiter Folgt // "-10:30"
            return_string = "-$END"
        }
    }
    
    return_string.replace("$EMPTY", with: noEventString)
    return_string.replace("$START", with: currentEventStartTime)
    return_string.replace("$END", with: currentEventEndTime)
    return_string.replace("$NEXTSTART", with: nextEventStartTime)
    return_string.replace("$NEXTEND", with: nextEventEndTime)
    return_string.replace("$STARTNEXT", with: nextEventStartTime) // falls man sich "verschrieben" hat
    return_string.replace("$ENDNEXT", with: nextEventEndTime) // falls man sich "verschrieben" hat
    
    return return_string
}

func getAPISHORT_ele() -> String {
    return ""
    // return "API"
}
func getAPILONG_ele() -> String {
    return ""
    // return "APILONG"
}

func getIMPORTANT_ele() -> String {
    return ""
    // return "IMPORTANT"
}

func getAPIDATE() -> String {
    let date = date_getNow() // ToDo
    return date_to_time_string(date: date)
}

func getCALENDARDATE() -> String {
    return date_to_time_string(date: calendarDate!)
}


func getEVENT_ele(event: Event) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    let startDate = dateFormatter.string(from: event.startDate)
    let startDate_components = startDate.components(separatedBy: " ")[1].split(separator: ":")
    let eventStartTime = startDate_components.prefix(2).joined(separator: ":")
    
    let endDate = dateFormatter.string(from: event.endDate)
    let endDate_components = endDate.components(separatedBy: " ")[1].split(separator: ":")
    let eventEndTime = endDate_components.prefix(2).joined(separator: ":")
    
    // let actionText = "\(eventStartTime)-\(eventEndTime) \(event.title) \(event.location)"
    
    var return_string = "$EVENTSTART-$EVENTEND $TITLE $LOCATION"

    return_string.replace("$EVENTSTART", with: eventStartTime)
    return_string.replace("$EVENTEND", with: eventEndTime)
    return_string.replace("$TITLE", with: event.title)
    return_string.replace("$LOCATION", with: event.location)
    return_string.replace("$CALENDARNAME", with: event.calendarName)
        return_string.replace("$CALNAME", with: event.calendarName)
    
    return return_string
}

func getDOT_ele () -> String {
    var return_string = ""

    if showColorDots == 1 {
        return_string = "$DOTSMALL " 
    } else if showColorDots == 2 {
        return_string = "$DOTLARGE "
    }

    return_string.replace("$DOTSMALL", with: "⦁") // <- Der ist größer als dieser "•"
    return_string.replace("$DOTLARGE", with: "●")
    
    return return_string
}


//* MARKBasics Date Functions
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
