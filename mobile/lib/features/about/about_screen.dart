import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:thaqafa/core/config/api_config.dart';
import 'package:thaqafa/core/theme/thaqafa_tokens.dart';
import 'package:thaqafa/core/theme/thaqafa_typography.dart';
import 'package:thaqafa/i18n/strings.g.dart';
import 'package:thaqafa/shared/primitives.dart';
import 'package:thaqafa/shared/thaqafa_mark.dart';
import 'package:url_launcher/url_launcher.dart';

const _skills = [
  'Python', 'FastAPI', 'Flask',
  'React', 'TypeScript', 'PostgreSQL', 'MySQL',
  'AWS', 'GCP', 'Docker', 'Terraform', 'Ansible',
  'Gitlab CI/CD', 'Traefik', 'Prefect', 'SQLModel',
  'Tailwind CSS', 'OpenCV', 'Pandas', 'NumPy',
  'Scikit-learn',
];

const _experienceKeys = ['madura', 'snap', 'enedis', 'bnp', 'cloudeasier'];

/// About page — full port of the web's `/about`. Hero + project
/// purpose + person hero (photo + bio) + education + experience +
/// skills + other projects + mentoring + charities + contact +
/// Qur'an attribution.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final lang = i18n.$meta.locale.languageCode;
    final about = i18n.about;
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
            // --- Hero ---
            const Center(child: ThaqafaMark(size: 48)),
            const SizedBox(height: 12),
            Center(child: Eyebrow('· ${about.title} ·', color: EyebrowColor.accent)),
            const SizedBox(height: 14),
            Text(
              about.subtitle,
              textAlign: TextAlign.center,
              style: lang == 'ar'
                  ? ThaqafaTypography.arabic(size: 17, color: t.inkSoft, height: 1.7)
                  : ThaqafaTypography.serif(
                      size: 17,
                      color: t.inkSoft,
                      style: FontStyle.italic,
                      height: 1.55,
                    ),
            ),

            const FriezeRule(marginTop: 28, marginBottom: 28),

            // --- Project purpose ---
            _Section(
              title: about.project_purpose_title,
              child: Text(
                about.project_purpose_body,
                style: lang == 'ar'
                    ? ThaqafaTypography.arabic(size: 17, color: t.inkSoft, height: 1.95)
                    : ThaqafaTypography.serif(size: 18, color: t.inkSoft, height: 1.7),
              ),
            ),

            FriezeRule(label: about.nav_label, marginTop: 36, marginBottom: 26),

            // --- Person hero (photo + name + role + bio) ---
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: t.rule, width: 0.5),
                  ),
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: CachedNetworkImage(
                      imageUrl: '${ApiConfig.baseUrl}/souhib.jpeg',
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: t.paperLo),
                      errorWidget: (_, _, _) => Container(color: t.paperLo),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  about.name,
                  textAlign: TextAlign.center,
                  style: lang == 'ar'
                      ? ThaqafaTypography.arabic(size: 30, color: t.ink, weight: FontWeight.w500)
                      : ThaqafaTypography.serif(
                          size: 30,
                          color: t.ink,
                          weight: FontWeight.w500,
                          height: 1.05,
                          letterSpacing: -0.6,
                        ),
                ),
                const SizedBox(height: 6),
                Eyebrow(about.role, color: EyebrowColor.inkMute),
                const SizedBox(height: 12),
                Text(
                  about.bio,
                  style: lang == 'ar'
                      ? ThaqafaTypography.arabic(size: 16.5, color: t.inkSoft, height: 1.9)
                      : ThaqafaTypography.serif(size: 17, color: t.inkSoft, height: 1.6),
                ),
              ],
            ),

            // --- Education ---
            _Section(
              title: about.education_title,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BorderedRow(text: about.education_epitech),
                  _BorderedRow(text: about.education_sfsu),
                ],
              ),
            ),

            // --- Experience ---
            _Section(
              title: about.experience_title,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final slug in _experienceKeys)
                    _ExperienceRow(slug: slug),
                ],
              ),
            ),

            // --- Skills ---
            _Section(
              title: about.skills_title,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in _skills)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(border: Border.all(color: t.rule, width: 0.5)),
                      child: Text(
                        s,
                        style: ThaqafaTypography.mono(
                          size: 12,
                          color: t.inkSoft,
                          letterSpacing: 0.3,
                          uppercase: false,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // --- Other projects ---
            _Section(
              title: about.other_projects_title,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProjectRow(
                    title: about.other_projects_majlisna_title,
                    desc: about.other_projects_majlisna_desc,
                    link: about.other_projects_majlisna_link,
                  ),
                  _ProjectRow(
                    title: about.other_projects_latabdhir_title,
                    desc: about.other_projects_latabdhir_desc,
                    link: about.other_projects_latabdhir_link,
                  ),
                ],
              ),
            ),

            // --- Mentoring ---
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: t.accentBg,
                border: Border.all(color: t.accent.withValues(alpha: 0.4), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Eyebrow('· ${about.mentoring_title} ·', color: EyebrowColor.accent),
                  const SizedBox(height: 12),
                  Text(
                    about.mentoring_body,
                    style: lang == 'ar'
                        ? ThaqafaTypography.arabic(size: 16, color: t.inkSoft, height: 1.9)
                        : ThaqafaTypography.serif(size: 16.5, color: t.inkSoft, height: 1.65),
                  ),
                  const SizedBox(height: 18),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ExternalChip(
                        label: 'souhib.t@hotmail.fr',
                        url: 'mailto:souhib.t@hotmail.fr',
                      ),
                      _ExternalChip(
                        label: '+33 6 43 14 20 20',
                        url: 'tel:+33643142020',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- Charities ---
            _Section(
              title: about.charity_title,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      about.charity_subtitle,
                      style: lang == 'ar'
                          ? ThaqafaTypography.arabic(size: 16, color: t.inkSoft, height: 1.9)
                          : ThaqafaTypography.serif(
                              size: 16,
                              color: t.inkSoft,
                              style: FontStyle.italic,
                              height: 1.6,
                            ),
                    ),
                  ),
                  _ProjectRow(
                    title: 'Human Appeal',
                    desc: about.charity_human_appeal_desc,
                    link: 'humanappeal.fr',
                    overrideUrl: 'https://humanappeal.fr/',
                    cta: about.charity_donate,
                  ),
                  _ProjectRow(
                    title: 'Ummah Charity',
                    desc: about.charity_ummah_charity_desc,
                    link: 'ummahcharity.org',
                    overrideUrl: 'https://ummahcharity.org/',
                    cta: about.charity_donate,
                  ), // ignore: prefer_const_constructors
                ],
              ),
            ),

            // --- Contact ---
            _Section(
              title: about.contact_title,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ContactRow(
                    label: about.contact_email,
                    value: 'souhib.t@hotmail.fr',
                    url: 'mailto:souhib.t@hotmail.fr',
                  ),
                  _ContactRow(
                    label: about.contact_phone,
                    value: '+33 6 43 14 20 20',
                    url: 'tel:+33643142020',
                  ),
                  _ContactRow(
                    label: about.contact_linkedin,
                    value: 'souhib-trabelsi',
                    url: 'https://www.linkedin.com/in/souhib-trabelsi/',
                  ),
                  _ContactRow(
                    label: about.contact_github,
                    value: '@Souhib',
                    url: 'https://github.com/Souhib',
                  ),
                ],
              ),
            ),

            // --- Qur'an attribution ---
            const SizedBox(height: 36),
            Eyebrow('· ${about.quran_attribution_title} ·', color: EyebrowColor.inkMute),
            const SizedBox(height: 10),
            Text(
              about.quran_attribution_body,
              style: lang == 'ar'
                  ? ThaqafaTypography.arabic(size: 14.5, color: t.inkMute, height: 1.85)
                  : ThaqafaTypography.serif(size: 15, color: t.inkMute, height: 1.65),
            ),

            // --- Legal ---
            const SizedBox(height: 36),
            Eyebrow('· ${i18n.legal.title} ·', color: EyebrowColor.inkMute),
            const SizedBox(height: 10),
            _LegalRow(label: i18n.legal.privacy, url: '${ApiConfig.baseUrl}${_legalPath('privacy', lang)}'),
            _LegalRow(label: i18n.legal.terms, url: '${ApiConfig.baseUrl}${_legalPath('terms', lang)}', last: true),
          ],
        ),
      ),
    );
  }
}

/// Resolve the localised legal-page path. The static files at the
/// public origin live at ``/privacy.html`` (EN), ``/privacy.fr.html``,
/// ``/privacy.ar.html`` (and the matching ``terms.*``).
String _legalPath(String kind, String lang) {
  if (lang == 'fr') return '/$kind.fr.html';
  if (lang == 'ar') return '/$kind.ar.html';
  return '/$kind.html';
}

class _LegalRow extends StatelessWidget {
  const _LegalRow({required this.label, required this.url, this.last = false});

  final String label;
  final String url;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: t.ruleSoft, width: 0.5),
            bottom: last ? BorderSide(color: t.ruleSoft, width: 0.5) : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: ThaqafaTypography.mono(
                  size: 11,
                  color: t.inkSoft,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            Text('↗', style: ThaqafaTypography.mono(size: 14, color: t.accent)),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Eyebrow('· $title ·', color: EyebrowColor.accent),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BorderedRow extends StatelessWidget {
  const _BorderedRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.ruleSoft, width: 0.5)),
      ),
      child: Text(
        text,
        style: ThaqafaTypography.serif(size: 17, color: t.ink, height: 1.4),
      ),
    );
  }
}

class _ExperienceRow extends StatelessWidget {
  const _ExperienceRow({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final i18n = Translations.of(context);
    final about = i18n.about;
    final (title, period, desc) = switch (slug) {
      'madura' => (about.experience_madura_title, about.experience_madura_period, about.experience_madura_desc),
      'snap' => (about.experience_snap_title, about.experience_snap_period, about.experience_snap_desc),
      'enedis' => (about.experience_enedis_title, about.experience_enedis_period, about.experience_enedis_desc),
      'bnp' => (about.experience_bnp_title, about.experience_bnp_period, about.experience_bnp_desc),
      _ => (about.experience_cloudeasier_title, about.experience_cloudeasier_period, about.experience_cloudeasier_desc),
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.ruleSoft, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ThaqafaTypography.serif(
              size: 17,
              color: t.ink,
              weight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            period.toUpperCase(),
            style: ThaqafaTypography.mono(size: 11, color: t.inkMute, letterSpacing: 1.2),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: ThaqafaTypography.serif(size: 15, color: t.inkSoft, height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({
    required this.title,
    required this.desc,
    required this.link,
    this.cta,
    this.overrideUrl,
  });

  final String title;
  final String desc;
  final String link;
  final String? cta;
  final String? overrideUrl;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final url = overrideUrl ?? 'https://$link';
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.ruleSoft, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: ThaqafaTypography.serif(
                      size: 19,
                      color: t.ink,
                      weight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
                Text(
                  '${(cta ?? link).toUpperCase()} ↗',
                  style: ThaqafaTypography.mono(size: 11, color: t.accent, letterSpacing: 1.4),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: ThaqafaTypography.serif(size: 16, color: t.inkSoft, height: 1.55),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.label,
    required this.value,
    required this.url,
  });

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
          border: Border(top: BorderSide(color: t.ruleSoft, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: Text(
                label.toUpperCase(),
                style: ThaqafaTypography.mono(
                  size: 11,
                  color: t.inkMute,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: ThaqafaTypography.serif(size: 16, color: t.ink),
              ),
            ),
            Text(
              '↗',
              style: ThaqafaTypography.mono(size: 14, color: t.accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExternalChip extends StatelessWidget {
  const _ExternalChip({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: t.rule, width: 0.5)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: ThaqafaTypography.mono(
                size: 12,
                color: t.inkSoft,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '↗',
              style: ThaqafaTypography.mono(size: 12, color: t.accent),
            ),
          ],
        ),
      ),
    );
  }
}
