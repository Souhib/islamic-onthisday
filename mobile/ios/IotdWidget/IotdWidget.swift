//
//  IotdWidget.swift
//  IotdWidget
//
//  Two home-screen widgets — Small (date pylon) + Medium (date +
//  headline) — fed from the App Group `group.app.iotd.mobile`
//  shared `UserDefaults`. The Flutter side writes through
//  `home_widget` (see `lib/core/widgets_bridge/home_widget_writer.dart`);
//  keys must stay in sync.
//

import WidgetKit
import SwiftUI

private enum IotdConstants {
    static let appGroupId = "group.app.iotd.mobile"
}

private enum IotdTokens {
    static let paper = Color(red: 0xF5/255.0, green: 0xF0/255.0, blue: 0xE6/255.0)
    static let paperHi = Color(red: 0xFB/255.0, green: 0xF7/255.0, blue: 0xEE/255.0)
    static let ink = Color(red: 0x1B/255.0, green: 0x1A/255.0, blue: 0x17/255.0)
    static let inkSoft = Color(red: 0x3A/255.0, green: 0x37/255.0, blue: 0x2F/255.0)
    static let inkMute = Color(red: 0x6E/255.0, green: 0x6A/255.0, blue: 0x5C/255.0)
    static let accent = Color(red: 0x3A/255.0, green: 0x8A/255.0, blue: 0x6B/255.0)
}

struct IotdEntry: TimelineEntry {
    let date: Date
    let hijriDay: Int
    let hijriMonth: String
    let hijriYear: Int
    let gregorianIso: String
    let title: String
    let era: String
    let slug: String
    let kind: String
}

struct IotdProvider: TimelineProvider {
    func placeholder(in context: Context) -> IotdEntry {
        IotdEntry(
            date: Date(),
            hijriDay: 19,
            hijriMonth: "Dhū al-Qaʿda",
            hijriYear: 1447,
            gregorianIso: "2026-05-06",
            title: "Today on the calendar",
            era: "ruler_death",
            slug: "",
            kind: "event"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (IotdEntry) -> ()) {
        completion(load())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<IotdEntry>) -> ()) {
        let entry = load()
        let next = Calendar.current.date(byAdding: .hour, value: 6, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func load() -> IotdEntry {
        let store = UserDefaults(suiteName: IotdConstants.appGroupId)
        return IotdEntry(
            date: Date(),
            hijriDay: store?.integer(forKey: "hijri_day") ?? 0,
            hijriMonth: store?.string(forKey: "hijri_month") ?? "",
            hijriYear: store?.integer(forKey: "hijri_year") ?? 0,
            gregorianIso: store?.string(forKey: "greg_iso") ?? "",
            title: store?.string(forKey: "title") ?? "Today on the calendar",
            era: store?.string(forKey: "era") ?? "",
            slug: store?.string(forKey: "slug") ?? "",
            kind: store?.string(forKey: "kind") ?? "event"
        )
    }
}

// MARK: - Views

private struct IotdSmallView: View {
    let entry: IotdEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TODAY")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .tracking(1.6)
                .foregroundColor(IotdTokens.accent)
            Spacer()
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("\(entry.hijriDay)")
                    .font(.system(size: 60, weight: .medium, design: .serif))
                    .foregroundColor(IotdTokens.ink)
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.hijriMonth)
                        .font(.system(size: 14, design: .serif))
                        .italic()
                        .foregroundColor(IotdTokens.ink)
                    Text("\(entry.hijriYear) AH")
                        .font(.system(size: 9, weight: .regular, design: .monospaced))
                        .foregroundColor(IotdTokens.inkMute)
                }
                Spacer()
            }
            Divider().background(IotdTokens.inkMute.opacity(0.3))
            Text(entry.gregorianIso)
                .font(.system(size: 9, weight: .regular, design: .monospaced))
                .tracking(1)
                .foregroundColor(IotdTokens.inkMute)
        }
        .padding(16)
        .containerBackground(for: .widget) { IotdTokens.paper }
    }
}

private struct IotdMediumView: View {
    let entry: IotdEntry
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("TODAY")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .tracking(1.6)
                    .foregroundColor(IotdTokens.accent)
                Spacer()
                Text("\(entry.hijriDay)")
                    .font(.system(size: 56, weight: .medium, design: .serif))
                    .foregroundColor(IotdTokens.ink)
                Text(entry.hijriMonth)
                    .font(.system(size: 13, design: .serif))
                    .italic()
                    .foregroundColor(IotdTokens.ink)
                Text("\(entry.hijriYear) AH")
                    .font(.system(size: 9, weight: .regular, design: .monospaced))
                    .foregroundColor(IotdTokens.inkMute)
            }
            .padding(16)
            .frame(width: 130, alignment: .leading)
            .background(IotdTokens.paperHi)

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.era.replacingOccurrences(of: "_", with: " ").uppercased())
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .tracking(1.6)
                    .foregroundColor(IotdTokens.accent)
                Text(entry.title)
                    .font(.system(size: 17, weight: .medium, design: .serif))
                    .foregroundColor(IotdTokens.ink)
                    .lineLimit(3)
                Spacer()
                Text(entry.gregorianIso)
                    .font(.system(size: 9, weight: .regular, design: .monospaced))
                    .tracking(0.8)
                    .foregroundColor(IotdTokens.inkMute)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .containerBackground(for: .widget) { IotdTokens.paper }
    }
}

// MARK: - Widgets

struct IotdSmallWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "IotdSmall", provider: IotdProvider()) { entry in
            IotdSmallView(entry: entry)
        }
        .configurationDisplayName("Today (small)")
        .description("Hijri date pylon.")
        .supportedFamilies([.systemSmall])
    }
}

struct IotdMediumWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "IotdMedium", provider: IotdProvider()) { entry in
            IotdMediumView(entry: entry)
        }
        .configurationDisplayName("Today (medium)")
        .description("Hijri date + today's headline.")
        .supportedFamilies([.systemMedium])
    }
}
