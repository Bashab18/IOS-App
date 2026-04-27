import 'package:flutter/material.dart';
import '../../Settings/settings_1.dart';
import '../../challenges.dart';
import '../../exercise.dart';
import '../../home_page.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/responsive_layout.dart';
import 'exercise_home.dart';

class ExerciseRoutinePage extends StatelessWidget {
  const ExerciseRoutinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;
    final textScale = screenWidth / 375;

    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ Use global app bar
      appBar: const CustomAppBar(title: "Exercise Routine"),

      // ✅ Wrap main body in ResponsiveLayout
      body: ResponsiveLayout(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenWidth * 0.04),
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black, size: screenWidth * 0.07),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(height: screenWidth * 0.02),

                Text(
                  'Exercise Routine 1',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20 * textScale,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),

                Text(
                  '*Click to personalize routine name',
                  style: TextStyle(fontSize: 12 * textScale, color: Colors.black87),
                ),
                SizedBox(height: screenWidth * 0.04),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7B0A6CA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(),
                      2: FlexColumnWidth(),
                      3: FlexColumnWidth(),
                    },
                    border: TableBorder.symmetric(
                      inside: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                    children: [
                      TableRow(
                        children: [
                          tableCellHeader('Exercise', textScale),
                          tableCellHeader('Reps', textScale),
                          tableCellHeader('Sets', textScale),
                          tableCellHeader('Weight', textScale),
                        ],
                      ),
                      tableRow('Calf Raises', '10', '3', '15', textScale),
                      tableRow('temp', 'temp', 'temp', 'temp', textScale),
                    ],
                  ),
                ),

                SizedBox(height: screenWidth * 0.03),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const ExercisePage()),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B578C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenWidth * 0.03,
                      ),
                    ),
                    child: Text(
                      'Accept',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14 * textScale,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenWidth * 0.06),

                Text(
                  'How does this routine look?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16 * textScale,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  'If you like it click accept above to add this routine to your personal exercise library.',
                  style: TextStyle(fontSize: 14 * textScale),
                ),
                SizedBox(height: screenWidth * 0.04),
                Text(
                  'Not quite right? You can generate a new routine or send us a comment to help improve your next routine.',
                  style: TextStyle(fontSize: 14 * textScale),
                ),
                SizedBox(height: screenWidth * 0.02),

                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const ExercisePage()),
                          (route) => false,
                    );
                  },
                  child: Text(
                    'Generate new routine',
                    style: TextStyle(
                      fontSize: 14 * textScale,
                      color: const Color(0xFF6B578C),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                SizedBox(height: screenWidth * 0.01),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Send a comment to our team',
                    style: TextStyle(
                      fontSize: 14 * textScale,
                      color: const Color(0xFF6B578C),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ✅ Use global bottom navigation bar
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  // Table helper methods
  Widget tableCellHeader(String text, double textScale) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14 * textScale),
      ),
    );
  }

  TableRow tableRow(String ex, String reps, String sets, String wt, double textScale) {
    return TableRow(
      children: [
        tableCellContent(ex, textScale),
        tableCellContent(reps, textScale),
        tableCellContent(sets, textScale),
        tableCellContent(wt, textScale),
      ],
    );
  }

  Widget tableCellContent(String text, double textScale) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(text, style: TextStyle(fontSize: 14 * textScale)),
    );
  }
}
