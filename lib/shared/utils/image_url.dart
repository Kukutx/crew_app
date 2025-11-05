/// Returns a sanitized network image URL or `null` when the input is empty or invalid.
/// 
/// Security validations:
/// - Only allows HTTPS protocol
/// - Validates host is not empty
/// - Limits URL length to 2048 characters
/// - Optional: domain whitelist (commented out)
String? sanitizeImageUrl(String? url) {
  final trimmed = url?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null) {
    return null;
  }

  // 只允许https协议
  if (uri.scheme != 'https') {
    return null;
  }

  // 验证host不为空
  if (uri.host.isEmpty) {
    return null;
  }

  // 可选：域名白名单验证
  // const allowedHosts = ['your-cdn.com', 'firebasestorage.googleapis.com'];
  // if (!allowedHosts.contains(uri.host)) {
  //   return null;
  // }

  // URL长度限制
  if (trimmed.length > 2048) {
    return null;
  }

  return trimmed;
}
