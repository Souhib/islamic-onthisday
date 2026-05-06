/// Collapse pipeline-source line breaks into renderable prose.
///
/// The dataset YAML stores descriptions as literal block scalars
/// (``|``) which preserve line breaks from the source file. HTML
/// rendering on the web collapses single newlines into whitespace
/// automatically; Flutter's ``Text`` widget renders them as hard
/// breaks. This helper closes the gap:
///
///   - runs of two or more newlines → ``\n\n`` (paragraph break)
///   - single newlines → space
///   - leading/trailing whitespace trimmed
///
/// We swap real paragraph breaks for a sentinel control char before
/// collapsing single ``\n``s, then restore the sentinel at the end —
/// avoids accidentally turning soft wraps into paragraphs.
String collapseHardBreaks(String input) {
  if (input.isEmpty) return input;
  const paragraphSentinel = '';
  return input
      .replaceAll('\r\n', '\n')
      .replaceAll(RegExp(r'\n{2,}'), paragraphSentinel)
      .replaceAll('\n', ' ')
      .replaceAll(paragraphSentinel, '\n\n')
      .replaceAll(RegExp(r' {2,}'), ' ')
      .trim();
}
