import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuestionBankScreen extends StatelessWidget {
  const QuestionBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go('/question-detail');
          },
          child: const Text('View Question'),
        ),
      ),
    );
  }
}
