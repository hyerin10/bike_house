// Converts import/export in lib/ from relative URIs to package:bike_house/...
// Run from repo root: dart run tool/convert_to_package_imports.dart
import 'dart:io';

void main() {
  final root = Directory.current.path;
  final libDir = Directory(_join(root, 'lib'));
  if (!libDir.existsSync()) {
    stderr.writeln('lib directory not found.');
    exitCode = 1;
    return;
  }

  const packageName = 'bike_house';
  final libRoot = _normalizePath(libDir.absolute.path);

  final importLine = RegExp(
    r'''^(\s*(?:import|export)\s+)(['"])([^'"]+)\2(.*);\s*$''',
  );

  var changedFiles = 0;

  for (final entity in libDir.listSync(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;

    final filePath = _normalizePath(entity.absolute.path);
    final original = entity.readAsStringSync();
    final lines = original.split('\n');
    final newLines = <String>[];

    for (final raw in lines) {
      final line = raw.replaceAll('\r', '');
      final match = importLine.firstMatch(line);
      if (match == null) {
        newLines.add(raw);
        continue;
      }

      final uri = match.group(3)!;
      if (uri.startsWith('package:') || uri.startsWith('dart:')) {
        newLines.add(raw);
        continue;
      }

      final newUri = _toPackageUri(
        uri,
        _dirname(filePath),
        libRoot,
        packageName,
      );

      if (newUri == null) {
        newLines.add(raw);
        continue;
      }

      final q = match.group(2)!;
      newLines.add('${match.group(1)!}$q$newUri$q${match.group(4)!};');
    }

    final updated = newLines.join('\n');
    if (updated != original) {
      entity.writeAsStringSync(updated);
      changedFiles++;
      stdout.writeln(_relativePath(entity.path, root));
    }
  }

  stdout.writeln('\nUpdated $changedFiles file(s).');
}

String _join(String a, String b) {
  if (a.endsWith(Platform.pathSeparator)) return '$a$b';
  return '$a${Platform.pathSeparator}$b';
}

String _dirname(String path) {
  final norm = path.replaceAll('/', Platform.pathSeparator);
  final i = norm.lastIndexOf(Platform.pathSeparator);
  if (i <= 0) return norm;
  return norm.substring(0, i);
}

String _normalizePath(String path) =>
    File(path).absolute.path.replaceAll('/', Platform.pathSeparator);

String _relativePath(String absolute, String from) {
  final prefix = _join(from, '');
  if (absolute.startsWith(prefix)) {
    return absolute.substring(prefix.length);
  }
  return absolute;
}

String? _toPackageUri(
  String uri,
  String fileDir,
  String libRoot,
  String packageName,
) {
  final base = fileDir.endsWith(Platform.pathSeparator)
      ? fileDir
      : '$fileDir${Platform.pathSeparator}';
  final resolvedUri =
      Uri.directory(base, windows: Platform.isWindows).resolve(uri);
  final resolvedPath =
      File(resolvedUri.toFilePath(windows: Platform.isWindows)).absolute.path;

  final rel = _relativeToLib(_normalizePath(resolvedPath), libRoot);
  if (rel == null) {
    stderr.writeln('SKIP (outside lib): $uri');
    return null;
  }
  return 'package:$packageName/${rel.replaceAll(r'\', '/')}';
}

String? _relativeToLib(String absolute, String libRoot) {
  var lib = libRoot.replaceAll(r'\', '/');
  if (!lib.endsWith('/')) lib = '$lib/';
  final abs = absolute.replaceAll(r'\', '/');
  if (abs.length < lib.length) return null;
  if (abs.toLowerCase().substring(0, lib.length) != lib.toLowerCase()) {
    return null;
  }
  return abs.substring(lib.length);
}
