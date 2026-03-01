import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  String _tag = 'App';

  void setTag(String tag) {
    _tag = tag;
  }

  void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  void warning(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final effectiveTag = tag ?? _tag;
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();

    if (kDebugMode) {
      switch (level) {
        case LogLevel.debug:
          debugPrint('[$timestamp] $levelStr [$effectiveTag] $message');
          break;
        case LogLevel.info:
          debugPrint('[$timestamp] $levelStr [$effectiveTag] $message');
          break;
        case LogLevel.warning:
          debugPrint('[$timestamp] $levelStr [$effectiveTag] $message');
          if (error != null) {
            debugPrint('Error: $error');
          }
          break;
        case LogLevel.error:
          debugPrint('[$timestamp] $levelStr [$effectiveTag] $message');
          if (error != null) {
            debugPrint('Error: $error');
          }
          if (stackTrace != null) {
            debugPrint('StackTrace: $stackTrace');
          }
          break;
      }
    }
  }
}

final logger = LoggerService();
