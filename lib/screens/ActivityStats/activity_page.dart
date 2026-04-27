import 'package:flutter/material.dart';

import '../Settings/settings_1.dart';
import '../challenges.dart';
import '../exercise.dart';
import '../home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mhealthapp/db_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mhealthapp/health/health_package.dart';
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/bottom_nav_bar.dart';

DateTime _mondayOf(DateTime d) => d.subtract(Duration(days: d.weekday - 1));

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  List<Map<String, String>> _logs = [];
  bool _loading = true;
  String? _error;
  int? _userId;
  bool _inserting = false;
  ActivityStats? _stats;
  bool _statsLoading = true;
  bool _seedingDaily = false;
  int _chartsEpoch = 0;

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userId = prefs.getInt('userId'));
  }

  Future<void> _loadWorkoutLogs() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId == null) {
        setState(() {
          _loading = false;
          _error = 'No userId found — create/select a user first.';
        });
        return;
      }

      final rows = await DBHelper().getWorkoutLogs(userId);

      final mapped = rows.map<Map<String, String>>((r) {
        return {
          'exercise': (r['workout_name'] ?? '').toString(),
          'date': (r['workout_date'] ?? '').toString(),
          'time': (r['duration_min'] ?? '').toString(),
          'cal': (r['calories_burned'] ?? '').toString(),
        };
      }).toList();

      setState(() {
        _logs = mapped;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to load workout logs: $e';
      });
    }
  }

  Future<void> _insertMockDataAndRefresh() async {
    if (_inserting) return;
    setState(() => _inserting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              ' No userId found. Please create or select a user first.',
            ),
          ),
        );
        return;
      }

      final dbHelper = DBHelper();
      await dbHelper.insertMockWorkoutSessions(userId);

      await _loadWorkoutLogs();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mock workout sessions inserted successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Insert failed: $e')));
    } finally {
      if (mounted) setState(() => _inserting = false);
    }
  }

  Future<void> _loadStats() async {
    setState(() => _statsLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _statsLoading = false;
        _stats = null;
      });
      return;
    }
    final now = DateTime.now();
    final s = await DBHelper().getDailyStats(userId: userId, day: now);
    if (!mounted) return;
    setState(() {
      _stats = s;
      _statsLoading = false;
    });
  }

  Future<void> _insertMockDailyAndRefresh() async {
    if (_seedingDaily) return;
    setState(() => _seedingDaily = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No user selected.')));
        return;
      }

      await DBHelper().insertMockDailyData(userId);

      await _loadStats();

      await DBHelper().printTable("daily_activity_fact");

      if (!mounted) return;
      setState(() => _chartsEpoch++);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserted 2 weeks of mock daily data.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Insert failed: $e')));
    } finally {
      if (mounted) setState(() => _seedingDaily = false);
    }
  }

  Future<void> syncTodayAndYesterdayToSQLite() async {
    print("syncTodayAndYesterdayToSQLite started");
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    final dbHelper = DBHelper();

    if (userId == null) {
      print("No userId in SharedPreferences; aborting sync.");
      return;
    }

    final todaySummary = await HealthAPI.getTodaySummary();
    final yesterdaySummary = await HealthAPI.getYesterdaySummary();
    print("Fetched today and yesterday summaries.");

    final todayworkouts = await HealthRepository().getTodayworkout();
    final yesterdayworkouts = await HealthRepository().getYesterdayworkout();

    await dbHelper.insert(
      'daily_activity_fact',
      todaySummary.toMap(userId: userId),
    );

    await dbHelper.insert(
      'daily_activity_fact',
      yesterdaySummary.toMap(userId: userId),
    );

    for (var session in todayworkouts) {
      await dbHelper.insert(
        'workout_session_fact',
        session.toMap(userId: userId),
      );
    }

    for (var session in yesterdayworkouts) {
      await dbHelper.insert(
        'workout_session_fact',
        session.toMap(userId: userId),
      );
    }

    await _loadWorkoutLogs();
    await _loadStats();
    print("Health data synced at ${DateTime.now()}");
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadWorkoutLogs();
    _loadStats();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Always go to HomePage instead of quitting or going to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        return false; // Prevent default pop (which would quit the app)
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: "Activity"),
        bottomNavigationBar: const BottomNavBar(currentIndex: 3),
        body: ResponsiveLayout(
          child: _selectedTab == 0
              ? _buildExerciseLog()
              : _buildStats(),
        ),
      ),
    );
  }

  double _progress(double value, double goal) {
    if (goal <= 0) return 0;
    return (value / goal).clamp(0.0, 1.0);
  }

  Widget _buildGoalRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple.shade200),
        borderRadius: BorderRadius.circular(10),
        color: Colors.deepPurple.shade50,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  double _todayExerciseMinutes() {
    final now = DateTime.now();
    double total = 0;

    for (final log in _logs) {
      final rawDate = log['date'] ?? '';
      final parsedDate = _parseLogDate(rawDate);
      if (parsedDate == null) continue;
      if (!_isSameDay(parsedDate, now)) continue;

      total += double.tryParse(log['time'] ?? '0') ?? 0;
    }

    return total;
  }

  List<MapEntry<String, double>> _weeklyExerciseBreakdown() {
    final weekStart = _mondayOf(DateTime.now());
    final weekEnd = weekStart.add(const Duration(days: 7));

    final Map<String, double> totals = {};

    for (final log in _logs) {
      final rawDate = log['date'] ?? '';
      final parsedDate = _parseLogDate(rawDate);
      if (parsedDate == null) continue;

      if (parsedDate.isBefore(weekStart) || !parsedDate.isBefore(weekEnd)) {
        continue;
      }

      final name = (log['exercise']?.trim().isNotEmpty ?? false)
          ? log['exercise']!.trim()
          : 'Workout';

      final mins = double.tryParse(log['time'] ?? '0') ?? 0;
      totals[name] = (totals[name] ?? 0) + mins;
    }

    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries;
  }

  DateTime? _parseLogDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final direct = DateTime.tryParse(value);
    if (direct != null) return direct;

    final firstPart = value.split(' ').first;
    return DateTime.tryParse(firstPart);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatMinutes(double mins) {
    final total = mins.round();
    final hours = total ~/ 60;
    final minutes = total % 60;

    if (hours == 0) return "${minutes}m";
    return "${hours}h ${minutes}m";
  }

  Widget _buildExerciseLog() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadWorkoutLogs,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final query = _searchQuery.trim().toLowerCase();
    final filteredLogs =
    _logs.where((log) {
      final name = (log['exercise'] ?? '').toLowerCase();
      return name.contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(8),
              fillColor: Colors.deepPurple.shade100,
              selectedColor: Colors.deepPurple,
              isSelected: [_selectedTab == 0, _selectedTab == 1],
              onPressed: (i) => setState(() => _selectedTab = i),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Exercise Log"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Activity Statistics"),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search exercises...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(8),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ElevatedButton.icon(
            icon: _inserting
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.library_add),
            label: Text(_inserting ? 'Inserting...' : 'Insert Mock Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(44),
            ),
            onPressed: _inserting ? null : _insertMockDataAndRefresh,
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ElevatedButton.icon(
            onPressed: () => syncTodayAndYesterdayToSQLite(),
            icon: const Icon(Icons.sync),
            label: const Text('Sync Today & Yesterday from Health API'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(44),
            ),
          ),
        ),

        Container(
          color: Colors.deepPurple.shade50,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: const [
              Expanded(flex: 3, child: Text("Exercise", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Time", style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text("Kilocalories", style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: ListView.separated(
            itemCount: filteredLogs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = filteredLogs[index];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(log["exercise"]!)),
                    Expanded(flex: 3, child: Text(log["date"]!)),
                    Expanded(flex: 2, child: Text("${log["time"]} min")),
                    Expanded(flex: 2, child: Text("${log["cal"]} kcal")),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  Widget _buildActivityBalance() {
    final active = _stats?.activeHours ?? 0;
    final sedentary = _stats?.sedentaryHours ?? 0;

    final total = active + sedentary;

    final activeFlex = total == 0 ? 50 : (active / total * 100).round().clamp(1, 99);
    final sedentaryFlex = total == 0 ? 50 : (sedentary / total * 100).round().clamp(1, 99);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Activity Balance",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              Expanded(
                flex: sedentaryFlex,
                child: Container(
                  height: 16,
                  color: Colors.grey.shade300,
                ),
              ),
              Expanded(
                flex: activeFlex,
                child: Container(
                  height: 16,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Sedentary ${sedentary.toStringAsFixed(1)}h"),
            Text("Active ${active.toStringAsFixed(1)}h"),
          ],
        ),
      ],
    );
  }

  Widget _buildStats() {
    final steps = (_stats?.steps ?? 0).toDouble();
    final calories = (_stats?.calories ?? 0).toDouble();
    final avgBpm = (_stats?.avgBpm ?? 0).toDouble();
    final maxBpm = (_stats?.maxBpm ?? 0).toDouble();
    final sleepHours = _stats?.sleepHours ?? 0.0;
    final exerciseMinutes = (_stats?.exerciseMinutes ?? 0).toDouble();
    final sleepDeepMinutes = _stats?.sleepDeepMinutes ?? 0;
    final sleepLightMinutes = _stats?.sleepLightMinutes ?? 0;
    final sleepRemMinutes = _stats?.sleepRemMinutes ?? 0;

    const double stepGoal = 10000;
    const double calorieGoal = 2000;
    const double sleepGoal = 8;

    final weeklyBreakdown = _weeklyExerciseBreakdown();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              fillColor: Colors.deepPurple.shade100,
              selectedColor: Colors.deepPurple,
              isSelected: [_selectedTab == 0, _selectedTab == 1],
              onPressed: (i) => setState(() => _selectedTab = i),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Exercise Log"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Activity Statistics"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ElevatedButton.icon(
              onPressed: _seedingDaily ? null : _insertMockDailyAndRefresh,
              icon: _seedingDaily
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.library_add),
              label: Text(
                _seedingDaily
                    ? 'Seeding daily data...'
                    : 'Insert Mock Daily Data',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ElevatedButton.icon(
              onPressed: () => syncTodayAndYesterdayToSQLite(),
              icon: const Icon(Icons.sync),
              label: const Text('Sync Today & Yesterday from Health API'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (_userId != null) ...[
            SizedBox(
              height: 350,
              child: WeeklyChartsPager(
                key: ValueKey(_chartsEpoch),
                userId: _userId!,
              ),
            ),
            const SizedBox(height: 20),
          ] else ...[
            const SizedBox(
              height: 350,
              child: Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 20),
          ],

          const Text(
            "Daily Activity",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.deepPurple.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TripleRingProgress(
                      size: 118,
                      values: [
                        _progress(steps, stepGoal),
                        _progress(calories, calorieGoal),
                        _progress(sleepHours, sleepGoal),
                      ],
                      colors: [
                        Colors.deepPurple,
                        Colors.deepPurple.shade300,
                        Colors.deepPurple.shade100,
                      ],
                      centerChild: const Text(
                        "Today",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _buildGoalRow(
                            "Steps",
                            "${steps.toInt()}/${stepGoal.toInt()}",
                          ),
                          const SizedBox(height: 10),
                          _buildGoalRow(
                            "Calories",
                            "${calories.toInt()}/${calorieGoal.toInt()}",
                          ),
                          const SizedBox(height: 10),
                          _buildGoalRow(
                            "Sleep",
                            "${sleepHours.toStringAsFixed(1)}/${sleepGoal.toInt()} hrs",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MetricTile(
                      icon: Icons.favorite,
                      label: _stats != null ? "${_stats!.avgBpm} bpm" : "–",
                    ),

                    _MetricTile(
                      icon: Icons.bedtime,
                      label: _stats != null
                          ? "${_stats!.sleepHours.toStringAsFixed(1)} hrs"
                          : "–",
                    ),
                  ],
                ),
                const SizedBox(height: 18),



                Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(
                        value: avgBpm.toInt().toString(),
                        label: "average bpm",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatBox(
                        value: maxBpm.toInt().toString(),
                        label: "max bpm",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatBox(
                        value: exerciseMinutes.toInt().toString(),
                        label: "exercise mins",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),



          const SizedBox(height: 20),

          _buildActivityBalance(),

          const SizedBox(height: 22),

          const Text(
            "Weekly Activity",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.deepPurple.shade100),
            ),
            child: weeklyBreakdown.isEmpty
                ? const Text("No workout data for this week yet.")
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weeklyBreakdown.length.toString(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: weeklyBreakdown.take(4).map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 54,
                              child: Text(
                                _formatMinutes(entry.value),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _showStandPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('What is "Stand"?'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Standing helps break up long periods of sitting and keeps your body active throughout the day. '
                      'This feature tracks how often you stand and move around, encouraging you to get up at least once every hour.\n',
                ),
                Text('Goal:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Stand and move for at least 1 minute each hour, across several hours of your day.\n',
                ),
                Text(
                  'Regular standing can help improve circulation, posture, and overall well-being!',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActivityCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}

// OTHER CLASSES UNCHANGED
class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetricTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 28),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}

class TripleRingProgress extends StatelessWidget {
  final double size;
  final List<double> values;
  final List<Color> colors;
  final Widget? centerChild;

  const TripleRingProgress({
  super.key,
  required this.size,
  required this.values,
  required this.colors,
  this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: values[2],
              strokeWidth: 14,
              backgroundColor: Colors.deepPurple.shade50,
              valueColor: AlwaysStoppedAnimation(colors[2]),
            ),
          ),
          SizedBox(
            width: size - 24,
            height: size - 24,
            child: CircularProgressIndicator(
              value: values[1],
              strokeWidth: 14,
              backgroundColor: Colors.deepPurple.shade50,
              valueColor: AlwaysStoppedAnimation(colors[1]),
            ),
          ),
          SizedBox(
            width: size - 48,
            height: size - 48,
            child: CircularProgressIndicator(
              value: values[0],
              strokeWidth: 14,
              backgroundColor: Colors.deepPurple.shade50,
              valueColor: AlwaysStoppedAnimation(colors[0]),
            ),
          ),
          Container(
            width: size - 78,
            height: size - 78,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: centerChild,
          ),
        ],
      ),
    );
  }
}

class WeeklyLineChart extends StatelessWidget {
  final List<DailyPoint> data;
  final String title;
  const WeeklyLineChart({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    final spots = List<FlSpot>.generate(
      7,
          (i) => FlSpot(i.toDouble(), data[i].value),
    );

    String dayLabel(int i) =>
        const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i.clamp(0, 6)];

    final maxVal = data.fold<double>(0, (m, e) => e.value > m ? e.value : m);
    final yMax = (maxVal * 1.2).clamp(1, double.infinity).toDouble();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: yMax,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: yMax / 4,
                ),
                borderData: FlBorderData(show: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (v, meta) => Text(
                        v.round().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (x, meta) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          dayLabel(x.round()),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 6,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyChartsPager extends StatefulWidget {
  final int userId;
  const WeeklyChartsPager({super.key, required this.userId});

  @override
  State<WeeklyChartsPager> createState() => _WeeklyChartsPagerState();
}

class _WeeklyChartsPagerState extends State<WeeklyChartsPager> {
  final _pageCtrl = PageController(initialPage: 0);
  int _page = 0;
  Metric _metric = Metric.steps;

  DateTime _weekStartForPage(int page) {
    final thisMonday = _mondayOf(DateTime.now());
    return thisMonday.subtract(Duration(days: 7 * page));
  }

  String _weekLabel(DateTime start) {
    final end = start.add(const Duration(days: 6));
    String fmt(DateTime d) => '${d.month}/${d.day}';
    return '< ${fmt(start)} - ${fmt(end)} >';
  }

  void _goOlder() {
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _goNewer() {
    if (_page == 0) return;
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<Metric>(
              value: _metric,
              items: const [
                DropdownMenuItem(value: Metric.steps, child: Text('Steps')),
                DropdownMenuItem(value: Metric.calories, child: Text('Calories')),
              ],
              onChanged: (m) => setState(() => _metric = m!),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _goOlder,
                  tooltip: 'Previous week (older)',
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _page == 0 ? null : _goNewer,
                  tooltip: 'Next week (newer)',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (p) => setState(() => _page = p),
            itemBuilder: (context, page) {
              final weekStart = _weekStartForPage(page);
              return Column(
                children: [
                  Text(
                    _weekLabel(weekStart),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: FutureBuilder<List<DailyPoint>>(
                      future: DBHelper().getWeekActivity(
                        userId: widget.userId,
                        weekStart: weekStart,
                        metric: _metric,
                      ),
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snap.hasError) {
                          return Center(child: Text('Error: ${snap.error}'));
                        }
                        final data = snap.data ?? const <DailyPoint>[];
                        return WeeklyLineChart(
                          data: data,
                          title: _metric == Metric.steps
                              ? 'Steps / Day'
                              : 'Calories / Day',
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
