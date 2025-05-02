import 'package:allen/feature_box.dart';
import 'package:allen/openai_service.dart';
import 'package:allen/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  final TextEditingController promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Widget _getDisplayWidget() {
    if (lastWords.isEmpty) {
      return const Center(
        child: Text(
          "Gemini response will appear here...",
          style: TextStyle(
            fontSize: 15,
            color: Colors.black54,
            fontFamily: 'Cera Pro',
          ),
        ),
      );
    } else if (lastWords.startsWith('❌ Error') ||
        lastWords.startsWith('🚨 Exception')) {
      return Text(
        lastWords,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.red,
          fontFamily: 'Cera Pro',
        ),
      );
    } else if (lastWords.startsWith('⚠️')) {
      return Text(
        lastWords,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.orange,
          fontFamily: 'Cera Pro',
        ),
      );
    } else if (lastWords == "Please wait, generating response...") {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.black,),
            SizedBox(height: 16),
            Text(
              "Please wait, generating response...",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontFamily: 'Cera Pro',
              ),
            ),
          ],
        ),
      );
    } else {
      return MarkdownBody(
        data: lastWords,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(
            fontSize: 15,
            color: Colors.black,
            fontFamily: 'Cera Pro',
          ),
          h1: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Cera Pro',
          ),
          h2: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Cera Pro',
          ),
          h3: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Cera Pro',
          ),
          listBullet: const TextStyle(
            fontSize: 15,
            color: Colors.black,
            fontFamily: 'Cera Pro',
          ),
          code: const TextStyle(
            backgroundColor: Color(0xFFEEEEEE),
            fontFamily: 'monospace',
            fontSize: 14,
          ),
          codeblockDecoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(8),
          ),
          tableHead: const TextStyle(fontWeight: FontWeight.bold),
          tableBody: const TextStyle(fontSize: 14),
        ),
      );
    }
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Gemini AI Assistant",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Cera Pro',
          ),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              width: math.max(MediaQuery.of(context).size.width * 0.8, 200),
              height: math.min(MediaQuery.of(context).size.height * 0.1, 80),
              margin: const EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  "GEMINI",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        math.min(MediaQuery.of(context).size.width * 0.1, 30),
                    color: Colors.black,
                    fontFamily: 'Cera Pro',
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: math.max(MediaQuery.of(context).size.width * 0.8, 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Ask me anything...',
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: math.min(
                        MediaQuery.of(context).size.width * 0.05,
                        20,
                      ),
                      fontFamily: 'Cera Pro',
                    ),
                    controller: promptController,
                    onSubmitted: (prompt) {
                      if (prompt.isNotEmpty) {
                        _sendPrompt(prompt);
                      }
                    },
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    final prompt = promptController.text;
                    if (prompt.isNotEmpty) {
                      _sendPrompt(prompt);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              width: math.max(MediaQuery.of(context).size.width * 0.8, 200),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: lastWords == "Please wait, generating response..."
                    ? _getDisplayWidget() 
                    : SingleChildScrollView(
                        child: _getDisplayWidget(),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendPrompt(String prompt) {
    setState(() {
      lastWords = "Please wait, generating response...";
    });

    // Clear the text field after sending
    promptController.clear();

    openAIService.GeminiAPI(prompt).then((response) {
      setState(() {
        lastWords = response;
      });
    }).catchError((error) {
      setState(() {
        lastWords = "❌ Error: $error";
      });
    });
  }
}
