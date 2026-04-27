import 'package:flutter/material.dart';
import 'create_acc4.dart';

// Unified widgets
import '../../../widgets/responsive_layout.dart';
import '../../../widgets/custom_app_bar.dart';

class CreateAccountStep3 extends StatefulWidget {
  final Map<String, dynamic> userData;
  const CreateAccountStep3({super.key, required this.userData});

  @override
  State<CreateAccountStep3> createState() => _CreateAccountStep3State();
}

class _CreateAccountStep3State extends State<CreateAccountStep3> {
  String? selectedGender = 'Male';
  String? weightUnit = 'lbs';
  String? heightUnit = 'in';

  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _rhrController = TextEditingController();
  final _conditionController = TextEditingController();

  void _onNextPressed() {
    widget.userData['weight'] = _weightController.text;
    widget.userData['sex'] = selectedGender;
    widget.userData['weight_unit'] = weightUnit;
    widget.userData['height_unit'] = heightUnit;
    widget.userData['height'] = _heightController.text;
    widget.userData['age'] = _ageController.text;
    widget.userData['RHR'] = _rhrController.text;
    widget.userData['health_conditions'] = _conditionController.text;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAccountStep4(userData: widget.userData),
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
                "Next, enter your health information. This will be crucial in helping you meet your fitness goals. This can be changed later in your profile.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 24),

              // Sex Selection
              Text("Sex*", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: [
                  Radio<String>(
                    value: 'Male',
                    groupValue: selectedGender,
                    onChanged: (val) => setState(() => selectedGender = val),
                  ),
                  const Text("Male"),
                  Radio<String>(
                    value: 'Female',
                    groupValue: selectedGender,
                    onChanged: (val) => setState(() => selectedGender = val),
                  ),
                  const Text("Female"),
                  Radio<String>(
                    value: 'Other',
                    groupValue: selectedGender,
                    onChanged: (val) => setState(() => selectedGender = val),
                  ),
                  const Text("Other"),
                ],
              ),
              SizedBox(height: 16),

              // Weight
              Text("Weight*", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        hintText: "Weight",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: 'lbs',
                            groupValue: weightUnit,
                            onChanged: (val) => setState(() => weightUnit = val),
                          ),
                          const Text("Imperial (lbs)"),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'kg',
                            groupValue: weightUnit,
                            onChanged: (val) => setState(() => weightUnit = val),
                          ),
                          const Text("Metric (kg)"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Height
              Text("Height*", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      decoration: InputDecoration(
                        hintText: "Height",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: 'in',
                            groupValue: heightUnit,
                            onChanged: (val) => setState(() => heightUnit = val),
                          ),
                          const Text("Imperial (in)"),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'cm',
                            groupValue: heightUnit,
                            onChanged: (val) => setState(() => heightUnit = val),
                          ),
                          const Text("Metric (cm)"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Age
              Text("Age*", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  hintText: "Age",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              // Resting Heart Rate
              Text("Resting Heart Rate",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              TextField(
                controller: _rhrController,
                decoration: InputDecoration(
                  hintText: "RHR",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),

              // Required note
              Text(
                "* Indicates required field",
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),

              // Add Preexisting Health Condition Button
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          "New Preexisting Health Condition",
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _conditionController,
                              decoration: InputDecoration(
                                hintText:
                                "Ex: Diabetes, Chronic Pain, Anemia, Asthma, etc.",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.deepPurple),
                              foregroundColor: Colors.black87,
                            ),
                            child: Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final entered = _conditionController.text.trim();
                              if (entered.isNotEmpty) {
                                Navigator.of(context).pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                            child: Text("Save"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "+ Add Preexisting Health Conditions",
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),

              SizedBox(height: 24),

              // Next Button
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
