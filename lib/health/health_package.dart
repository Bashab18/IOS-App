// Health Data Package - Export all health related functionality

// Core Models
export 'health_data_model.dart';
import 'health_data_model.dart';

// Services
export 'health_service.dart';
import 'health_service.dart';
export 'health_repository.dart';
import 'health_repository.dart';
export 'health_permissions.dart';
import 'health_permissions.dart';

// API Layer
export 'health_api.dart';
import 'health_api.dart';

// Main Health Package Interface
class HealthPackage {
  static final HealthPackage _instance = HealthPackage._internal();
  factory HealthPackage() => _instance;

  HealthPackage._internal();

  // Quick access to most common operations
  static Future<List<HealthDataModel>> getTodayData() {
    return HealthAPI.getTodayData();
  }

  static Future<HealthSummary> getTodaySummary() {
    return HealthAPI.getTodaySummary();
  }

  static Future<bool> initialize() {
    return HealthAPI.initialize();
  }

  static Future<bool> requestPermissions() {
    return HealthAPI.requestPermissions();
  }
}
