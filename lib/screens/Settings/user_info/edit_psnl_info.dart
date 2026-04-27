// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mhealthapp/db_helper.dart';

import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/responsive_layout.dart';

class EditPersonalInfoPage extends StatefulWidget {
  const EditPersonalInfoPage({super.key});

  @override
  _EditPersonalInfoPageState createState() => _EditPersonalInfoPageState();
}

class _EditPersonalInfoPageState extends State<EditPersonalInfoPage> {
  int? userId;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadUserIdAndData();
  }

  Future<void> loadUserIdAndData() async {
    final prefs = await SharedPreferences.getInstance();
    final int? id = prefs.getInt('userId');
    final dbHelper = DBHelper();

    if (id == null) {
      print('No userId found in SharedPreferences');
      return;
    }

    final Map<String, dynamic>? data = await dbHelper.getUserById(id);
    if (data != null) {
      setState(() {
        userId = data['id'];
        userData = data;
      });
    } else {
      print('User not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "mHealth"),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),

      body: ResponsiveLayout(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Divider(height: 32),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EditableTextRow(
                    label: 'First Name',
                    initialValue: userData?["first_name"] ?? '',
                  ),
                  EditableTextRow(
                    label: 'Last Name',
                    initialValue: userData?["last_name"] ?? '',
                  ),
                  EditableTextRow(
                    label: 'Date of Birth',
                    initialValue: userData?["dob"] ?? '',
                  ),
                  EditableTextRow(
                    label: 'Email',
                    initialValue: userData?["email"] ?? '',
                  ),
                  EditableTextRow(
                    label: 'Phone Number',
                    initialValue: userData?["phone_number"] ?? '',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditableTextRow extends StatefulWidget {
  final String label;
  final String initialValue;

  const EditableTextRow({
  required this.label,
  required this.initialValue,
  super.key,
});

@override
State<EditableTextRow> createState() => _EditableTextRowState();
}

class _EditableTextRowState extends State<EditableTextRow> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  Future<void> _saveToDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;

    final dbHelper = DBHelper();

    final Map<String, String> labelToFieldMap = {
      'First Name': 'first_name',
      'Last Name': 'last_name',
      'Date of Birth': 'dob',
      'Email': 'email',
      'Phone Number': 'phone_number',
    };

    final fieldName = labelToFieldMap[widget.label];
    final fieldValue = _controller.text;

    if (fieldName != null) {
      await dbHelper.updateUser(userId, {fieldName: fieldValue});
      print('Updated $fieldName to $fieldValue');
      await printUserInfo(userId);
    }
  }

  Future<void> printUserInfo(int userId) async {
    final dbHelper = DBHelper();
    final userInfo = await dbHelper.getUserById(userId);

    if (userInfo != null) {
      print('User Info:');
      userInfo.forEach((key, value) {
        print('key: $key → value: $value → type: ${value.runtimeType}');
      });
    } else {
      print('No user found with id: $userId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _isEditing
                ? TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: widget.label),
              onSubmitted: (_) async {
                setState(() => _isEditing = false);
                await _saveToDatabase();
              },
            )
                : Text(
              '${widget.label}\n${_controller.text}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() => _isEditing = !_isEditing);
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 4.0),
              child: Text('Edit', style: TextStyle(color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
