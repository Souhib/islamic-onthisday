import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/core/config/api_config.dart';

/// One ayah from the pipeline-emitted ``quran-extracts.json`` —
/// vocalised Arabic + Saheeh International EN + Hamidullah FR +
/// surah names.
class QuranicVerse {
  const QuranicVerse({
    required this.ar,
    required this.en,
    required this.fr,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahNameAr,
    required this.surahNameEn,
  });

  factory QuranicVerse.fromJson(Map<String, Object?> json) => QuranicVerse(
        ar: json['ar']! as String,
        en: json['en']! as String,
        fr: json['fr']! as String,
        surahNumber: json['surahNumber']! as int,
        ayahNumber: json['ayahNumber']! as int,
        surahNameAr: json['surahNameAr']! as String,
        surahNameEn: json['surahNameEn']! as String,
      );

  final String ar;
  final String en;
  final String fr;
  final int surahNumber;
  final int ayahNumber;
  final String surahNameAr;
  final String surahNameEn;
}

class QuranExtracts {
  const QuranExtracts({required this.fallback, required this.verses});

  factory QuranExtracts.fromJson(Map<String, Object?> json) {
    final raw = json['verses']! as Map<String, Object?>;
    final verses = <String, QuranicVerse>{};
    for (final entry in raw.entries) {
      verses[entry.key] = QuranicVerse.fromJson(entry.value! as Map<String, Object?>);
    }
    return QuranExtracts(
      fallback: json['fallback']! as String,
      verses: verses,
    );
  }

  final String fallback;
  final Map<String, QuranicVerse> verses;

  /// Pick a verse by ``surah:ayah`` key with fallback to Yūsuf 12:111.
  QuranicVerse? pick(String? key) {
    if (key != null && verses.containsKey(key)) return verses[key];
    return verses[fallback];
  }
}

final quranExtractsProvider = FutureProvider<QuranExtracts?>((ref) async {
  try {
    final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
    final res = await dio.get<Map<String, Object?>>('/quran-extracts.json');
    return QuranExtracts.fromJson(res.data!);
  } catch (_) {
    return null;
  }
});

/// Extract the first ``surah:ayah`` lookup key from a freeform
/// ``quran_refs`` string. Mirrors the web's ``firstQuranKey`` parser.
String? firstQuranKey(String? refs) {
  if (refs == null || refs.isEmpty) return null;
  final m = RegExp(r'(\d{1,3}):(\d{1,3})').firstMatch(refs);
  if (m == null) return null;
  final surah = int.parse(m.group(1)!);
  final ayah = int.parse(m.group(2)!);
  if (surah < 1 || surah > 114) return null;
  if (ayah < 1) return null;
  return '$surah:$ayah';
}
