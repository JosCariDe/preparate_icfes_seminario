import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuestionScreen extends StatelessWidget {
  const QuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go('/results');
          },
          child: const Text('Finish'),
        ),
      ),
    );
  }
}
