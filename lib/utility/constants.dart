import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);
const defaultPadding = 16.0;

// Web uses /api (Vercel proxy), Desktop uses direct server IP
const MAIN_URL = kIsWeb ? '/api' : 'http://52.70.7.244:3000';
