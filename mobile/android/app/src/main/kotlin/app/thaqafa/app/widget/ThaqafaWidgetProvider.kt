// ThaqafaWidgetProvider.kt
//
// Android home-screen widget for the Thaqafa app.
// Lives at native_widgets/android/ in the repo; copy to
// `android/app/src/main/kotlin/app/thaqafa/app/widget/` and
// register it in the AndroidManifest.xml (see README in this folder
// for the manifest snippet + the widget_info.xml + remote-views layout
// XML files).
//
// Reads the same shared-preferences keys the Flutter side writes
// through `home_widget`:
//   hijri_day / hijri_month / hijri_year / greg_iso / title / era /
//   slug / kind

package app.thaqafa.app.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import app.thaqafa.app.R

class ThaqafaWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs: SharedPreferences = HomeWidgetPlugin.getData(context)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.thaqafa_widget_medium)
            views.setTextViewText(
                R.id.thaqafa_hijri_day,
                prefs.getInt("hijri_day", 0).toString(),
            )
            views.setTextViewText(
                R.id.thaqafa_hijri_month,
                prefs.getString("hijri_month", "") ?: "",
            )
            views.setTextViewText(
                R.id.thaqafa_hijri_year,
                "${prefs.getInt("hijri_year", 0)} AH",
            )
            views.setTextViewText(
                R.id.thaqafa_title,
                prefs.getString("title", "Today on the calendar") ?: "Today on the calendar",
            )
            views.setTextViewText(
                R.id.thaqafa_era,
                (prefs.getString("era", "") ?: "")
                    .replace('_', ' ')
                    .uppercase(),
            )
            views.setTextViewText(
                R.id.thaqafa_greg_iso,
                prefs.getString("greg_iso", "") ?: "",
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
