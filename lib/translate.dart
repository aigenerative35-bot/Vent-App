import 'dart:convert';
import 'package:http/http.dart' as http;

/// Free, key-less translation used by the "Translate" option on a post.
///
/// It tries Google's public translate endpoint first and falls back to the
/// MyMemory API. Both need no account or API key, so this works out of the
/// box. If you later want a paid/enterprise translator (e.g. a Cloud
/// Translation API key), replace [_google]/[_myMemory] — nothing else changes.
class Translator {
  /// Returns the translated text, or null if it could not be translated.
  static Future<String?> translate(String text, String target) async {
    final t = text.trim();
    if (t.isEmpty) return null;
    final g = await _google(t, target);
    if (g != null) return g;
    return _myMemory(t, target);
  }

  static Future<String?> _google(String text, String target) async {
    try {
      final uri = Uri.parse('https://translate.googleapis.com/translate_a/single'
          '?client=gtx&sl=auto&tl=$target&dt=t&q=${Uri.encodeComponent(text)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      if (data is List && data.isNotEmpty && data[0] is List) {
        final buf = StringBuffer();
        for (final seg in data[0] as List) {
          if (seg is List && seg.isNotEmpty && seg[0] is String) buf.write(seg[0]);
        }
        final out = buf.toString().trim();
        if (out.isNotEmpty) return out;
      }
    } catch (_) {}
    return null;
  }

  static Future<String?> _myMemory(String text, String target) async {
    try {
      final uri = Uri.parse('https://api.mymemory.translated.net/get'
          '?q=${Uri.encodeComponent(text)}&langpair=auto|$target');
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final out = (data['responseData']?['translatedText'] ?? '').toString().trim();
      if (out.isNotEmpty && !out.toUpperCase().contains('MYMEMORY WARNING')) return out;
    } catch (_) {}
    return null;
  }
}
