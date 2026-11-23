import 'dart:io';
import 'package:logger/logger.dart';
import 'path_resolver.dart';

/// Rotating local file logger that captures diagnostic logs for user support.
class AppLogger {
  static Logger? _logger;
  static File? _currentLogFile;

  static Future<void> initialize() async {
    final logsDir = await PathResolver.getLogsDirectory();
    _currentLogFile = File('${logsDir.path}/app.log');

    // Simple rotation: if log file is > 2MB, rename to app.log.old
    if (await _currentLogFile!.exists()) {
      final length = await _currentLogFile!.length();
      if (length > 2 * 1024 * 1024) {
        final oldFile = File('${logsDir.path}/app.log.old');
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
        await _currentLogFile!.rename(oldFile.path);
        _currentLogFile = File('${logsDir.path}/app.log');
      }
    }

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        colors: false,
        printEmojis: false,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        _FileOutput(_currentLogFile!),
      ]),
    );
  }

  static Logger get instance {
    return _logger ??
        Logger(
          printer: PrettyPrinter(methodCount: 0, colors: false, printEmojis: false),
        );
  }

  static Future<String> getDiagnosticInfo() async {
    final sb = StringBuffer();
    sb.writeln('=== ctrl+video Diagnostic Log ===');
    sb.writeln('OS: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
    sb.writeln('Dart: ${Platform.version}');
    sb.writeln('Platform Key: ${PathResolver.getPlatformKey()}');

    if (_currentLogFile != null && await _currentLogFile!.exists()) {
      sb.writeln('\n--- Recent Logs ---');
      final lines = await _currentLogFile!.readAsLines();
      final recent = lines.length > 100 ? lines.sublist(lines.length - 100) : lines;
      sb.writeln(recent.join('\n'));
    }

    return sb.toString();
  }
}

class _FileOutput extends LogOutput {
  final File file;

  _FileOutput(this.file);

  @override
  void output(OutputEvent event) {
    try {
      final sink = file.openWrite(mode: FileMode.append);
      for (final line in event.lines) {
        sink.writeln('${DateTime.now().toIso8601String()} $line');
      }
      sink.close();
    } catch (_) {}
  }
}
