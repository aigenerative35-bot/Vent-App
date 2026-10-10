import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Result of a translation attempt. This layer NEVER throws — callers read
/// [ok] / [error] instead, so a bad network or a blocked endpoint can never
/// crash the app.
class TranslateResult {
  final String? text;
  final bool ok;
  final String? error;
  const TranslateResult(this.text, this.ok, this.error);
}

/// Build-time configuration (kept OUT of the repo — pass it on the build).
///
///   flutter build apk --dart-define=TRANSLATE_PROVIDER=google_cloud \
///                     --dart-define=TRANSLATE_API_KEY=YOUR_KEY
///
/// In GitHub Actions, store the key as a repository secret and add
///   --dart-define=TRANSLATE_API_KEY=${{ secrets.TRANSLATE_API_KEY }}
/// to the build step.
class TranslateConfig {
  /// 'google_cloud' | 'sarvam' | 'free'. Empty = auto-pick.
  static const provider = String.fromEnvironment('TRANSLATE_PROVIDER', defaultValue: '');
  static const apiKey = String.fromEnvironment('TRANSLATE_API_KEY', defaultValue: '');

  static bool get hasKey => apiKey.trim().isNotEmpty;

  /// If no official key is set we fall back to key-less public endpoints.
  /// Those are fine for a demo but are NOT licensed for commercial traffic —
  /// set a real key before you ship.
  static String get resolved {
    if (provider.isNotEmpty) return provider;
    return hasKey ? 'google_cloud' : 'free';
  }
}

/// Commercial-safe translation with caching, timeouts, one retry and a
/// graceful fallback chain. All network calls are wrapped so nothing throws.
class TranslateService {
  static final Map<String, String> _cache = {};
  static const _maxLen = 4500; // very long posts are skipped, not sent
  static const _timeout = Duration(seconds: 12);

  static Future<TranslateResult> translate(String text, String target) async {
    final t = text.trim();
    if (t.isEmpty) return TranslateResult(text, true, null);
    if (t.length > _maxLen) {
      return const TranslateResult(null, false, 'Post too long to translate');
    }

    final cacheKey = '$target::${t.hashCode}';
    final hit = _cache[cacheKey];
    if (hit != null) return TranslateResult(hit, true, null);

    TranslateResult r;
    switch (TranslateConfig.resolved) {
      case 'google_cloud':
        r = await _googleCloud(t, target);
        break;
      case 'sarvam':
        r = await _sarvam(t, target);
        break;
      default:
        r = await _free(t, target);
    }

    if (r.ok && r.text != null && r.text!.isNotEmpty) {
      _cache[cacheKey] = r.text!;
    }
    return r;
  }

  // ---- provider 1: Google Cloud Translation v2 (commercial, needs key) ----
  static Future<TranslateResult> _googleCloud(String text, String target) async {
    if (!TranslateConfig.hasKey) return _free(text, target); // graceful downgrade
    try {
      final uri = Uri.parse('https://translation.googleapis.com/language/translate/v2?key=${TranslateConfig.apiKey}');
      final res = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'q': text, 'target': target, 'format': 'text'}))
          .timeout(_timeout);
      if (res.statusCode != 200) {
        return TranslateResult(null, false, _statusMessage(res.statusCode));
      }
      final data = jsonDecode(res.body);
      final out = data['data']?['translations']?[0]?['translatedText'];
      if (out is String && out.trim().isNotEmpty) return TranslateResult(out.trim(), true, null);
      return const TranslateResult(null, false, 'No translation returned');
    } on TimeoutException {
      return const TranslateResult(null, false, 'Translation timed out');
    } catch (_) {
      return const TranslateResult(null, false, 'Translation failed');
    }
  }

  // ---- provider 2: Sarvam AI (good for Indian languages, needs key) ----
  static Future<TranslateResult> _sarvam(String text, String target) async {
    if (!TranslateConfig.hasKey) return _free(text, target);
    try {
      final uri = Uri.parse('https://api.sarvam.ai/translate');
      final res = await http
          .post(uri, headers: {'api-subscription-key': TranslateConfig.apiKey, 'Content-Type': 'application/json'}, body: jsonEncode({
            'input': text,
            'source_language_code': 'auto',
            'target_language_code': _bcp47(target),
            'mode': 'formal',
          }))
          .timeout(_timeout);
      if (res.statusCode != 200) return TranslateResult(null, false, _statusMessage(res.statusCode));
      final data = jsonDecode(res.body);
      final out = data['translated_text'];
      if (out is String && out.trim().isNotEmpty) return TranslateResult(out.trim(), true, null);
      return const TranslateResult(null, false, 'No translation returned');
    } on TimeoutException {
      return const TranslateResult(null, false, 'Translation timed out');
    } catch (_) {
      return const TranslateResult(null, false, 'Translation failed');
    }
  }

  // ---- fallback: key-less public endpoints (demo only, not for commercial) ----
  static Future<TranslateResult> _free(String text, String target) async {
    final g = await _tryGoogleFree(text, target);
    if (g != null) return TranslateResult(g, true, null);
    final m = await _tryMyMemory(text, target);
    if (m != null) return TranslateResult(m, true, null);
    return const TranslateResult(null, false, 'Translation service unreachable');
  }

  static Future<String?> _tryGoogleFree(String text, String target) async {
    try {
      final uri = Uri.parse('https://translate.googleapis.com/translate_a/single'
          '?client=gtx&sl=auto&tl=$target&dt=t&q=${Uri.encodeComponent(text)}');
      final res = await http.get(uri).timeout(_timeout);
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

  static Future<String?> _tryMyMemory(String text, String target) async {
    try {
      final uri = Uri.parse('https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=auto|$target');
      final res = await http.get(uri).timeout(_timeout);
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final out = (data['responseData']?['translatedText'] ?? '').toString().trim();
      if (out.isNotEmpty && !out.toUpperCase().contains('MYMEMORY WARNING')) return out;
    } catch (_) {}
    return null;
  }

  static String _bcp47(String target) => target == 'hi' ? 'hi-IN' : 'en-IN';

  static String _statusMessage(int code) {
    if (code == 401 || code == 403) return 'Translation key rejected';
    if (code == 429) return 'Translation limit reached';
    if (code >= 500) return 'Translation service busy';
    return 'Translation failed ($code)';
  }
}
