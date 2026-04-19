import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<String> loadVideoPath(String assetPath) async {
  final file = await _copyAssetToLocal(assetPath);
  if (Platform.isIOS) {
    return Uri.file(file.path).toString();
  }
  return file.path;
}

Future<File> _copyAssetToLocal(String assetPath) async {
  final filename = assetPath.split('/').last;
  final tempDir = await getTemporaryDirectory();
  final localFile = File('${tempDir.path}/$filename');
  if (await localFile.exists()) return localFile;
  final data = await rootBundle.load(assetPath);
  await localFile.writeAsBytes(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
  return localFile;
}
