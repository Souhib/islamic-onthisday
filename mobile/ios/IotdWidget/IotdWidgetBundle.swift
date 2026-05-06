//
//  IotdWidgetBundle.swift
//  IotdWidget
//
//  Bundle entry point. The two concrete widgets — small + medium —
//  live in `IotdWidget.swift`.
//

import WidgetKit
import SwiftUI

@main
struct IotdWidgetBundle: WidgetBundle {
    var body: some Widget {
        IotdSmallWidget()
        IotdMediumWidget()
    }
}
