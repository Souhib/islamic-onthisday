// ThaqafaWidget.swift
//
// WidgetKit extension source for the Thaqafa app.
// Lives at native_widgets/ios/ in the repo; copy to a Widget
// Extension target you create in Xcode (File → New → Target →
// Widget Extension) inside `Runner.xcworkspace`. Bundle ID
// suggestion: app.thaqafa.app.ThaqafaWidget.
//
// To make App Group sharing work:
//
//   1. In Xcode → Signing & Capabilities for *both* Runner and the
//      ThaqafaWidget target, add the same App Group:
//      `group.app.thaqafa.app`.
//   2. Both entitlements files must list it. Xcode handles this
//      automatically when you tick the App Group.
//
// The Flutter side writes through `home_widget` (see
// `lib/core/widgets_bridge/home_widget_writer.dart`); keys must
// match the ones read here.

import WidgetKit
import SwiftUI

private enum ThaqafaConstants {
    static let appGroupId = "group.app.thaqafa.app"
}

private enum ThaqafaTokens {
    static let paper = Color(red: 0xF5/255.0, green: 0xF0/255.0, blue: 0xE6/255.0)
    static let paperHi = Color(red: 0xFB/255.0, green: 0xF7/255.0, blue: 0xEE/255.0)
    static let ink = Color(red: 0x1B/255.0, green: 0x1A/255.0, blue: 0x17/255.0)
    static let inkSoft = Color(red: 0x3A/255.0, green: 0x37/255.0, blue: 0x2F/255.0)
    static let inkMute = Color(red: 0x6E/255.0, green: 0x6A/255.0, blue: 0x5C/255.0)
    static let accent = Color(red: 0x3A/255.0, green: 0x8A/255.0, blue: 0x6B/255.0)
}

private struct ThaqafaEntry: TimelineEntry {
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

private struct ThaqafaProvider: TimelineProvider {
    func placeholder(in context: Context) -> ThaqafaEntry {
        ThaqafaEntry(
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

    func getSnapshot(in context: Context, completion: @escaping (ThaqafaEntry) -> ()) {
        completion(load())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ThaqafaEntry>) -> ()) {
        let entry = load()
        let next = Calendar.current.date(byAdding: .hour, value: 6, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func load() -> ThaqafaEntry {
        let store = UserDefaults(suiteName: ThaqafaConstants.appGroupId)
        return ThaqafaEntry(
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

private struct ThaqafaSmallView: View {
    let entry: ThaqafaEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TODAY")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .tracking(1.6)
                .foregroundColor(ThaqafaTokens.accent)
            Spacer()
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("\(entry.hijriDay)")
                    .font(.custom("Cormorant Garamond Medium", size: 60))
                    .foregroundColor(ThaqafaTokens.ink)
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.hijriMonth)
                        .font(.custom("Cormorant Garamond Italic", size: 14))
                        .foregroundColor(ThaqafaTokens.ink)
                    Text("\(entry.hijriYear) AH")
                        .font(.system(size: 9, weight: .regular, design: .monospaced))
                        .foregroundColor(ThaqafaTokens.inkMute)
                }
                Spacer()
            }
            Divider().background(ThaqafaTokens.inkMute.opacity(0.3))
            Text(entry.gregorianIso)
                .font(.system(size: 9, weight: .regular, design: .monospaced))
                .tracking(1)
                .foregroundColor(ThaqafaTokens.inkMute)
        }
        .padding(16)
        .background(ThaqafaTokens.paper)
    }
}

private struct ThaqafaMediumView: View {
    let entry: ThaqafaEntry
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text("TODAY")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .tracking(1.6)
                    .foregroundColor(ThaqafaTokens.accent)
                Spacer()
                Text("\(entry.hijriDay)")
                    .font(.custom("Cormorant Garamond Medium", size: 56))
                    .foregroundColor(ThaqafaTokens.ink)
                Text(entry.hijriMonth)
                    .font(.custom("Cormorant Garamond Italic", size: 13))
                    .foregroundColor(ThaqafaTokens.ink)
                Text("\(entry.hijriYear) AH")
                    .font(.system(size: 9, weight: .regular, design: .monospaced))
                    .foregroundColor(ThaqafaTokens.inkMute)
            }
            .padding(16)
            .frame(width: 130, alignment: .leading)
            .background(ThaqafaTokens.paperHi)

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.era.replacingOccurrences(of: "_", with: " ").uppercased())
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .tracking(1.6)
                    .foregroundColor(ThaqafaTokens.accent)
                Text(entry.title)
                    .font(.custom("Cormorant Garamond Medium", size: 17))
                    .foregroundColor(ThaqafaTokens.ink)
                    .lineLimit(3)
                Spacer()
                Text(entry.gregorianIso)
                    .font(.system(size: 9, weight: .regular, design: .monospaced))
                    .tracking(0.8)
                    .foregroundColor(ThaqafaTokens.inkMute)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(ThaqafaTokens.paper)
    }
}

// MARK: - Bundle

@main
struct ThaqafaWidgetBundle: WidgetBundle {
    var body: some Widget {
        ThaqafaSmallWidget()
        ThaqafaMediumWidget()
    }
}

struct ThaqafaSmallWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ThaqafaSmall", provider: ThaqafaProvider()) { entry in
            ThaqafaSmallView(entry: entry)
        }
        .configurationDisplayName("Today (small)")
        .description("Hijri date pylon.")
        .supportedFamilies([.systemSmall])
    }
}

struct ThaqafaMediumWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ThaqafaMedium", provider: ThaqafaProvider()) { entry in
            ThaqafaMediumView(entry: entry)
        }
        .configurationDisplayName("Today (medium)")
        .description("Hijri date + today's headline.")
        .supportedFamilies([.systemMedium])
    }
}
