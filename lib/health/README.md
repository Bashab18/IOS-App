 # Health Data Package

A comprehensive Flutter package for accessing and managing health data from various sources including Health Connect (Android) and HealthKit (iOS). This package provides a simple, unified API for retrieving health metrics, writing health data, and managing permissions.

## Features

- 📊 **Comprehensive Health Data**: Access steps, heart rate, weight, sleep, distance, calories, and more
- 🔐 **Permission Management**: Simplified permission handling for health data access
- 📱 **Cross-Platform**: Supports both Android (Health Connect) and iOS (HealthKit)
- 🎯 **Simple API**: Easy-to-use endpoints for common health data operations
- 📈 **Data Aggregation**: Built-in summary and aggregation functions
- 🔄 **Real-time Data**: Write and read health data in real-time
- 📦 **Package-like Structure**: Modular design for easy integration

## Installation

### 1. Add Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  health: ^10.2.0
  permission_handler: ^11.3.1
```

### 2. Copy Health Package Files

Copy the entire `health/` directory to your project's `lib/` folder:

```
lib/
├── health/
│   ├── health_package.dart      # Main entry point
│   ├── health_api.dart          # Static API interface
│   ├── health_service.dart      # Service layer
│   ├── health_repository.dart   # Data repository
│   ├── health_permissions.dart  # Permission management
│   ├── health_data_model.dart   # Data models
│   └── example_usage.dart       # Usage examples
```

### 3. Android Setup

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.health.READ_STEPS" />
<uses-permission android:name="android.permission.health.WRITE_STEPS" />
<uses-permission android:name="android.permission.health.READ_HEART_RATE" />
<uses-permission android:name="android.permission.health.WRITE_HEART_RATE" />
<uses-permission android:name="android.permission.health.READ_WEIGHT" />
<uses-permission android:name="android.permission.health.WRITE_WEIGHT" />
<uses-permission android:name="android.permission.health.READ_HEIGHT" />
<uses-permission android:name="android.permission.health.READ_SLEEP" />
<uses-permission android:name="android.permission.health.READ_DISTANCE" />
<uses-permission android:name="android.permission.health.READ_ACTIVE_CALORIES_BURNED" />
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

### 4. iOS Setup

Add to `ios/Runner/Info.plist`:

```xml
<key>NSHealthShareUsageDescription</key>
<string>This app needs access to health data to track your fitness progress</string>
<key>NSHealthUpdateUsageDescription</key>
<string>This app needs to write health data to keep your records up to date</string>
```

## Quick Start

### Basic Usage

```dart
import 'package:your_app/health/health_package.dart';

class MyHealthApp {
  Future<void> initializeHealth() async {
    // Initialize and check permissions
    bool initialized = await HealthPackage.initialize();
    if (!initialized) {
      // Request permissions
      bool granted = await HealthPackage.requestPermissions();
      if (!granted) {
        print('Health permissions not granted');
        return;
      }
    }
    
    // Get today's health data
    List<HealthDataModel> todayData = await HealthPackage.getTodayData();
    print('Found ${todayData.length} health data points');
    
    // Get today's summary
    HealthSummary summary = await HealthPackage.getTodaySummary();
    print('Steps today: ${summary.totalSteps}');
    print('Distance today: ${summary.totalDistance.toStringAsFixed(2)} km');
  }
}
```

### In a Flutter Widget

```dart
import 'package:flutter/material.dart';
import 'package:your_app/health/health_package.dart';

class HealthDashboard extends StatefulWidget {
  @override
  _HealthDashboardState createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  HealthSummary? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    try {
      // Ensure permissions
      bool hasPerms = await HealthAPI.ensurePermissions();
      if (!hasPerms) {
        setState(() => _loading = false);
        return;
      }

      // Load today's summary
      HealthSummary summary = await HealthAPI.getTodaySummary();
      setState(() {
        _summary = summary;
        _loading = false;
      });
    } catch (e) {
      print('Error loading health data: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_summary == null) {
      return Center(child: Text('No health data available'));
    }

    return Column(
      children: [
        _buildHealthCard('Steps', '${_summary!.totalSteps}', Icons.directions_walk),
        _buildHealthCard('Distance', '${_summary!.totalDistance.toStringAsFixed(2)} km', Icons.straighten),
        _buildHealthCard('Calories', '${_summary!.totalCalories}', Icons.local_fire_department),
        _buildHealthCard('Heart Rate', '${_summary!.averageHeartRate} BPM', Icons.favorite),
        _buildHealthCard('Sleep', '${_summary!.sleepHours.toStringAsFixed(1)} hours', Icons.bedtime),
      ],
    );
  }

  Widget _buildHealthCard(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
```

## API Reference

### HealthPackage (Main Interface)

```dart
// Quick access methods
static Future<List<HealthDataModel>> getTodayData()
static Future<HealthSummary> getTodaySummary()
static Future<bool> initialize()
static Future<bool> requestPermissions()
```

### HealthAPI (Static Methods)

#### Data Retrieval
```dart
// Get data for different periods
static Future<List<HealthDataModel>> getTodayData()
static Future<List<HealthDataModel>> getWeekData()
static Future<List<HealthDataModel>> getMonthData()
static Future<List<HealthDataModel>> getCustomData(DateTime start, DateTime end)

// Get summaries
static Future<HealthSummary> getTodaySummary()
static Future<HealthSummary> getDateSummary(DateTime date)
static Future<List<HealthSummary>> getWeeklySummary()

// Get specific data types
static Future<List<HealthDataModel>> getTodaySteps()
static Future<List<HealthDataModel>> getStepsForPeriod(DateTime start, DateTime end)
static Future<List<HealthDataModel>> getTodayHeartRate()
static Future<List<HealthDataModel>> getHeartRateForPeriod(DateTime start, DateTime end)
```

#### Data Writing
```dart
static Future<bool> addSteps(int steps, {DateTime? start, DateTime? end})
static Future<bool> addWeight(double weight, {DateTime? dateTime})
static Future<bool> addHeartRate(int heartRate, {DateTime? dateTime})
```

#### Permission Management
```dart
static Future<bool> hasPermissions()
static Future<bool> requestPermissions()
static Future<bool> isHealthConnectAvailable()
static Future<bool> initialize()
static Future<bool> ensurePermissions()
```

### HealthService (Advanced Usage)

```dart
HealthService service = HealthService();

// Get data with more control
Future<List<HealthDataModel>> getData({
  DateTime? start,
  DateTime? end,
  HealthDataPeriod period = HealthDataPeriod.today,
})

// Available periods: today, thisWeek, thisMonth, custom
```

### Data Models

#### HealthDataModel
```dart
class HealthDataModel {
  final HealthDataType type;
  final double value;
  final HealthDataUnit unit;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String sourceName;
  final String platform;
  
  String get displayValue;  // Formatted value (e.g., "10,000 steps")
  String get displayName;   // Human-readable name (e.g., "Steps")
}
```

#### HealthSummary
```dart
class HealthSummary {
  final int totalSteps;
  final double totalDistance;    // in km
  final int totalCalories;
  final int averageHeartRate;
  final double sleepHours;
  final DateTime date;
}
```

## Advanced Usage Examples

### 1. Custom Data Provider

```dart
class CustomHealthProvider {
  static Future<Map<String, dynamic>> getHealthReport() async {
    // Ensure permissions
    bool hasPerms = await HealthAPI.ensurePermissions();
    if (!hasPerms) {
      throw Exception('Health permissions required');
    }

    // Get comprehensive data
    HealthSummary today = await HealthAPI.getTodaySummary();
    List<HealthSummary> week = await HealthAPI.getWeeklySummary();
    
    // Calculate weekly averages
    double avgSteps = week.isEmpty ? 0 : 
        week.map((s) => s.totalSteps).reduce((a, b) => a + b) / week.length;
    double avgDistance = week.isEmpty ? 0 : 
        week.map((s) => s.totalDistance).reduce((a, b) => a + b) / week.length;

    return {
      'today': {
        'steps': today.totalSteps,
        'distance': today.totalDistance,
        'calories': today.totalCalories,
        'heartRate': today.averageHeartRate,
        'sleep': today.sleepHours,
      },
      'weeklyAverages': {
        'steps': avgSteps.round(),
        'distance': avgDistance,
      },
      'weeklyData': week.map((s) => {
        'date': s.date.toIso8601String(),
        'steps': s.totalSteps,
        'distance': s.totalDistance,
        'calories': s.totalCalories,
      }).toList(),
    };
  }
}
```

### 2. Background Data Sync

```dart
class HealthDataSync {
  static Future<void> syncToServer() async {
    try {
      // Get today's data
      List<HealthDataModel> data = await HealthAPI.getTodayData();
      
      // Convert to API format
      List<Map<String, dynamic>> apiData = data.map((d) => {
        'type': d.type.name,
        'value': d.value,
        'unit': d.unit.name,
        'timestamp': d.dateFrom.toIso8601String(),
        'source': d.sourceName,
        'platform': d.platform,
      }).toList();
      
      // Send to your API
      await sendToAPI(apiData);
      
    } catch (e) {
      print('Sync failed: $e');
    }
  }
  
  static Future<void> sendToAPI(List<Map<String, dynamic>> data) async {
    // Your API implementation
  }
}
```

### 3. Real-time Health Monitoring

```dart
class HealthMonitor {
  static Stream<HealthSummary> watchHealthData() async* {
    while (true) {
      try {
        HealthSummary summary = await HealthAPI.getTodaySummary();
        yield summary;
      } catch (e) {
        print('Error monitoring health data: $e');
      }
      
      // Update every 5 minutes
      await Future.delayed(Duration(minutes: 5));
    }
  }
}

// Usage in widget
StreamBuilder<HealthSummary>(
  stream: HealthMonitor.watchHealthData(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text('Steps: ${snapshot.data!.totalSteps}');
    }
    return CircularProgressIndicator();
  },
)
```

## Error Handling

```dart
try {
  List<HealthDataModel> data = await HealthAPI.getTodayData();
} catch (e) {
  if (e.toString().contains('permissions')) {
    // Handle permission error
    bool granted = await HealthAPI.requestPermissions();
  } else if (e.toString().contains('Health Connect')) {
    // Handle Health Connect not available
    print('Health Connect not installed');
  } else {
    // Handle other errors
    print('Error: $e');
  }
}
```

## Best Practices

1. **Always check permissions** before accessing health data
2. **Cache data** when possible to reduce API calls
3. **Handle errors gracefully** - health data may not always be available
4. **Request minimal permissions** - only ask for data types you actually use
5. **Be mindful of privacy** - don't store sensitive health data unnecessarily
6. **Test on real devices** - health data simulators may not work perfectly

## Troubleshooting

### Android Issues
- Ensure Health Connect is installed and updated
- Check that your app's target SDK is compatible
- Verify all required permissions are declared in AndroidManifest.xml

### iOS Issues
- Ensure HealthKit is available on the device
- Check that usage descriptions are properly set in Info.plist
- Test on a real device (simulator may not have health data)

### Permission Issues
```dart
// Debug permission status
bool available = await HealthAPI.isHealthConnectAvailable();
bool hasPerms = await HealthAPI.hasPermissions();
print('Health Connect available: $available');
print('Has permissions: $hasPerms');
```

## License

This package is provided as-is for educational and development purposes. Make sure to comply with health data regulations in your jurisdiction.

## Contributing

Feel free to submit issues and enhancement requests!