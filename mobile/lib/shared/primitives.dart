import 'package:flutter/material.dart';
import 'package:iotd_mobile/core/theme/iotd_tokens.dart';
import 'package:iotd_mobile/core/theme/iotd_typography.dart';

/// The project's editorial mark — two squares, one rotated 45°, both
/// hairline-stroked. Used on splash, onboarding, and as a faint
/// watermark on otherwise-plain screens.
class EightPointStar extends StatelessWidget {
  const EightPointStar({this.size = 24, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: _StarPainter(color: color ?? context.tokens.accent),
    ),
  );
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..strokeJoin = StrokeJoin.round;

    final inset = size.width * 0.16;
    final rect = Rect.fromLTRB(
      inset,
      inset,
      size.width - inset,
      size.height - inset,
    );
    canvas.drawRect(rect, paint);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(0.7853981633974483); // 45°
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) => oldDelegate.color != color;
}

/// Small concentric rosette anchoring frieze rules. Mirrors the
/// `Rosette` SVG in the web mockup.
class Rosette extends StatelessWidget {
  const Rosette({this.size = 22, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: _RosettePainter(color: color ?? context.tokens.accent),
    ),
  );
}

class _RosettePainter extends CustomPainter {
  _RosettePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    final center = Offset(size.width / 2, size.height / 2);
    // Web's rosette geometry — two concentric circles with two
    // overlaid squares (one upright, one rotated 45°) that together
    // suggest an eight-point star inside the circle ring.
    canvas.drawCircle(center, size.width * 0.39, paint);
    canvas.drawCircle(center, size.width * 0.21, paint);

    final rectInset = size.width * 0.205;
    final rect = Rect.fromLTRB(
      rectInset,
      rectInset,
      size.width - rectInset,
      size.height - rectInset,
    );
    canvas.drawRect(rect, paint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.7853981633974483); // 45°
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RosettePainter oldDelegate) => oldDelegate.color != color;
}

/// Decorative horizontal rule with a centered rosette, optionally
/// labelled. The label is set in mono uppercase tracking, matching the
/// editorial vocabulary established on the web.
class FriezeRule extends StatelessWidget {
  const FriezeRule({
    this.label,
    this.rosetteOnly = false,
    this.marginTop = 22,
    this.marginBottom = 18,
    super.key,
  });

  final String? label;
  final bool rosetteOnly;
  final double marginTop;
  final double marginBottom;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    if (rosetteOnly) {
      return Padding(
        padding: EdgeInsets.only(top: marginTop, bottom: marginBottom),
        child: const Center(child: Rosette()),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: marginTop, bottom: marginBottom),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Container(height: 1, color: t.ink.withValues(alpha: 0.85)),
              const SizedBox(height: 3),
              Container(height: 0.5, color: t.rule),
            ],
          ),
          Container(
            color: t.paper,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Rosette(),
                if (label != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    label!.toUpperCase(),
                    style: IotdTypography.mono(
                      size: 11.5,
                      color: t.accent,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Rosette(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mono-uppercase label used as a section eyebrow.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {this.color, this.fontSize = 12, super.key});

  final String text;
  final EyebrowColor? color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = switch (color) {
      EyebrowColor.accent => t.accent,
      EyebrowColor.warn => t.warn,
      EyebrowColor.ink => t.ink,
      _ => t.inkMute,
    };
    return Text(
      text.toUpperCase(),
      style: IotdTypography.mono(size: fontSize, color: c, letterSpacing: 1.4),
    );
  }
}

enum EyebrowColor { inkMute, accent, warn, ink }

/// Verification chip — rendered as a row of dots followed by a label,
/// where the dot count = trust tier. Same visual logic as the web's
/// `VerificationChip`.
class VerificationChip extends StatelessWidget {
  const VerificationChip({required this.kind, required this.label, super.key});

  final VerificationKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final dots = switch (kind) {
      VerificationKind.scholarReviewed => 4,
      VerificationKind.crossVerified => 3,
      VerificationKind.singleSource => 2,
      VerificationKind.unverified => 1,
    };
    final tone = kind == VerificationKind.singleSource ||
            kind == VerificationKind.unverified
        ? t.warn
        : t.accent;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 4; i++) ...[
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: i < dots ? tone : Colors.transparent,
              border: Border.all(color: tone, width: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          if (i < 3) const SizedBox(width: 3),
        ],
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: IotdTypography.mono(size: 10.5, color: tone, letterSpacing: 1.2),
        ),
      ],
    );
  }
}

enum VerificationKind { scholarReviewed, crossVerified, singleSource, unverified }

/// Tap-to-explain dispute pill. Reflects `Event.disputeAbout`
/// (`date` / `detail` / `interpretation`).
class DisputeBadge extends StatelessWidget {
  const DisputeBadge({required this.about, this.label, this.onTap, super.key});

  final DisputeAbout about;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: t.warnBg,
          border: Border.all(color: t.warn.withValues(alpha: 0.4), width: 0.5),
        ),
        child: Text(
          (label ?? about.name).toUpperCase(),
          style: IotdTypography.mono(size: 10.5, color: t.warn, letterSpacing: 1.2),
        ),
      ),
    );
  }
}

enum DisputeAbout { date, detail, interpretation }
