/// Localise a backend-supplied English weekday ("Wednesday") into the
/// app's current locale. The API returns the day in English regardless
/// of the requesting locale (matches the web behaviour); the FE owns
/// rendering.
String localiseWeekday(String englishWeekday, String lang) {
  final key = englishWeekday.toLowerCase();
  return switch (lang) {
    'fr' => _fr[key] ?? englishWeekday,
    'ar' => _ar[key] ?? englishWeekday,
    _ => englishWeekday,
  };
}

const Map<String, String> _fr = {
  'monday': 'Lundi',
  'tuesday': 'Mardi',
  'wednesday': 'Mercredi',
  'thursday': 'Jeudi',
  'friday': 'Vendredi',
  'saturday': 'Samedi',
  'sunday': 'Dimanche',
};

const Map<String, String> _ar = {
  'monday': 'الإثنين',
  'tuesday': 'الثلاثاء',
  'wednesday': 'الأربعاء',
  'thursday': 'الخميس',
  'friday': 'الجمعة',
  'saturday': 'السبت',
  'sunday': 'الأحد',
};
