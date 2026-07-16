import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const int _maximumScreenshotBytes = 4 * 1024 * 1024;
const int _screenshotWidth = 824;
const int _screenshotHeight = 1830;
const List<String> _expectedScreenshotNames = <String>[
  'app-bar-and-view-light.png',
  'bottom-navigation-dark.png',
  'buttons-light.png',
  'alert-dialog-light.png',
  'sliders-dark.png',
];

Future<void> main(List<String> arguments) async {
  try {
    final _Options options = _Options.parse(arguments);
    final Directory root = File.fromUri(Platform.script).parent.parent;
    final File pubspecFile = File('${root.path}/pubspec.yaml');
    final File changelogFile = File('${root.path}/CHANGELOG.md');
    final File readmeFile = File('${root.path}/README.md');

    for (final File file in <File>[pubspecFile, changelogFile, readmeFile]) {
      if (!file.existsSync()) {
        throw _ReleaseFailure('Required release file not found: ${file.path}');
      }
    }

    final String pubspec = pubspecFile.readAsStringSync();
    final String changelog = changelogFile.readAsStringSync();
    final String readme = readmeFile.readAsStringSync();
    final String packageName = _requireTopLevelScalar(pubspec, 'name');
    final String packageVersion = _requireTopLevelScalar(pubspec, 'version');

    _validateSemanticVersion(options.expectedVersion);
    _requireEqual(
      actual: packageVersion,
      expected: options.expectedVersion,
      source: 'pubspec.yaml version',
    );
    _validateChangelog(changelog, options.expectedVersion);
    _validateReadmeVersion(readme, options.expectedVersion);

    final List<_Screenshot> screenshots = _parseScreenshots(pubspec);
    _validateScreenshots(root, readme, screenshots);

    if (options.requireUnpublished) {
      _validateGitTags(root, options.expectedVersion);
      await _validatePubDev(packageName, options.expectedVersion);
    }

    stdout.writeln(
      'Release metadata is consistent for $packageName ${options.expectedVersion}; '
      '${screenshots.length} screenshots validated.',
    );
  } on _ReleaseFailure catch (error) {
    stderr.writeln('Release check failed: ${error.message}');
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln('Release check failed: ${error.message}');
    exitCode = 1;
  }
}

final class _Options {
  const _Options({
    required this.expectedVersion,
    required this.requireUnpublished,
  });

  factory _Options.parse(List<String> arguments) {
    String? expectedVersion;
    bool requireUnpublished = false;

    for (int index = 0; index < arguments.length; index += 1) {
      final String argument = arguments[index];
      if (argument == '--help' || argument == '-h') {
        stdout.writeln(
          'Usage: dart run tool/check_release.dart '
          '--expected-version <semver> [--require-unpublished]',
        );
        exit(0);
      }
      if (argument == '--require-unpublished') {
        requireUnpublished = true;
        continue;
      }
      if (argument.startsWith('--expected-version=')) {
        expectedVersion = argument.substring('--expected-version='.length);
        continue;
      }
      if (argument == '--expected-version') {
        index += 1;
        if (index >= arguments.length || arguments[index].startsWith('--')) {
          throw const _ReleaseFailure('Missing value for --expected-version.');
        }
        expectedVersion = arguments[index];
        continue;
      }
      throw _ReleaseFailure('Unknown argument: $argument');
    }

    if (expectedVersion == null || expectedVersion.trim().isEmpty) {
      throw const _ReleaseFailure('--expected-version is required.');
    }
    return _Options(
      expectedVersion: expectedVersion,
      requireUnpublished: requireUnpublished,
    );
  }

  final String expectedVersion;
  final bool requireUnpublished;
}

String _requireTopLevelScalar(String yaml, String key) {
  for (final String line in const LineSplitter().convert(yaml)) {
    if (line.startsWith('$key:')) {
      final String value = _decodeYamlScalar(line.substring(key.length + 1));
      if (value.isNotEmpty) {
        return value;
      }
    }
  }
  throw _ReleaseFailure('pubspec.yaml is missing a top-level `$key` value.');
}

String _decodeYamlScalar(String source) {
  String value = source.split(' #').first.trim();
  if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
    try {
      return jsonDecode(value) as String;
    } on FormatException {
      throw _ReleaseFailure('Invalid quoted YAML value: $value');
    }
  }
  if (value.length >= 2 && value.startsWith("'") && value.endsWith("'")) {
    value = value.substring(1, value.length - 1).replaceAll("''", "'");
  }
  return value;
}

void _validateSemanticVersion(String version) {
  final RegExp semanticVersion = RegExp(
    r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)'
    r'(?:-[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?'
    r'(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$',
  );
  if (!semanticVersion.hasMatch(version)) {
    throw _ReleaseFailure(
      'Expected version is not valid semantic versioning: $version',
    );
  }
}

void _validateChangelog(String changelog, String expectedVersion) {
  final RegExpMatch? firstHeading = RegExp(
    r'^##\s+([^\s]+)\s*$',
    multiLine: true,
  ).firstMatch(changelog);
  if (firstHeading == null) {
    throw const _ReleaseFailure('CHANGELOG.md has no version heading.');
  }
  _requireEqual(
    actual: firstHeading.group(1)!,
    expected: expectedVersion,
    source: 'first CHANGELOG.md heading',
  );
}

void _validateReadmeVersion(String readme, String expectedVersion) {
  final RegExpMatch? dependency = RegExp(
    r'^\s*one_ui:\s*\^?([0-9A-Za-z.+-]+)\s*$',
    multiLine: true,
  ).firstMatch(readme);
  if (dependency == null) {
    throw const _ReleaseFailure(
      'README.md has no one_ui dependency installation example.',
    );
  }
  _requireEqual(
    actual: dependency.group(1)!,
    expected: expectedVersion,
    source: 'README.md dependency version',
  );
}

List<_Screenshot> _parseScreenshots(String pubspec) {
  final List<_Screenshot> screenshots = <_Screenshot>[];
  Map<String, String>? current;
  bool inScreenshots = false;

  void addCurrent() {
    final Map<String, String>? fields = current;
    if (fields == null) {
      return;
    }
    final String? description = fields['description'];
    final String? path = fields['path'];
    if (description == null ||
        description.isEmpty ||
        path == null ||
        path.isEmpty) {
      throw const _ReleaseFailure(
        'Every pubspec screenshot needs a non-empty description and path.',
      );
    }
    screenshots.add(_Screenshot(description: description, path: path));
  }

  for (final String line in const LineSplitter().convert(pubspec)) {
    if (!inScreenshots) {
      if (line == 'screenshots:') {
        inScreenshots = true;
      }
      continue;
    }
    if (line.trim().isEmpty || line.trimLeft().startsWith('#')) {
      continue;
    }
    if (!line.startsWith(' ')) {
      break;
    }

    final String trimmed = line.trim();
    if (trimmed.startsWith('- ')) {
      addCurrent();
      current = <String, String>{};
      _parseScreenshotField(trimmed.substring(2), current);
    } else {
      if (current == null) {
        throw const _ReleaseFailure('Malformed pubspec screenshots list.');
      }
      _parseScreenshotField(trimmed, current);
    }
  }
  addCurrent();

  if (!inScreenshots) {
    throw const _ReleaseFailure(
      'pubspec.yaml has no top-level screenshots list.',
    );
  }
  return screenshots;
}

void _parseScreenshotField(String source, Map<String, String> destination) {
  final int separator = source.indexOf(':');
  if (separator <= 0) {
    throw _ReleaseFailure('Malformed screenshot metadata: $source');
  }
  final String key = source.substring(0, separator).trim();
  if (key != 'description' && key != 'path') {
    return;
  }
  if (destination.containsKey(key)) {
    throw _ReleaseFailure('Duplicate screenshot `$key` value.');
  }
  destination[key] = _decodeYamlScalar(source.substring(separator + 1));
}

void _validateScreenshots(
  Directory root,
  String readme,
  List<_Screenshot> screenshots,
) {
  if (screenshots.length != _expectedScreenshotNames.length) {
    throw _ReleaseFailure(
      'Expected ${_expectedScreenshotNames.length} screenshots, '
      'found ${screenshots.length}.',
    );
  }

  final String resolvedRoot = root.resolveSymbolicLinksSync();
  final Set<String> paths = <String>{};
  for (int index = 0; index < screenshots.length; index += 1) {
    final _Screenshot screenshot = screenshots[index];
    final List<String> pathSegments = screenshot.path.split('/');
    if (screenshot.path.startsWith('/') || pathSegments.contains('..')) {
      throw _ReleaseFailure(
        'Screenshot path must stay inside the package: ${screenshot.path}',
      );
    }
    if (!paths.add(screenshot.path)) {
      throw _ReleaseFailure('Duplicate screenshot path: ${screenshot.path}');
    }

    final String expectedName = _expectedScreenshotNames[index];
    final String actualName = pathSegments.last;
    _requireEqual(
      actual: actualName,
      expected: expectedName,
      source: 'screenshot ${index + 1} filename',
    );
    if (screenshot.description.runes.length > 160) {
      throw _ReleaseFailure(
        'Screenshot description exceeds 160 characters: ${screenshot.path}',
      );
    }
    if (!readme.contains(actualName)) {
      throw _ReleaseFailure(
        'README.md does not reference screenshot: $actualName',
      );
    }

    final File file = File('${root.path}/${screenshot.path}');
    if (!file.existsSync()) {
      throw _ReleaseFailure('Screenshot file not found: ${screenshot.path}');
    }
    final String resolvedFile = file.resolveSymbolicLinksSync();
    if (resolvedFile != resolvedRoot &&
        !resolvedFile.startsWith('$resolvedRoot${Platform.pathSeparator}')) {
      throw _ReleaseFailure(
        'Screenshot resolves outside the package: ${screenshot.path}',
      );
    }
    if (file.lengthSync() > _maximumScreenshotBytes) {
      throw _ReleaseFailure('Screenshot exceeds 4 MiB: ${screenshot.path}');
    }
    _validatePng(file, screenshot.path);
  }
}

void _validatePng(File file, String displayPath) {
  final Uint8List bytes = file.readAsBytesSync();
  const List<int> signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
  if (bytes.length < 24 ||
      !List<int>.generate(8, (int index) => bytes[index]).asMap().entries.every(
        (MapEntry<int, int> entry) => entry.value == signature[entry.key],
      )) {
    throw _ReleaseFailure('Screenshot is not a valid PNG: $displayPath');
  }
  final ByteData data = ByteData.sublistView(bytes);
  final int width = data.getUint32(16, Endian.big);
  final int height = data.getUint32(20, Endian.big);
  if (width != _screenshotWidth || height != _screenshotHeight) {
    throw _ReleaseFailure(
      'Screenshot must be ${_screenshotWidth}x$_screenshotHeight pixels, '
      'found ${width}x$height: $displayPath',
    );
  }
}

void _validateGitTags(Directory root, String expectedVersion) {
  final ProcessResult result = Process.runSync('git', <String>[
    'tag',
    '--list',
  ], workingDirectory: root.path);
  if (result.exitCode != 0) {
    throw _ReleaseFailure('Unable to inspect Git tags: ${result.stderr}');
  }
  final Set<String> tags = const LineSplitter()
      .convert(result.stdout as String)
      .map((String tag) => tag.trim())
      .where((String tag) => tag.isNotEmpty)
      .toSet();
  if (tags.contains(expectedVersion) || tags.contains('v$expectedVersion')) {
    throw _ReleaseFailure('A Git tag already exists for $expectedVersion.');
  }
}

Future<void> _validatePubDev(String packageName, String expectedVersion) async {
  final HttpClient client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10)
    ..userAgent = 'one_ui-release-check';
  try {
    final Uri uri = Uri.https('pub.dev', '/api/packages/$packageName');
    final HttpClientRequest request = await client
        .getUrl(uri)
        .timeout(const Duration(seconds: 15));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final HttpClientResponse response = await request.close().timeout(
      const Duration(seconds: 15),
    );
    if (response.statusCode == HttpStatus.notFound) {
      await response.drain<void>();
      return;
    }
    final String body = await utf8.decoder
        .bind(response)
        .join()
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != HttpStatus.ok) {
      throw _ReleaseFailure(
        'pub.dev returned HTTP ${response.statusCode} for $packageName.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw const _ReleaseFailure(
        'pub.dev returned malformed package metadata.',
      );
    }
    if (decoded is! Map<String, Object?> ||
        decoded['versions'] is! List<Object?>) {
      throw const _ReleaseFailure(
        'pub.dev package metadata has an unexpected shape.',
      );
    }
    final bool alreadyPublished = (decoded['versions']! as List<Object?>).any(
      (Object? entry) =>
          entry is Map<String, Object?> && entry['version'] == expectedVersion,
    );
    if (alreadyPublished) {
      throw _ReleaseFailure(
        '$packageName $expectedVersion is already published on pub.dev.',
      );
    }
  } on SocketException catch (error) {
    throw _ReleaseFailure('Unable to query pub.dev: ${error.message}');
  } on TimeoutException {
    throw const _ReleaseFailure('Timed out while querying pub.dev.');
  } finally {
    client.close(force: true);
  }
}

void _requireEqual({
  required String actual,
  required String expected,
  required String source,
}) {
  if (actual != expected) {
    throw _ReleaseFailure('$source is `$actual`; expected `$expected`.');
  }
}

final class _Screenshot {
  const _Screenshot({required this.description, required this.path});

  final String description;
  final String path;
}

final class _ReleaseFailure implements Exception {
  const _ReleaseFailure(this.message);

  final String message;
}
