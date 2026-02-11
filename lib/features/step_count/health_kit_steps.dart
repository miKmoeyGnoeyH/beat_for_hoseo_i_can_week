import 'package:flutter/services.dart';

class HealthKitSteps {
  static const _ch = MethodChannel('beat/healthkit_steps');

  static Future<bool> requestAuth() async {
    final ok = await _ch.invokeMethod<bool>('requestAuth');
    return ok ?? false;
  }

  static Future<void> startBGDelivery() async {
    await _ch.invokeMethod('startBGDelivery');
  }

  static Future<int> getTodaySteps() async {
    final v = await _ch.invokeMethod<dynamic>('getTodaySteps');
    return (v as num?)?.toInt() ?? 0;
  }

  static Future<int> getCachedTodaySteps() async {
    final v = await _ch.invokeMethod<dynamic>('getCachedTodaySteps');
    return (v as num?)?.toInt() ?? 0;
  }

  static Future<DateTime?> getCachedLastUpdate() async {
    final v = await _ch.invokeMethod<dynamic>('getCachedLastUpdate');
    final ts = (v as num?)?.toDouble() ?? 0.0;
    if (ts <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch((ts * 1000).toInt());
  }
}