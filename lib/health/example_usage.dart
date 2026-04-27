// Example usage of Health Package

import 'health_package.dart';

class HealthDataExample {
  // Example 1: Simple usage with the main package interface
  static Future<void> simpleUsage() async {
    // Initialize the health package
    bool initialized = await HealthPackage.initialize();
    if (!initialized) {
      print('Health Connect not available or no permissions');
      return;
    }

    // Get today's data
    List<HealthDataModel> todayData = await HealthPackage.getTodayData();
    print('Today\'s health data points: ${todayData.length}');

    // Get today's summary
    HealthSummary summary = await HealthPackage.getTodaySummary();
    print('Steps today: ${summary.totalSteps}');
    print('Distance today: ${summary.totalDistance.toStringAsFixed(2)} km');
  }

  // Example 2: Using the API layer directly
  static Future<void> apiUsage() async {
    // Check and request permissions
    bool hasPerms = await HealthAPI.hasPermissions();
    if (!hasPerms) {
      hasPerms = await HealthAPI.requestPermissions();
      if (!hasPerms) {
        print('Failed to get permissions');
        return;
      }
    }

    // Get specific data types
    List<HealthDataModel> steps = await HealthAPI.getTodaySteps();
    List<HealthDataModel> heartRate = await HealthAPI.getTodayHeartRate();

    print('Steps data points: ${steps.length}');
    print('Heart rate data points: ${heartRate.length}');

    // Get weekly summary
    List<HealthSummary> weeklySummary = await HealthAPI.getWeeklySummary();
    print('Weekly data available for ${weeklySummary.length} days');

    // Write new data
    bool success = await HealthAPI.addSteps(5000);
    print('Steps added successfully: $success');
  }

  // Example 3: Using the service layer for more control
  static Future<void> serviceUsage() async {
    HealthService service = HealthService();

    // Get custom period data
    DateTime start = DateTime.now().subtract(Duration(days: 7));
    DateTime end = DateTime.now();

    List<HealthDataModel> weekData = await service.getData(
      period: HealthDataPeriod.custom,
      start: start,
      end: end,
    );

    print('Week data: ${weekData.length} points');

    // Get specific data types with custom periods
    List<HealthDataModel> stepsLastWeek = await service.getSteps(
      period: HealthDataPeriod.custom,
      start: start,
      end: end,
    );

    print('Steps last week: ${stepsLastWeek.length} data points');
  }

  // Example 4: In a Flutter widget
  // static Future<Widget> buildHealthWidget() async {
  //   try {
  //     // Get today's summary
  //     HealthSummary summary = await HealthAPI.getTodaySummary();

  //     return Column(
  //       children: [
  //         Text('Steps: ${summary.totalSteps}'),
  //         Text('Distance: ${summary.totalDistance.toStringAsFixed(2)} km'),
  //         Text('Calories: ${summary.totalCalories}'),
  //         Text('Avg Heart Rate: ${summary.averageHeartRate} BPM'),
  //       ],
  //     );
  //   } catch (e) {
  //     return Text('Error loading health data: $e');
  //   }
  // }

  // Example 5: Background data fetching
  static Future<Map<String, dynamic>> getHealthDataForAPI() async {
    try {
      // Ensure permissions
      bool hasPerms = await HealthAPI.ensurePermissions();
      if (!hasPerms) {
        return {'error': 'No permissions'};
      }

      // Get comprehensive data
      List<HealthDataModel> todayData = await HealthAPI.getTodayData();
      HealthSummary summary = await HealthAPI.getTodaySummary();
      List<HealthSummary> weekSummary = await HealthAPI.getWeeklySummary();

      return {
        'today': {
          'raw_data':
              todayData
                  .map(
                    (d) => {
                      'type': d.type.name,
                      'value': d.value,
                      'unit': d.unit.name,
                      'timestamp': d.dateFrom.toIso8601String(),
                    },
                  )
                  .toList(),
          'summary': {
            'steps': summary.totalSteps,
            'distance_km': summary.totalDistance,
            'calories': summary.totalCalories,
            'avg_heart_rate': summary.averageHeartRate,
            'sleep_hours': summary.sleepHours,
          },
        },
        'week':
            weekSummary
                .map(
                  (s) => {
                    'date': s.date.toIso8601String(),
                    'steps': s.totalSteps,
                    'distance_km': s.totalDistance,
                    'calories': s.totalCalories,
                  },
                )
                .toList(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}

// Example of a simple health data provider class
class HealthDataProvider {
  static Future<List<HealthDataModel>> fetchSteps([DateTime? date]) async {
    if (date != null) {
      return await HealthAPI.getStepsForPeriod(
        DateTime(date.year, date.month, date.day),
        DateTime(date.year, date.month, date.day, 23, 59, 59),
      );
    }
    return await HealthAPI.getTodaySteps();
  }

  static Future<int> getTotalStepsToday() async {
    List<HealthDataModel> steps = await fetchSteps();
    return steps.fold<int>(0, (sum, step) => sum + step.value.toInt());
  }

  static Future<bool> addStepsEntry(int steps) async {
    return await HealthAPI.addSteps(steps);
  }
}
