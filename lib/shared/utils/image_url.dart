/// Returns a sanitized network image URL or `null` when the input is empty or invalid.
String? sanitizeImageUrl(String? url) {
  final trimmed = url?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null) {
    return null;
  }

  if (uri.hasScheme && uri.host.isNotEmpty) {
    return trimmed;
  }

  return null;
}
