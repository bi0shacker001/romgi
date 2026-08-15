import 'dart:io';

import 'package:flutter/services.dart';

/// Resolves the path to the bundled pkg2zip executable and invokes it to
/// decrypt a PS Vita `.pkg` into a NoNpDrm-format zip.
///
/// pkg2zip (https://github.com/mmozeiko/pkg2zip) is vendored unmodified as
/// the `external/pkg2zip` submodule and compiled by
/// `android/app/src/main/cpp/CMakeLists.txt` into a real ELF executable at
/// `jniLibs/<abi>/libpkg2zip.so` — named and placed that way so Android's
/// APK packaging puts it under the app's own (executable) nativeLibraryDir.
/// It's invoked directly as a subprocess rather than through JNI/FFI, the
/// same way the upstream tool is meant to be used.
class VitaDecryptService {
  static const _channel = MethodChannel('com.caprado.romgi/open');

  static String? _nativeLibDir;

  static Future<String> _nativeLibraryDir() async {
    return _nativeLibDir ??=
        await _channel.invokeMethod<String>('getNativeLibraryDir') ??
            (throw StateError('nativeLibraryDir unavailable'));
  }

  static Future<String> pkg2zipPath() async =>
      '${await _nativeLibraryDir()}/libpkg2zip.so';

  /// Decrypts [pkgPath] with [zrif], writing a NoNpDrm-format zip (deflate,
  /// pkg2zip's default zipped mode) into [outputDir]. Returns the zip's path.
  static Future<String> decryptPkgToZip({
    required String pkgPath,
    required String zrif,
    required String outputDir,
  }) async {
    final bin = await pkg2zipPath();
    final result =
        await Process.run(bin, [pkgPath, zrif], workingDirectory: outputDir);
    if (result.exitCode != 0) {
      throw Exception('pkg2zip failed: ${result.stdout}\n${result.stderr}');
    }
    final dir = Directory(outputDir);
    final zip = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.zip'))
        .toList()
      ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    if (zip.isEmpty) {
      throw Exception('pkg2zip did not produce a zip in $outputDir');
    }
    return zip.first.path;
  }
}
