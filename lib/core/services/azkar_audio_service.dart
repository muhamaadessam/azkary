import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AzkarAudioService {
  static Future<String?> localPathFor(String url) async {
    final file = await _fileFor(url);
    return await file.exists() ? file.path : null;
  }

  static Future<bool> areAllDownloaded(Iterable<String> urls) async {
    for (final url in urls) {
      if (await localPathFor(url) == null) return false;
    }
    return true;
  }

  static Future<String> download(String url) async {
    final file = await _fileFor(url);
    if (await file.exists()) return file.path;

    final partial = File('${file.path}.part');
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Audio download failed: ${response.statusCode}');
      }
      await response.pipe(partial.openWrite());
      await partial.rename(file.path);
      return file.path;
    } finally {
      client.close(force: true);
      if (await partial.exists() && !await file.exists()) {
        await partial.delete();
      }
    }
  }

  static Future<File> _fileFor(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final uri = Uri.parse(url);
    final name = '${uri.host}_${uri.pathSegments.last}'.replaceAll(
      RegExp(r'[^A-Za-z0-9_.-]'),
      '_',
    );
    return File('${directory.path}/azkar_audio_$name');
  }
}
