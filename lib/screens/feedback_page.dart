import 'package:flutter/material.dart';
import '../services/api_services.dart';

class feedback_page extends StatefulWidget {
  const feedback_page({Key? key}) : super(key: key);

  @override
  State<feedback_page> createState() => _feedback_pageState();
}

class _feedback_pageState extends State<feedback_page> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  double _rating = 3.0;
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final feedbackData = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "message": _messageController.text.trim(),
      "rating": _rating.toString(),
    };

    final response = await ApiService.submitFeedback(feedbackData);

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response["message"] ?? "Feedback submitted successfully")),
    );

    _formKey.currentState!.reset();
    setState(() => _rating = 3.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Feedback")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "We value your feedback 💬",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Your Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? "Enter your name" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? "Enter your email" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Your Message",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? "Please write your feedback" : null,
                ),
                const SizedBox(height: 16),

                const Text("Rate your experience:"),
                Slider(
                  value: _rating,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _rating.toString(),
                  onChanged: (val) => setState(() => _rating = val),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit Feedback"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
