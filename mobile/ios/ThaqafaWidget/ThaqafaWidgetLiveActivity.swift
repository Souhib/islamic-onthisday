//
//  ThaqafaWidgetLiveActivity.swift
//  ThaqafaWidget
//
//  Created by Souhib Trabelsi on 06/05/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ThaqafaWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ThaqafaWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ThaqafaWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ThaqafaWidgetAttributes {
    fileprivate static var preview: ThaqafaWidgetAttributes {
        ThaqafaWidgetAttributes(name: "World")
    }
}

extension ThaqafaWidgetAttributes.ContentState {
    fileprivate static var smiley: ThaqafaWidgetAttributes.ContentState {
        ThaqafaWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ThaqafaWidgetAttributes.ContentState {
         ThaqafaWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ThaqafaWidgetAttributes.preview) {
   ThaqafaWidgetLiveActivity()
} contentStates: {
    ThaqafaWidgetAttributes.ContentState.smiley
    ThaqafaWidgetAttributes.ContentState.starEyes
}
