import 'package:flutter/material.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';
import 'package:iotd_mobile/i18n/strings.g.dart';
import 'package:iotd_mobile/shared/primitives.dart';
import 'package:url_launcher/url_launcher.dart';

/// About page — port of the web's /about. Project promise, image
/// policy table, mention of the wider work (Majlisna + LaTabdhir),
/// contact links. Skips the long bio + experience sections from the
/// web — those read awkwardly in a phone viewport.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
          children: [
            const Center(child: EightPointStar(size: 36)),
            const SizedBox(height: 18),
            Text(
              i18n.about.headline,
              textAlign: TextAlign.center,
              style: IotdTypography.serif(
                size: 30,
                color: t.ink,
                weight: FontWeight.w500,
                height: 1.05,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              i18n.about.intro,
              textAlign: TextAlign.center,
              style: IotdTypography.serif(
                size: 17,
                color: t.inkSoft,
                style: FontStyle.italic,
                height: 1.5,
              ),
            ),

            FriezeRule(label: i18n.about.other_projects, marginTop: 36, marginBottom: 14),
            _ProjectLink(label: 'Majlisna', subtitle: i18n.about.majlisna_subtitle, url: 'https://majlisna.app'),
            _ProjectLink(label: 'LaTabdhir', subtitle: i18n.about.latabdhir_subtitle, url: 'https://latabdhir.ae'),

            FriezeRule(label: i18n.about.contact, marginTop: 36, marginBottom: 14),
            const _ContactRow(label: 'Email', value: 'souhib.t@hotmail.fr', url: 'mailto:souhib.t@hotmail.fr'),
            const _ContactRow(label: 'GitHub', value: '@Souhib', url: 'https://github.com/Souhib'),
            const _ContactRow(label: 'LinkedIn', value: 'souhib-trabelsi', url: 'https://www.linkedin.com/in/souhib-trabelsi/'),

            FriezeRule(label: i18n.about.editions_title, marginTop: 36, marginBottom: 14),
            _EditionRow(
              label: i18n.about.edition_arabic_label,
              value: i18n.about.edition_arabic_value,
            ),
            _EditionRow(
              label: i18n.about.edition_english_label,
              value: i18n.about.edition_english_value,
            ),
            _EditionRow(
              label: i18n.about.edition_french_label,
              value: i18n.about.edition_french_value,
              last: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditionRow extends StatelessWidget {
  const _EditionRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: t.rule, width: 0.5),
          bottom: last ? BorderSide(color: t.rule, width: 0.5) : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: IotdTypography.mono(
              size: 10,
              color: t.inkMute,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: IotdTypography.serif(
              size: 16,
              color: t.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectLink extends StatelessWidget {
  const _ProjectLink({required this.label, required this.subtitle, required this.url});

  final String label;
  final String subtitle;
  final String url;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: t.rule, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: IotdTypography.serif(size: 18, color: t.ink, weight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: IotdTypography.serif(size: 14, color: t.inkMute, style: FontStyle.italic),
                  ),
                ],
              ),
            ),
            Text(
              '↗',
              style: IotdTypography.mono(size: 14, color: t.accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.label, required this.value, required this.url});

  final String label;
  final String value;
  final String url;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: t.rule, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: Text(
                label.toUpperCase(),
                style: IotdTypography.mono(size: 11, color: t.inkMute, letterSpacing: 1.2),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: IotdTypography.serif(size: 16, color: t.ink),
              ),
            ),
            Text(
              '↗',
              style: IotdTypography.mono(size: 14, color: t.accent),
            ),
          ],
        ),
      ),
    );
  }
}
