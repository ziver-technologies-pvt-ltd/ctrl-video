import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';

/// Result of a completed or failed process execution.
class ProcessResultOutput {
  final int exitCode;
  final String stdout;
  final String stderr;

  ProcessResultOutput({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  bool get isSuccess => exitCode == 0;
}

/// A wrapper around Process.start to run commands safely using argument lists
/// (never raw shell strings), stream stdout/stderr, and manage process lifecycle.
class ProcessRunner {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: false,
      printEmojis: false,
    ),
  );

  /// Executes an executable directly with arguments list.
  /// Collects complete stdout and stderr.
  Future<ProcessResultOutput> run({
    required String executable,
    required List<String> arguments,
    String? workingDirectory,
    Map<String, String>? environment,
    Duration? timeout,
  }) async {
    _logger.d('Running: $executable ${arguments.join(' ')}');

    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      runInShell: false, // Security: never invoke shell interpreter
    );

    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();

    final stdoutFuture = process.stdout
        .transform(utf8.decoder)
        .listen(stdoutBuffer.write)
        .asFuture();
    final stderrFuture = process.stderr
        .transform(utf8.decoder)
        .listen(stderrBuffer.write)
        .asFuture();

    Future<int> exitCodeFuture = process.exitCode;
    if (timeout != null) {
      exitCodeFuture = exitCodeFuture.timeout(
        timeout,
        onTimeout: () {
          process.kill(ProcessSignal.sigkill);
          throw TimeoutException('Process timed out after $timeout: $executable');
        },
      );
    }

    final exitCode = await exitCodeFuture;
    await Future.wait([stdoutFuture, stderrFuture]);

    return ProcessResultOutput(
      exitCode: exitCode,
      stdout: stdoutBuffer.toString(),
      stderr: stderrBuffer.toString(),
    );
  }

  /// Starts a process and streams stdout & stderr lines as they are produced.
  /// Useful for download progress bars and live logs.
  Future<Process> startStreaming({
    required String executable,
    required List<String> arguments,
    String? workingDirectory,
    Map<String, String>? environment,
    void Function(String line)? onStdoutLine,
    void Function(String line)? onStderrLine,
  }) async {
    _logger.d('Streaming start: $executable ${arguments.join(' ')}');

    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      runInShell: false,
    );

    if (onStdoutLine != null) {
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(onStdoutLine);
    }

    if (onStderrLine != null) {
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(onStderrLine);
    }

    return process;
  }
}
