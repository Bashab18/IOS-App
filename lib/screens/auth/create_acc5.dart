import 'package:flutter/material.dart';
import 'create_acc6.dart';
import 'package:mhealthapp/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Unified widgets
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/custom_app_bar.dart';

class CreateAccountStep5 extends StatefulWidget {
  final Map<String, dynamic> userData;
  const CreateAccountStep5({super.key, required this.userData});

  @override
  State<CreateAccountStep5> createState() => _CreateAccountStep5State();
}

class _CreateAccountStep5State extends State<CreateAccountStep5> {
  String? selectedPersonality;
  String? selectedVoice;
  int selectedAvatar = -1;

  final TextEditingController _customGoalController = TextEditingController();

  void _showPersonalityInfo(String title, List<String> points) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title, style: TextStyle(color: Colors.deepPurple)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: points
              .map((p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text("• $p", style: TextStyle(color: Colors.deepPurple)),
          ))
              .toList(),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => selectedPersonality = title);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: Text("Select", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityOption(String label, List<String> traits) {
    final isSelected = selectedPersonality == label;

    return GestureDetector(
      onTap: () => _showPersonalityInfo(label, traits),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
        ),
        child: Text(label, style: TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildVoiceOption(String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: label,
      groupValue: selectedVoice,
      activeColor: Colors.deepPurple,
      onChanged: (value) => setState(() => selectedVoice = value),
    );
  }

  void printUserInfo(int userId) async {
    final dbHelper = DBHelper();
    final userInfo = await dbHelper.getUserById(userId);

    if (userInfo != null) {
      print('User Info:');
      userInfo.forEach((key, value) {
        print('key: $key → value: $value → type: ${value.runtimeType}');
      });
    }
  }

  void _onNextPressed() async {
    widget.userData['ai_avatar_id'] = selectedAvatar.toString();
    widget.userData['ai_personality'] = selectedPersonality;
    widget.userData['ai_voice'] = selectedVoice;

    final userId = await DBHelper().insertUser(widget.userData);
    if (userId == null) {
      print('Error inserting user data');
      return;
    }

    widget.userData['id'] = userId.toString();
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt('userId', userId);
    prefs.setString('username', widget.userData['username']);
    prefs.setString('email', widget.userData['email']);

    printUserInfo(userId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAccountStep6(userData: widget.userData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      backgroundColor: Colors.white,

      body: ResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24.0),

          child: ListView(
            children: [
              Text(
                "Create an Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),

              Text(
                "Finally, customize the settings of your AI agent! Select an avatar, choose a voice, and shape their personality.",
                style: TextStyle(fontSize: 14),
              ),

              SizedBox(height: 28),

              //-------------------------------------------------------
              //                AVATAR SELECTION
              //-------------------------------------------------------
              Text("Appearance", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 9,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (_, index) {
                  final isSelected = selectedAvatar == index;

                  return GestureDetector(
                    onTap: () => setState(() => selectedAvatar = index),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.deepPurple : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'images/avatar${index + 1}.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 32),

              //-------------------------------------------------------
              //                PERSONALITY SELECTION
              //-------------------------------------------------------
              Text("Personality", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildPersonalityOption("Empathetic", [
                    "Gentle and understanding",
                    "Supportive when you're tired",
                    "Focuses on encouragement"
                  ]),
                  _buildPersonalityOption("Direct", [
                    "Straightforward and firm",
                    "Very analytical and goal-driven",
                    "Pushes you without sugarcoating"
                  ]),
                  _buildPersonalityOption("Balanced", [
                    "Friendly and reasonable",
                    "Equal focus on mental + physical health",
                    "Supportive but not too pushy"
                  ]),
                  _buildPersonalityOption("Mentally Focused", [
                    "Focuses on mental toughness",
                    "Builds discipline and grit",
                    "Pushes you mentally more than physically"
                  ]),
                ],
              ),

              SizedBox(height: 32),

              //-------------------------------------------------------
              //                VOICE SELECTION
              //-------------------------------------------------------
              Text("Voice", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),

              _buildVoiceOption("Voice 1"),
              _buildVoiceOption("Voice 2"),
              _buildVoiceOption("Voice 3"),
              _buildVoiceOption("Voice 4"),

              SizedBox(height: 32),

              //-------------------------------------------------------
              //                NEXT BUTTON
              //-------------------------------------------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
