//
//  ThaqafaWidgetBundle.swift
//  ThaqafaWidget
//
//  Bundle entry point. The two concrete widgets — small + medium —
//  live in `ThaqafaWidget.swift`.
//

import WidgetKit
import SwiftUI

@main
struct ThaqafaWidgetBundle: WidgetBundle {
    var body: some Widget {
        ThaqafaSmallWidget()
        ThaqafaMediumWidget()
    }
}
