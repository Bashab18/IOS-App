// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:mhealthapp/screens/ActivityStats/activity_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mhealthapp/db_helper.dart';

import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/responsive_layout.dart';
import '../../exercise.dart';

class HealthInfo extends StatefulWidget {
  const HealthInfo({super.key});

  @override
  _HealthInfostate createState() => _HealthInfostate();
}

class _HealthInfostate extends State<HealthInfo> {
  int? userId;
  Map<String, dynamic>? userData;
  String? weightUnit;

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
        weightUnit = data['weight_unit'] ?? 'kg';
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

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "mHealth"),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),

      /// ✅ WRAPPED with ResponsiveLayout (only structural update)
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
                'Health Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Divider(height: 32),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EditableNumberWithUnitRow(
                    label: 'Weight',
                    fieldName: 'weight',
                    unitFieldName: 'weight_unit',
                    initialValue: userData?["weight"]?.toString() ?? "",
                    initialUnit: userData?["weight_unit"] ?? "kg",
                    units: const ["kg", "lbs"],
                  ),
                  EditableNumberWithUnitRow(
                    label: 'Height',
                    fieldName: 'height',
                    unitFieldName: 'height_unit',
                    initialValue: userData?["height"]?.toString() ?? "",
                    initialUnit: userData?["height_unit"] ?? "cm",
                    units: const ["cm", "inch"],
                  ),
                  EditableTextRow(
                    label: 'Age',
                    initialValue: userData?["age"].toString() ?? '',
                  ),
                  EditableTextRow(
                    label: 'Preexisting Health Conditions',
                    initialValue: userData?["health_conditions"] ?? '',
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
      'Weight': 'weight',
      'Height': 'height',
      'Age': 'age',
      'Preexisting Health Conditions': "health_conditions",
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

class EditableNumberWithUnitRow extends StatefulWidget {
  final String label;
  final String fieldName;
  final String unitFieldName;
  final String initialValue;
  final String initialUnit;
  final List<String> units;

  const EditableNumberWithUnitRow({
  super.key,
  required this.label,
  required this.fieldName,
  required this.unitFieldName,
  required this.initialValue,
  required this.initialUnit,
  required this.units,
  });

  @override
  State<EditableNumberWithUnitRow> createState() =>
      _EditableNumberWithUnitRowState();
}

class _EditableNumberWithUnitRowState
    extends State<EditableNumberWithUnitRow> {
  late TextEditingController _controller;
  late String _selectedUnit;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _selectedUnit =
    widget.initialUnit.isNotEmpty ? widget.initialUnit : widget.units.first;
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _saveToDatabase();
      }
    });
  }

  Future<void> _saveToDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;

    final dbHelper = DBHelper();
    final double numericValue = double.tryParse(_controller.text) ?? 0.0;

    await dbHelper.updateUser(userId, {
      widget.fieldName: numericValue,
      widget.unitFieldName: _selectedUnit,
    });

    print("Saved ${widget.label}: $numericValue $_selectedUnit");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  onEditingComplete: () async {
                    FocusScope.of(context).unfocus();
                    await _saveToDatabase();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: widget.units.map((unit) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: unit,
                        groupValue: _selectedUnit,
                        onChanged: (value) async {
                          setState(() => _selectedUnit = value!);
                          await _saveToDatabase();
                        },
                      ),
                      Text(unit),
                    ],
                  );
                }).toList(),
              ),
            ],
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

AppBar appBar() {
  return AppBar(
    centerTitle: true,
    backgroundColor: Colors.white,
    elevation: 0.0,
    automaticallyImplyLeading: false,
    title: const Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Text(
        'mHealth',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
    ),
  );
}
