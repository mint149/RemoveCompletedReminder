//
//  ContentView.swift
//  RemoveCompletedReminder
//
//  Created by hato on 2021/03/18.
//

import SwiftUI
import EventKit

struct ContentView: View {
    @State var reminderAccess = "unknown"
    @State var reminderList: [EKReminder] = []

    var body: some View {
        VStack(alignment: .leading){
            Text("reminderAccess:\(reminderAccess)")
            Divider()
            Button(action: {
                let eventStore = EKEventStore()
                let ekcal : [EKCalendar] = [eventStore.defaultCalendarForNewReminders()!]
                let predForCompleted = eventStore.predicateForCompletedReminders(withCompletionDateStarting: nil, ending: nil, calendars: ekcal)
                eventStore.fetchReminders(matching: predForCompleted) { (reminders) in
                    reminderList = reminders!
                    
                    for i in reminders!{
                        do{
                            try eventStore.remove(i, commit: true)
                        }catch let error{
                            print(error)
                        }
                    }
                }
            }) {
                Text("削除実行")
            }
            Divider()
            List{
                ForEach(reminderList, id: \.calendarItemIdentifier){ reminder in
                    Text(reminder.title)
                }
            }
            Spacer()
        }
        .padding()
        .onAppear(){
            switch EKEventStore.authorizationStatus(for: EKEntityType.reminder){
            case .notDetermined:
                let eventStore = EKEventStore()
                eventStore.requestAccess(to: .reminder) { (granted, error) in
                    if granted{
                        reminderAccess = "granted"
                    }else{
                        reminderAccess = "failed"
                        print(error ?? "unknown error")
                    }
                }
            case .restricted:
                reminderAccess = "restricted"
            case .denied:
                reminderAccess = "denied"
            case .authorized:
                reminderAccess = "authorized"
            @unknown default:
                reminderAccess = "unknown"
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
