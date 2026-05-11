import 'package:flutter/material.dart';
import '../theme/game_theme.dart';

/// Підсвічує входження [names] у [text] (без урахування регістру), довші рядки першими.
List<TextSpan> buildDialogueHighlightSpans(
  String text,
  List<String> names,
  TextStyle baseStyle,
  TextStyle highlightStyle,
) {
  if (text.isEmpty) return [TextSpan(text: text, style: baseStyle)];
  final needles = names
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList()
    ..sort((a, b) => b.length.compareTo(a.length));

  if (needles.isEmpty) {
    return [TextSpan(text: text, style: baseStyle)];
  }

  final lower = text.toLowerCase();
  final covered = List<bool>.filled(text.length, false);
  final matches = <({int start, int end})>[];

  for (final needle in needles) {
    final n = needle.toLowerCase();
    var from = 0;
    while (from < text.length) {
      final i = lower.indexOf(n, from);
      if (i < 0) break;
      final end = i + needle.length;
      var overlap = false;
      for (var j = i; j < end && j < covered.length; j++) {
        if (covered[j]) {
          overlap = true;
          break;
        }
      }
      if (!overlap) {
        for (var j = i; j < end && j < covered.length; j++) {
          covered[j] = true;
        }
        matches.add((start: i, end: end));
      }
      from = i + 1;
    }
  }

  matches.sort((a, b) => a.start.compareTo(b.start));
  if (matches.isEmpty) {
    return [TextSpan(text: text, style: baseStyle)];
  }

  final spans = <TextSpan>[];
  var cursor = 0;
  for (final m in matches) {
    if (m.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, m.start), style: baseStyle));
    }
    spans.add(TextSpan(text: text.substring(m.start, m.end), style: highlightStyle));
    cursor = m.end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
  }
  return spans;
}

class NewsPanel extends StatelessWidget {
  final String customMessage;
  /// Рядок над основним текстом (наприклад попередження) — показується червоним.
  final String? redWarningPrefix;
  /// Опційний віджет під текстом (наприклад кнопка «Піти роздавати флаєри»).
  final Widget? trailing;
  /// Імена для підсвічування в тексті (активний NPC тощо), без урахування регістру.
  final List<String> highlightNames;

  const NewsPanel({
    super.key,
    this.customMessage = "Ласкаво просимо...",
    this.redWarningPrefix,
    this.trailing,
    this.highlightNames = const [],
  });

  static const TextStyle _baseMessageStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    height: 1.3,
  );

  static final TextStyle _highlightStyle = _baseMessageStyle.copyWith(
    fontWeight: FontWeight.w800,
    color: const Color(0xFFFFD54F),
    shadows: [
      Shadow(
        color: Colors.black.withValues(alpha: 0.85),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );

  static final TextStyle _redWarningStyle = TextStyle(
    color: Colors.red.shade400,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w700,
  );

  Widget _messageRichText() {
    final spans = buildDialogueHighlightSpans(
      customMessage,
      highlightNames,
      _baseMessageStyle,
      _highlightStyle,
    );
    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.start,
      softWrap: true,
    );
  }

  List<Widget> _messageColumnChildren() {
    final w = redWarningPrefix?.trim();
    final children = <Widget>[];
    if (w != null && w.isNotEmpty) {
      children.add(
        Text(w, style: _redWarningStyle, textAlign: TextAlign.start),
      );
      children.add(const SizedBox(height: 12));
    }
    children.add(_messageRichText());
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(15),
          alignment: Alignment.topLeft,
          decoration: BoxDecoration(
            color: GameTheme.bgDark,
            borderRadius: BorderRadius.circular(15),
          ),
          child: SizedBox(
            height: constraints.maxHeight,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: trailing != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ..._messageColumnChildren(),
                        const SizedBox(height: 12),
                        trailing!,
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _messageColumnChildren(),
                    ),
            ),
          ),
        );
      },
    );
  }
}