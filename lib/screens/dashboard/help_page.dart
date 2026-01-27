import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'sunil.cs24024@mmcc.edu.in',
      query: 'subject=NextUp App Support&body=Hello, I need help with...',
    );
    if (!await launchUrl(emailUri)) {
      throw Exception('Could not launch email client');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.deepPurple.shade100,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧭 About Section
            const Text(
              'About NextUp',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'NextUp is a Virtual Queue Management System designed to eliminate long physical lines. '
                  'It allows users to join queues remotely and get notified when their turn is approaching. '
                  'Service Providers can manage services, issue tokens, and monitor real-time activity.',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),

            const SizedBox(height: 24),

            // ⚙️ How to Use Section
            const Text(
              'How to Use the App',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildStepsCard(
              context,
              'For Users',
              [
                '1️⃣ Register or Log in to your account.',
                '2️⃣ Go to the Home page and scan a QR or select a service manually.',
                '3️⃣ Receive a virtual token and check your position in the queue.',
                '4️⃣ Get notifications as your turn approaches.',
              ],
            ),

            _buildStepsCard(
              context,
              'For Service Providers',
              [
                '1️⃣ Register as an Admin from the signup screen.',
                '2️⃣ Add your service details (name, timings, etc.).',
                '3️⃣ Manage tokens for customers efficiently.',
                '4️⃣ View analytics and monitor queue performance.',
              ],
            ),

            const SizedBox(height: 24),

            // 💬 FAQs
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildFAQ(
              'Why can’t I join a queue?',
              'Ensure you have a stable internet connection and the service is open for queue registration.',
            ),
            _buildFAQ(
              'Can I cancel a token?',
              'Yes, go to “My Tokens” → select a token → tap “Cancel Token.”',
            ),
            _buildFAQ(
              'What if I miss my turn?',
              'You can rejoin the queue, but you’ll be placed at the end of the waiting list.',
            ),

            const SizedBox(height: 24),

            // 📞 Contact Support
            const Text(
              'Need More Help?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you’re facing any issues or have suggestions, feel free to contact us at:',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _launchEmail,
                icon: const Icon(Icons.email, color: Colors.white),
                label: const Text(
                  'Contact Support',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Custom step card
  Widget _buildStepsCard(BuildContext context, String title, List<String> steps) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            for (final step in steps)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(step, style: const TextStyle(fontSize: 15)),
              ),
          ],
        ),
      ),
    );
  }

  // FAQ widget
  Widget _buildFAQ(String question, String answer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline, color: Colors.deepPurple),
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(answer, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
