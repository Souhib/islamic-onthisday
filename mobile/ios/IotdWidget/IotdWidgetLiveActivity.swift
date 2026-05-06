//
//  IotdWidgetLiveActivity.swift
//  IotdWidget
//
//  Created by Souhib Trabelsi on 06/05/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct IotdWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct IotdWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IotdWidgetAttributes.self) { context in
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

extension IotdWidgetAttributes {
    fileprivate static var preview: IotdWidgetAttributes {
        IotdWidgetAttributes(name: "World")
    }
}

extension IotdWidgetAttributes.ContentState {
    fileprivate static var smiley: IotdWidgetAttributes.ContentState {
        IotdWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: IotdWidgetAttributes.ContentState {
         IotdWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: IotdWidgetAttributes.preview) {
   IotdWidgetLiveActivity()
} contentStates: {
    IotdWidgetAttributes.ContentState.smiley
    IotdWidgetAttributes.ContentState.starEyes
}
