import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

import '../log_entry.dart';
import '../log_formatter.dart';
import '../log_filter.dart';
import '../log_level.dart';
import '../config/file_config.dart';
import 'log_handler.dart';

class FileLogHandler extends LogHandler {
  final FileLogConfig config;
  final Lock _fileLock = Lock();
  File? _logFile;
  int _currentLogSize = 0;
  bool _isInitialized = false;

  FileLogHandler({
    LogFilter? filter,
    LogFormatter? formatter,
    FileLogConfig? config,
  })  : config = config ?? const FileLogConfig(),
        super(
          filter: filter ?? LevelFilter(LogLevel.info),
          formatter: formatter ?? DetailedLogFormatter(forFile: true),
        ) {
    _initLogFile();
  }

  @override
  Future<void> handle(LogEntry entry) async {
    if (!_isInitialized) {
      await _initLogFile();
    }

    if (_logFile == null) return;

    await _writeToFile(entry);
  }

  Future<void> _initLogFile() async {
    if (!config.enabled) return;

    try {
      final directory = await _getLogDirectory();
      final path = '${directory.path}/${config.fileName}.log';
      _logFile = File(path);

      if (await _logFile!.exists()) {
        _currentLogSize = await _logFile!.length();
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FileLogHandler: Gagal menginisialisasi file log: $e');
      }
    }
  }

  Future<Directory> _getLogDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDir.path}/logs');

    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    return logDir;
  }

  Future<void> _writeToFile(LogEntry entry) async {
    if (_logFile == null) return;

    return _fileLock.synchronized(() async {
      try {
        final logEntry = formatter.format(entry);
        await _logFile!.writeAsString('$logEntry\n--------------------\n',
            mode: FileMode.append);

        _currentLogSize +=
            logEntry.length + 24;
        if (_currentLogSize > config.maxFileSize) {
          await _rotateLogFiles();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('FileLogHandler: Gagal menulis ke file log: $e');
        }
      }
    });
  }

  Future<void> _rotateLogFiles() async {
    try {
      final directory = await _getLogDirectory();

      for (int i = config.maxFiles; i > 0; i--) {
        final oldFile = File(
          '${directory.path}/${config.fileName}.$i.log',
        );

        if (await oldFile.exists() && i == config.maxFiles) {
          await oldFile.delete();
        } else if (await oldFile.exists()) {
          await oldFile.rename(
            '${directory.path}/${config.fileName}.${i + 1}.log',
          );
        }
      }

      if (_logFile != null && await _logFile!.exists()) {
        await _logFile!.rename(
          '${directory.path}/${config.fileName}.1.log',
        );
      }

      _logFile = File('${directory.path}/${config.fileName}.log');
      _currentLogSize = 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FileLogHandler: Gagal merotasi file log: $e');
      }
    }
  }

  Future<void> clearLogs() async {
    return _fileLock.synchronized(() async {
      try {
        final directory = await _getLogDirectory();
        final files = await directory.list().toList();

        for (var entity in files) {
          if (entity is File && entity.path.contains(config.fileName)) {
            await entity.delete();
          }
        }

        _logFile = File('${directory.path}/${config.fileName}.log');
        _currentLogSize = 0;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('FileLogHandler: Gagal menghapus file log: $e');
        }
      }
    });
  }

  Future<List<File>> getLogFiles() async {
    try {
      final directory = await _getLogDirectory();
      final files = await directory.list().toList();

      return files
          .whereType<File>()
          .where((file) => file.path.contains(config.fileName))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FileLogHandler: Gagal mendapatkan file log: $e');
      }
      return [];
    }
  }

  @override
  Future<void> dispose() async {
    await _fileLock.synchronized(() async {
      _logFile = null;
      _isInitialized = false;
    });
  }
}
