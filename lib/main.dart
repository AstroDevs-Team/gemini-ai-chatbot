import 'package:flutter/material.dart';
import 'package:gemini_chat_bot/chat_screen.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Gemini AI ChatBot',
      home:  ChatScreen(),
    );
  }
}
