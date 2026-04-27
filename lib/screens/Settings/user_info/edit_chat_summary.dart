import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mhealthapp/db_helper.dart';
import 'dart:convert';

import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/responsive_layout.dart';

class ConversationSummaryPage extends StatefulWidget {
  const ConversationSummaryPage({super.key});

  @override
  State<ConversationSummaryPage> createState() =>
      _ConversationSummaryPageState();
}

class _ConversationSummaryPageState extends State<ConversationSummaryPage> {
  int? userId;
  Map<String, dynamic>? userData;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController conditionsController = TextEditingController();
  final TextEditingController exerciseController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController chatbotSummaryController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserIdAndData();
  }

  Future<void> loadUserIdAndData() async {
    final prefs = await SharedPreferences.getInstance();
    final int? id = prefs.getInt('userId');
    final dbHelper = DBHelper();

    if (id == null) return;

    final Map<String, dynamic>? data = await dbHelper.getUserById(id);
    if (data != null) {
      setState(() {
        userId = data['user_dim_id'];
        userData = data;

        nameController.text =
            "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}".trim();
        ageController.text = (data['age'] ?? '').toString();
        goalController.text = parseGoals(data['custom_goals']);
        conditionsController.text = data['health_conditions'] ?? '';
        exerciseController.text = data['preferred_exercise'] ?? '';
        notesController.text = data['notes'] ?? '';
        chatbotSummaryController.text = data['chatbot_summary'] ?? '';
      });
    }
  }

  String parseGoals(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return '';
    try {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      final trueKeys = decoded.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();
      return trueKeys.join(", ");
    } catch (_) {
      return '';
    }
  }

  Future<void> saveChanges() async {
    if (userId == null) return;
    final dbHelper = DBHelper();

    final values = {
      "first_name": nameController.text.split(" ").first,
      "last_name": nameController.text.split(" ").length > 1
          ? nameController.text.split(" ").sublist(1).join(" ")
          : "",
      "age": int.tryParse(ageController.text) ?? 0,
      "custom_goals": json.encode({
        for (var g in goalController.text.split(",").map((s) => s.trim()))
          if (g.isNotEmpty) g: true,
      }),
      "health_conditions": conditionsController.text,
      "chatbot_summary": chatbotSummaryController.text,
    };

    await dbHelper.updateUser(userId!, values);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Changes saved!")));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;
    final textScale = screenWidth / 375;

    return Scaffold(
      backgroundColor: Colors.white,

      /// ✔ Unified AppBar
      appBar: const CustomAppBar(title: "mHealth"),

      /// ✔ Keep Bottom Nav as required
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),

      /// ✔ Wrap in ResponsiveLayout
      body: ResponsiveLayout(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenWidth * 0.04),
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: screenWidth * 0.07,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(height: screenWidth * 0.02),

                Text(
                  'Conversation Summary',
                  style: TextStyle(
                    fontSize: 20 * textScale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(height: 32),

                _editableField("Name", nameController, textScale),
                _editableField("Age", ageController, textScale),
                _editableField("Health Goal", goalController, textScale),
                _editableField("Known Conditions", conditionsController, textScale),
                _editableField("Preferred Exercise", exerciseController, textScale),

                SizedBox(height: screenWidth * 0.04),
                Text(
                  'Chatbot Summary:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16 * textScale,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                TextField(
                  controller: chatbotSummaryController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF6B578C)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF6B578C)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),

                SizedBox(height: screenWidth * 0.04),
                Text(
                  'Additional Notes:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16 * textScale,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                TextField(
                  controller: notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Add any personal notes...",
                    hintStyle: const TextStyle(
                      color: Color(0xFF6B578C),
                      fontWeight: FontWeight.w500,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF6B578C)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF6B578C)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),

                SizedBox(height: screenWidth * 0.06),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B578C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _editableField(
      String label, TextEditingController controller, double textScale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14 * textScale,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF6B578C)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF6B578C)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    goalController.dispose();
    conditionsController.dispose();
    exerciseController.dispose();
    notesController.dispose();
    chatbotSummaryController.dispose();
    super.dispose();
  }
}
