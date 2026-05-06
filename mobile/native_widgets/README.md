# Native widget setup

Phase 4 ships the Flutter side ready (the data writer at
`lib/core/widgets_bridge/home_widget_writer.dart` pushes today's
payload through `home_widget` whenever the Today provider resolves)
and the native source files for both platforms — but creating the
**iOS Widget Extension target** and registering the **Android
AppWidgetProvider** require manual steps inside Xcode and Android
Studio that can't be scripted from CLI without risking
`Runner.xcodeproj` corruption.

This is a one-shot setup. After it's done the widgets refresh
automatically from app data.

## iOS — Widget Extension target

1. Open `mobile/ios/Runner.xcworkspace` in Xcode.
2. **File → New → Target → Widget Extension**. Product name:
   `IotdWidget`. Bundle Identifier: `app.iotd.mobile.IotdWidget`.
   Deselect "Include Configuration Intent".
3. Replace the generated `IotdWidget.swift` and
   `IotdWidgetBundle.swift` with the contents of
   `native_widgets/ios/IotdWidget.swift` from this folder
   (the bundle / provider / views all live there in this version).
   Leave the auto-generated `AppIntent.swift`,
   `IotdWidgetControl.swift`, `IotdWidgetLiveActivity.swift` files
   in place — they're independent and harmless; if you want to
   clean up, delete them in Xcode (right-click → Delete → Move to
   Trash).
4. Select **both** the `Runner` target and the new `IotdWidget`
   target → **Signing & Capabilities** → **+ Capability** →
   **App Groups**. Add `group.app.iotd.mobile` to both. The
   entitlements files update automatically.
5. Set the deployment target on the `IotdWidget` scheme to
   **iOS 14.0** (matches the project's Podfile platform).

### Two known foot-guns when building (fix once, never see again)

**(a) `pod install` fails with `objectVersion 70`.** Xcode 26+
writes the project file in pbxproj v70 which CocoaPods 1.16.x
doesn't understand. Edit
`ios/Runner.xcodeproj/project.pbxproj` and change
`objectVersion = 70;` to `objectVersion = 56;`. Then
`cd ios && pod install` runs cleanly. Re-add the change every
time Xcode regenerates the file (rare).

**(b) "Cycle inside Runner" build error.** Xcode wires the new
"Embed Foundation Extensions" build phase at the end of Runner's
phase list, where it ends up in a dependency cycle with `Thin
Binary` and `[CP] Embed Pods Frameworks`. Fix in Xcode:
**Runner target → Build Phases**, drag *Embed Foundation
Extensions* to sit just above *Embed Frameworks*. The expected
order is:

```
[CP] Check Pods Manifest.lock
Run Script
Sources
Frameworks
Resources
Embed Foundation Extensions   ← move here
Embed Frameworks
[CP] Embed Pods Frameworks
Thin Binary
```

Build & run. The widget appears in the iOS widget gallery.

## Android — AppWidgetProvider

1. Copy `native_widgets/android/IotdWidgetProvider.kt` to
   `mobile/android/app/src/main/kotlin/app/iotd/mobile/widget/IotdWidgetProvider.kt`
   (create the `widget/` subfolder).
2. Copy `native_widgets/android/iotd_widget_medium.xml` to
   `mobile/android/app/src/main/res/layout/iotd_widget_medium.xml`.
3. Copy `native_widgets/android/iotd_widget_info.xml` to
   `mobile/android/app/src/main/res/xml/iotd_widget_info.xml`.
4. Open `mobile/android/app/src/main/AndroidManifest.xml` and add
   the receiver inside `<application>`:

   ```xml
   <receiver android:name=".widget.IotdWidgetProvider"
             android:exported="false">
       <intent-filter>
           <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
       </intent-filter>
       <meta-data android:name="android.appwidget.provider"
                  android:resource="@xml/iotd_widget_info" />
   </receiver>
   ```

5. Build & run. The widget appears in the long-press home-screen
   widget picker.

## Wiring the data writer to the Today flow

Once the targets compile, edit `today_provider.dart` to call
`HomeWidgetWriter.publishToday(data, locale)` after a successful
fetch — the FE refreshes the shared store and triggers a widget
timeline reload in one shot. Suggested integration:

```dart
final todayProvider = FutureProvider<TodayResponse>((ref) async {
  final client = ref.watch(iotdClientProvider).today;
  final data = await client.getTodayApiV1TodayGet();
  await HomeWidgetWriter.publishToday(
    data,
    LocaleSettings.currentLocale.languageCode,
  );
  return data;
});
```

We don't ship that wiring in phase 4 because without the native
targets it's a no-op — the `home_widget` plugin tolerates a missing
extension and silently skips the reload.
