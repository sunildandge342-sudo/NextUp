import 'package:flutter/material.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Queue Status')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Current Token: 12', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Text(
              'Estimated Wait Time: 10 mins',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
