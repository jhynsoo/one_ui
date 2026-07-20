import 'dart:io';

const String _defaultInput = 'coverage/lcov.info';
const double _defaultMinimum = 85;

void main(List<String> arguments) {
  try {
    final _Options options = _Options.parse(arguments);
    final File input = File(options.inputPath);
    if (!input.existsSync()) {
      throw _CoverageFailure(
        'Coverage file not found: ${input.path}. Run `flutter test --coverage` first.',
      );
    }

    final _Coverage coverage = _Coverage.fromLcov(input.readAsLinesSync());
    final double percentage = coverage.percentage;
    stdout.writeln(
      'Line coverage: ${percentage.toStringAsFixed(2)}% '
      '(${coverage.coveredLines}/${coverage.totalLines}); '
      'minimum: ${options.minimum.toStringAsFixed(2)}%.',
    );

    if (percentage < options.minimum) {
      throw _CoverageFailure(
        'Line coverage is below the configured minimum by '
        '${(options.minimum - percentage).toStringAsFixed(2)} percentage points.',
      );
    }
  } on _CoverageFailure catch (error) {
    stderr.writeln('Coverage check failed: ${error.message}');
    exitCode = 1;
  }
}

final class _Options {
  const _Options({required this.inputPath, required this.minimum});

  factory _Options.parse(List<String> arguments) {
    String inputPath = _defaultInput;
    double minimum = _defaultMinimum;

    for (int index = 0; index < arguments.length; index += 1) {
      final String argument = arguments[index];
      if (argument == '--help' || argument == '-h') {
        stdout.writeln(
          'Usage: dart run tool/check_coverage.dart '
          '[--input coverage/lcov.info] [--minimum 85]',
        );
        exit(0);
      }

      final String? inlineInput = _inlineValue(argument, '--input');
      if (inlineInput != null) {
        inputPath = inlineInput;
        continue;
      }
      final String? inlineMinimum = _inlineValue(argument, '--minimum');
      if (inlineMinimum != null) {
        minimum = _parseMinimum(inlineMinimum);
        continue;
      }

      switch (argument) {
        case '--input':
          inputPath = _nextValue(arguments, ++index, argument);
        case '--minimum':
          minimum = _parseMinimum(_nextValue(arguments, ++index, argument));
        default:
          throw _CoverageFailure('Unknown argument: $argument');
      }
    }

    if (inputPath.trim().isEmpty) {
      throw _CoverageFailure('The coverage input path must not be empty.');
    }
    return _Options(inputPath: inputPath, minimum: minimum);
  }

  final String inputPath;
  final double minimum;

  static String? _inlineValue(String argument, String option) {
    final String prefix = '$option=';
    return argument.startsWith(prefix)
        ? argument.substring(prefix.length)
        : null;
  }

  static String _nextValue(List<String> arguments, int index, String option) {
    if (index >= arguments.length || arguments[index].startsWith('--')) {
      throw _CoverageFailure('Missing value for $option.');
    }
    return arguments[index];
  }

  static double _parseMinimum(String value) {
    final double? minimum = double.tryParse(value);
    if (minimum == null || !minimum.isFinite || minimum < 0 || minimum > 100) {
      throw _CoverageFailure(
        'The minimum must be a number between 0 and 100: $value',
      );
    }
    return minimum;
  }
}

final class _Coverage {
  const _Coverage({required this.coveredLines, required this.totalLines});

  factory _Coverage.fromLcov(List<String> lines) {
    final Map<String, Map<int, int>> records = <String, Map<int, int>>{};
    String? sourceFile;

    for (final String line in lines) {
      if (line.startsWith('SF:')) {
        sourceFile = line.substring(3).trim();
        if (sourceFile.isEmpty) {
          throw _CoverageFailure('An LCOV source record has no file path.');
        }
        records.putIfAbsent(sourceFile, () => <int, int>{});
        continue;
      }
      if (!line.startsWith('DA:')) {
        continue;
      }
      if (sourceFile == null) {
        throw _CoverageFailure(
          'An LCOV line record appears before its source file.',
        );
      }

      final List<String> fields = line.substring(3).split(',');
      if (fields.length < 2) {
        throw _CoverageFailure('Malformed LCOV line record: $line');
      }
      final int? lineNumber = int.tryParse(fields[0]);
      final int? hitCount = int.tryParse(fields[1]);
      if (lineNumber == null ||
          lineNumber <= 0 ||
          hitCount == null ||
          hitCount < 0) {
        throw _CoverageFailure('Malformed LCOV line record: $line');
      }

      final Map<int, int> sourceLines = records[sourceFile]!;
      final int previousHitCount = sourceLines[lineNumber] ?? 0;
      if (hitCount > previousHitCount) {
        sourceLines[lineNumber] = hitCount;
      } else {
        sourceLines.putIfAbsent(lineNumber, () => hitCount);
      }
    }

    final Iterable<int> hitCounts = records.values.expand(
      (Map<int, int> sourceLines) => sourceLines.values,
    );
    final List<int> materializedHitCounts = hitCounts.toList(growable: false);
    if (materializedHitCounts.isEmpty) {
      throw _CoverageFailure(
        'No executable line records were found in the LCOV file.',
      );
    }

    return _Coverage(
      coveredLines: materializedHitCounts
          .where((int count) => count > 0)
          .length,
      totalLines: materializedHitCounts.length,
    );
  }

  final int coveredLines;
  final int totalLines;

  double get percentage => coveredLines * 100 / totalLines;
}

final class _CoverageFailure implements Exception {
  const _CoverageFailure(this.message);

  final String message;
}
