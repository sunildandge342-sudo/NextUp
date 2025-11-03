import 'package:flutter/material.dart';
import 'help_page.dart';

class HomePage extends StatelessWidget {
  final int userId;
  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "NextUp",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan QR to Join Queue',
            onPressed: () {
              // TODO: Navigate to QR Scanner page
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help & Support',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpPage()),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome
            const Text(
              "Welcome 👋",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Join a queue easily using one of the options below",
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),

            // --- Join Queue Options ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.qr_code_scanner,
                  label: "Scan QR",
                  color: Colors.deepPurple,
                  onTap: () {
                    // TODO: Navigate to QR Scanner
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.list_alt,
                  label: "Browse Services",
                  color: Colors.indigo,
                  onTap: () {
                    // TODO: Navigate to Services List
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.numbers,
                  label: "Enter Code",
                  color: Colors.orange,
                  onTap: () {
                    // TODO: Manual Code Entry
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- Quick Stats Section ---
            const Text(
              "Your Queue Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("Active Tokens", "2", Colors.green),
                _buildStatCard("Completed", "5", Colors.blue),
                _buildStatCard("Feedbacks", "3", Colors.purple),
              ],
            ),

            const SizedBox(height: 30),

            // --- Recent Tokens ---
            const Text(
              "Recent Tokens",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildRecentTokenCard("Electric Bill Payment", "#23", "Active", Colors.green),
            _buildRecentTokenCard("Passport Office", "#07", "Pending", Colors.orange),
            _buildRecentTokenCard("Aadhaar Update", "#45", "Completed", Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTokenCard(
      String service, String number, String status, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(number.replaceAll('#', ''),
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
        title: Text(service, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(status, style: TextStyle(color: color)),
      ),
    );
  }
}


