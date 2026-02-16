import 'package:flutter/material.dart';
const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);
const defaultPadding = 16.0;

// final String MAIN_URL = dotenv.env['MAIN_BACKEND_URL']!;
const String MAIN_URL =
    String.fromEnvironment('MAIN_BACKEND_URL', defaultValue: 'http://localhost:3000');