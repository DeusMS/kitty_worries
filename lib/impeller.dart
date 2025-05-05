import 'package:flutter/foundation.dart';

void configureImpeller() {
  // отключаем только в debug/profile
  if (!kReleaseMode) {
    debugPrint('Impeller отключён в debug/profile');
    // настройка делается в gradle.properties, этот вызов — просто для логирования
  }
}