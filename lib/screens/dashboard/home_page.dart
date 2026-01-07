import 'package:flutter/material.dart';
import 'help_page.dart';

class HomePage extends StatelessWidget {
  final int userId;
  const HomePage({super.key, required this.userId});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "NextUp",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
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

            // ================= WELCOME CARD =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A5AE0), Color(0xFF8E7BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Welcome 👋",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Tester4",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Join queues faster & smarter",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF6A5AE0)),
                  )
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ================= QUICK ACTIONS =================
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionCard(
                  icon: Icons.qr_code_scanner,
                  label: "Scan QR",
                  color: Colors.deepPurple,
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: Icons.list_alt,
                  label: "Services",
                  color: Colors.indigo,
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: Icons.numbers,
                  label: "Enter Code",
                  color: Colors.orange,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ================= STATS =================
            const Text(
              "Your Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _buildStatCard(
                  icon: Icons.timelapse,
                  title: "Active",
                  value: "2",
                  color: Colors.green,
                ),
                _buildStatCard(
                  icon: Icons.check_circle,
                  title: "Completed",
                  value: "5",
                  color: Colors.blue,
                ),
                _buildStatCard(
                  icon: Icons.feedback,
                  title: "Feedbacks",
                  value: "3",
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ================= RECENT TOKENS =================
            const Text(
              "Recent Tokens",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildRecentTokenCard(
              service: "Electric Bill Payment",
              token: "#23",
              status: "Active",
              color: Colors.green,
            ),
            _buildRecentTokenCard(
              service: "Passport Office",
              token: "#07",
              status: "Pending",
              color: Colors.orange,
            ),
            _buildRecentTokenCard(
              service: "Aadhaar Update",
              token: "#45",
              status: "Completed",
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ================= ACTION CARD =================
  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 13),

                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 38),

                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= STAT CARD =================
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 13),

              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  // ================= RECENT TOKEN =================
  Widget _buildRecentTokenCard({
    required String service,
    required String token,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 13),

            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 38),

          child: Text(
            token.replaceAll('#', ''),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          service,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          status,
          style: TextStyle(color: color),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}



