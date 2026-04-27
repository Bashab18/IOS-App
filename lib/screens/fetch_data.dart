import 'package:flutter/material.dart';
import 'package:mhealthapp/health/health_package.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

Future<void> initHealth() async {
  bool initialized = await HealthPackage.initialize();
  if (!initialized) {
    bool granted = await HealthPackage.requestPermissions();
    if (!granted) {
      print("Permissions not granted");
      return;
    }
  }
}
