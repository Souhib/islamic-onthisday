import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iotd_mobile/core/config/api_config.dart';

/// Pipeline-emitted dataset depth signal — same JSON the web's
/// footer reads. Cached for the session (it's a static asset
/// regenerated nightly by the pipeline rebuild).
class DatasetMeta {
  const DatasetMeta({
    required this.eventCount,
    required this.observanceCount,
    required this.personCount,
    required this.daysWithHeadline,
  });

  factory DatasetMeta.fromJson(Map<String, Object?> json) => DatasetMeta(
        eventCount: json['event_count']! as int,
        observanceCount: json['observance_count']! as int,
        personCount: json['person_count']! as int,
        daysWithHeadline: json['days_with_headline']! as int,
      );

  final int eventCount;
  final int observanceCount;
  final int personCount;
  final int daysWithHeadline;
}

final datasetMetaProvider = FutureProvider<DatasetMeta?>((ref) async {
  try {
    final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
    final res = await dio.get<Map<String, Object?>>('/dataset-meta.json');
    return DatasetMeta.fromJson(res.data!);
  } catch (_) {
    return null;
  }
});
