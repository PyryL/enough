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
        let sinceReference = UserDefaults.suite.double(forKey: UserDefaultsKeys.targetDate)
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
            let isGreen: Bool?

            if let targetDate = loadTimerTargetDate() {
                isGreen = targetDate.timeIntervalSinceNow < 0
            } else {
                isGreen = nil
            }

            entry = TimerWidgetEntry(date: .now, isGreen: isGreen)
        }
        completion(entry)
    }

    /// Get the current and all known future states of the widget (real data).
    /// Use reload policy `never` here and use `WidgetCenter.reloadTimelines` in the UI.
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries: [TimerWidgetEntry]

        if let timerTargetDate = loadTimerTargetDate() {
            if timerTargetDate.timeIntervalSinceNow < 0 {
                // timer target date is already past
                entries = [
                    TimerWidgetEntry(date: .now, isGreen: true)
                ]
            } else {
                // timer target date is upcoming
                entries = [
                    TimerWidgetEntry(date: .now, isGreen: false),
                    TimerWidgetEntry(date: timerTargetDate, isGreen: true)
                ]
            }
        } else {
            // timer not started
            entries = [TimerWidgetEntry(date: .now, isGreen: nil)]
        }

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct TimerWidgetEntry: TimelineEntry {
    let date: Date
    /// `true` if the timer is green, `false` if it's red and `nil` if the timer is not started.
    let isGreen: Bool?
}

struct TimerWidgetView: View {
    var entry: TimerWidgetProvider.Entry

    @available(iOS 17.0, *)
    private var color: any ShapeStyle {
        switch entry.isGreen {
        case .none:
            return .fill.tertiary
        case .some(true):
            return .green
        case .some(false):
            return .red
        }
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            ZStack {
                Color.clear

                if entry.isGreen == nil {
                    startTimerPrompt
                }
            }
            .modifier(ContainerBackgroundModifier(isGreen: entry.isGreen))
        } else {
            ZStack {
                Color.clear

                if entry.isGreen == nil {
                    startTimerPrompt
                        .padding()
                }
            }
            .background(entry.isGreen == nil ? Color(uiColor: .tertiarySystemBackground) : entry.isGreen! ? Color.green : Color.red)
        }
    }

    private var startTimerPrompt: some View {
        Text("Set the timer in the app")
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }

    @available(iOS 17.0, *)
    private struct ContainerBackgroundModifier: ViewModifier {
        var isGreen: Bool?

        func body(content: Content) -> some View {
            Group {
                switch isGreen {
                case .none:
                    content.containerBackground(.fill.tertiary, for: .widget)
                case .some(true):
                    content.containerBackground(.green, for: .widget)
                case .some(false):
                    content.containerBackground(.red, for: .widget)
                }
            }
        }
    }
}

struct TimerWidget: Widget {
    let kind: String = "info.pyry.apps.digitlessTimer.widgets.timerWidget"

    private let families: [WidgetFamily] = [
        .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge
    ]

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimerWidgetProvider()) { entry in
            TimerWidgetView(entry: entry)
        }
        .configurationDisplayName("Timer Widget")
        .description("Widget showing either red or green.")
        .supportedFamilies(families)
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
            TimerWidgetView(entry: TimerWidgetEntry(date: .now, isGreen: nil))
        }
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
