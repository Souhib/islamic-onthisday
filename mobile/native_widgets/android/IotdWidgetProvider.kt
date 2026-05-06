// IotdWidgetProvider.kt
//
// Android home-screen widget for the Islamic On This Day app.
// Lives at native_widgets/android/ in the repo; copy to
// `android/app/src/main/kotlin/app/iotd/mobile/widget/` and
// register it in the AndroidManifest.xml (see README in this folder
// for the manifest snippet + the widget_info.xml + remote-views layout
// XML files).
//
// Reads the same shared-preferences keys the Flutter side writes
// through `home_widget`:
//   hijri_day / hijri_month / hijri_year / greg_iso / title / era /
//   slug / kind

package app.iotd.mobile.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import app.iotd.mobile.R

class IotdWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs: SharedPreferences = HomeWidgetPlugin.getData(context)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.iotd_widget_medium)
            views.setTextViewText(
                R.id.iotd_hijri_day,
                prefs.getInt("hijri_day", 0).toString(),
            )
            views.setTextViewText(
                R.id.iotd_hijri_month,
                prefs.getString("hijri_month", "") ?: "",
            )
            views.setTextViewText(
                R.id.iotd_hijri_year,
                "${prefs.getInt("hijri_year", 0)} AH",
            )
            views.setTextViewText(
                R.id.iotd_title,
                prefs.getString("title", "Today on the calendar") ?: "Today on the calendar",
            )
            views.setTextViewText(
                R.id.iotd_era,
                (prefs.getString("era", "") ?: "")
                    .replace('_', ' ')
                    .uppercase(),
            )
            views.setTextViewText(
                R.id.iotd_greg_iso,
                prefs.getString("greg_iso", "") ?: "",
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
