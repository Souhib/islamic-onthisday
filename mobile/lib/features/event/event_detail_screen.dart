import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:thaqafa/api/generated/models/bookmark_create_target_kind.dart';
import 'package:thaqafa/api/generated/models/event_detail.dart';
import 'package:thaqafa/api/generated/models/event_detail_dispute_about.dart';
import 'package:thaqafa/api/generated/models/event_detail_verification_status.dart';
import 'package:thaqafa/core/i18n/collapse_breaks.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/features/bookmarks/save_button.dart';
import 'package:thaqafa/features/event/event_provider.dart';
import 'package:thaqafa/features/event/widgets/disputed_drawer.dart';
import 'package:thaqafa/features/event/widgets/people_section.dart';
import 'package:thaqafa/features/event/widgets/sources_section.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/primitives.dart';
import 'package:thaqafa/shared/verse_epigraph.dart';
import 'package:url_launcher/url_launcher.dart';

/// Single-event detail page. Reuses the editorial vocabulary from the
/// web's `Main` component: era eyebrow, verification chip, full title
/// (Arabic companion when locale ≠ ar), Hijri/Gregorian dates, summary
/// in italic, body paragraphs separated by a frieze rule.
class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final query = ref.watch(eventBySlugProvider(slug));

    return Scaffold(
      backgroundColor: t.paper,
      appBar: AppBar(
        backgroundColor: t.paper,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: t.ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: query.when(
          loading: () => Center(
            child: Text(
              i18n.today.loading.toUpperCase(),
              style: ThaqafaTypography.mono(size: 11, color: t.inkMute, letterSpacing: 1.4),
            ),
          ),
          error: (_, _) => Center(
            child: Text(
              i18n.errors.not_found,
              style: ThaqafaTypography.serif(size: 17, color: t.inkSoft, style: FontStyle.italic),
            ),
          ),
          data: (event) => _Body(event: event),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.event});

  final EventDetail event;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final lang = i18n.$meta.locale.languageCode;
    final title = _pick(lang, event.title, event.titleAr, event.titleFr);
    final summary = _pick(lang, event.summary, event.summaryAr, event.summaryFr);
    final body = _pickList(lang, event.body, event.bodyAr, event.bodyFr);

    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 60),
      children: [
        Row(
          children: [
            if ((event.era ?? '').isNotEmpty)
              Eyebrow(event.era!, color: EyebrowColor.accent),
            const Spacer(),
            VerificationChip(
              kind: _verificationOf(event.verificationStatus),
              label: _verificationLabel(i18n, event.verificationStatus),
            ),
            const SizedBox(width: 10),
            SaveButton(slug: event.id, kind: BookmarkCreateTargetKind.event),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: ThaqafaTypography.serif(
            size: 34,
            color: t.ink,
            weight: FontWeight.w500,
            height: 1.0,
            letterSpacing: -0.6,
          ),
        ),
        if (lang != 'ar' && (event.titleAr ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              event.titleAr!,
              style: ThaqafaTypography.arabic(size: 22, color: t.inkSoft, height: 1.5),
            ),
          ),
        ],
        const SizedBox(height: 18),
        if (event.hijri != null || event.gregorian != null)
          Wrap(
            spacing: 14,
            children: [
              if (event.hijri != null)
                Text(event.hijri!,
                    style: ThaqafaTypography.serif(size: 16, color: t.ink, style: FontStyle.italic)),
              if (event.gregorian != null)
                Text(
                  '· ${_ddmmyyyy(event.gregorian!)} ·',
                  style: ThaqafaTypography.mono(
                    size: 12,
                    color: t.inkMute,
                    letterSpacing: 0.8,
                    uppercase: false,
                  ),
                ),
            ],
          ),
        if (event.disputed) ...[
          const SizedBox(height: 12),
          Builder(
            builder: (ctx) => DisputeBadge(
              about: _disputeOf(event.disputeAbout),
              label: _disputeLabel(i18n, event.disputeAbout),
              onTap: () => showDisputedDrawer(
                ctx,
                positions: event.disputedPositions,
                aboutLabel: _disputeLabel(i18n, event.disputeAbout) ?? '',
              ),
            ),
          ),
        ],
        if ((event.imageUrl ?? '').isNotEmpty) ...[
          const SizedBox(height: 22),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: t.rule, width: 0.5),
                bottom: BorderSide(color: t.rule, width: 0.5),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: event.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: t.paperLo),
                errorWidget: (_, _, _) => Container(color: t.paperLo),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        FriezeRule(label: i18n.today.introduction, marginTop: 4, marginBottom: 14),
        Text(
          collapseHardBreaks(summary),
          style: ThaqafaTypography.serif(
            size: 18,
            color: t.inkSoft,
            style: FontStyle.italic,
            height: 1.6,
          ),
        ),
        if (body.isNotEmpty) ...[
          FriezeRule(label: i18n.today.the_reading, marginTop: 28, marginBottom: 18),
          for (int i = 0; i < body.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 18),
              child: Text(
                collapseHardBreaks(body[i]),
                style: ThaqafaTypography.serif(size: 17, color: t.inkSoft, height: 1.65),
              ),
            ),
          const FriezeRule(rosetteOnly: true, marginTop: 28),
          Text(
            i18n.today.end_of_reading.toUpperCase(),
            textAlign: TextAlign.center,
            style: ThaqafaTypography.mono(size: 11, color: t.inkMute, letterSpacing: 1.6),
          ),
        ],
        PeopleSection(people: event.people),
        SourcesSection(sources: event.sources),
        if ((event.sourceUrl ?? '').isNotEmpty) ...[
          const SizedBox(height: 22),
          Center(
            child: TextButton(
              onPressed: () => launchUrl(
                Uri.parse(event.sourceUrl!),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                '${i18n.today.verify.toUpperCase()} ↗',
                style: ThaqafaTypography.mono(
                  size: 11,
                  color: t.accent,
                  letterSpacing: 1.6,
                ),
              ),
            ),
          ),
        ],
        VerseEpigraph(quranRefs: event.quranRefs),
      ],
    );
  }
}

String _pick(String lang, String en, String? ar, String? fr) => switch (lang) {
      'ar' => (ar?.isNotEmpty ?? false) ? ar! : en,
      'fr' => (fr?.isNotEmpty ?? false) ? fr! : en,
      _ => en,
    };

List<String> _pickList(String lang, List<String> en, List<String>? ar, List<String>? fr) =>
    switch (lang) {
      'ar' => (ar?.isNotEmpty ?? false) ? ar! : en,
      'fr' => (fr?.isNotEmpty ?? false) ? fr! : en,
      _ => en,
    };

VerificationKind _verificationOf(EventDetailVerificationStatus s) => switch (s) {
      EventDetailVerificationStatus.scholarReviewed => VerificationKind.scholarReviewed,
      EventDetailVerificationStatus.crossVerified => VerificationKind.crossVerified,
      EventDetailVerificationStatus.singleSource => VerificationKind.singleSource,
      _ => VerificationKind.unverified,
    };

String _verificationLabel(Translations i18n, EventDetailVerificationStatus s) => switch (s) {
      EventDetailVerificationStatus.scholarReviewed => i18n.verification.scholar_reviewed,
      EventDetailVerificationStatus.crossVerified => i18n.verification.cross_verified,
      EventDetailVerificationStatus.singleSource => i18n.verification.single_source,
      _ => i18n.verification.unverified,
    };

DisputeAbout _disputeOf(EventDetailDisputeAbout? a) => switch (a) {
      EventDetailDisputeAbout.date => DisputeAbout.date,
      EventDetailDisputeAbout.detail => DisputeAbout.detail,
      EventDetailDisputeAbout.interpretation => DisputeAbout.interpretation,
      _ => DisputeAbout.detail,
    };

String? _disputeLabel(Translations i18n, EventDetailDisputeAbout? a) => switch (a) {
      EventDetailDisputeAbout.date => i18n.dispute.date,
      EventDetailDisputeAbout.detail => i18n.dispute.detail,
      EventDetailDisputeAbout.interpretation => i18n.dispute.interpretation,
      _ => null,
    };

String _ddmmyyyy(String iso) {
  final m = RegExp(r'^(\d{1,4})-(\d{2})-(\d{2})$').firstMatch(iso);
  if (m == null) return iso;
  return '${m.group(3)}-${m.group(2)}-${m.group(1)!.padLeft(4, '0')}';
}
