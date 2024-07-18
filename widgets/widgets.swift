//
//  widgets.swift
//  widgets
//
//  Created by Pyry Lahtinen on 18.7.2024.
//

import WidgetKit
import SwiftUI

struct TimerWidgetProvider: TimelineProvider {
    private func loadTimerTargetDate() -> Date? {
        // TODO: this does not work yet, since user defaults uses standard
        let sinceReference = UserDefaults.suite.double(forKey: UserDefaultsKeys.targetDate)
        print("loading user defaults", sinceReference, UserDefaults.suite.integer(forKey: UserDefaultsKeys.timerSecs))
        guard sinceReference > 0 else {
            return nil
        }
        return Date(timeIntervalSinceReferenceDate: sinceReference)
    }

    /// Quick example without real data.
    func placeholder(in context: Context) -> TimerWidgetEntry {
        TimerWidgetEntry(date: .now, isGreen: true)
    }

    /// Get the current state of the widget (real data).
    /// Use placeholder data if `context.preview` is true and real data is slow to load.
    func getSnapshot(in context: Context, completion: @escaping (TimerWidgetEntry) -> ()) {
        let entry: TimerWidgetEntry
        if context.isPreview {
            // use sample data
            entry = TimerWidgetEntry(date: .now, isGreen: true)
        } else {
            let isGreen: Bool

            if let targetDate = loadTimerTargetDate() {
                isGreen = targetDate.timeIntervalSinceNow < 0
            } else {
                isGreen = true
            }

            entry = TimerWidgetEntry(date: .now, isGreen: isGreen)
        }
        completion(entry)
    }

    /// Get the current and all known future states of the widget (real data).
    /// Use reload policy `never` here and use `WidgetCenter.reloadTimelines` in the UI.
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [TimerWidgetEntry] = []

        if let timerTargetDate = loadTimerTargetDate(), timerTargetDate.timeIntervalSinceNow >= 0 {
            entries = [
                TimerWidgetEntry(date: .now, isGreen: false),
                TimerWidgetEntry(date: timerTargetDate, isGreen: true)
            ]
        } else {
            entries = [TimerWidgetEntry(date: .now, isGreen: true)]
        }

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct TimerWidgetEntry: TimelineEntry {
    let date: Date
    let isGreen: Bool
}

struct TimerWidgetView: View {
    var entry: TimerWidgetProvider.Entry

    private var color: Color {
        entry.isGreen ? .green : .red
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            Color.clear
                .containerBackground(color, for: .widget)
        } else {
            Color.clear
                .background(color)
        }
    }
}

struct widgets: Widget {
    let kind: String = "info.pyry.apps.digitlessTimer.widgets.timerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimerWidgetProvider()) { entry in
            TimerWidgetView(entry: entry)
        }
        .configurationDisplayName("Timer Widget")
        .description("Widget showing either red or green.")
    }
}

//#Preview(as: .systemSmall) {
//    widgets()
//} timeline: {
//    TimerWidgetEntry(date: .now, isGreen: false)
//    TimerWidgetEntry(date: .now, isGreen: true)
//}

struct TimerWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimerWidgetView(entry: TimerWidgetEntry(date: .now, isGreen: false))
            TimerWidgetView(entry: TimerWidgetEntry(date: .now, isGreen: true))
        }
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
