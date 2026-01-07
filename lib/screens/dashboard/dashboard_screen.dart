import 'package:flutter/material.dart';
import 'package:nextup/screens/scan_qr_screen.dart';
import 'package:nextup/screens/enter_code_screen.dart';
import 'package:nextup/screens/browse_services_screen.dart';
import 'help_page.dart';
import 'account_page.dart';
class UserDashboard extends StatefulWidget {
  final int userId;

  const UserDashboard({super.key, required this.userId});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {

  int _currentIndex = 0;

  @override
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      /// 🔝 PREMIUM LIGHT APP BAR (NO BACK ARROW)
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xFFEFF2FF),
        foregroundColor: Colors.indigo,
        title: const Text(
          "NextUp",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.indigo,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.indigo),
            tooltip: "Help",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpPage()),
              );
            },
          ),
        ],
      ),

      /// 📄 BODY
      body: _buildBody(),

      /// 🔽 BOTTOM NAVIGATION (CLEAN & CORRECT)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE6E8F0),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            letterSpacing: 0.2,
          ),
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: [
            _navItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: "Home",
              index: 0,
            ),
            _navItem(
              icon: Icons.confirmation_number_outlined,
              activeIcon: Icons.confirmation_number,
              label: "Tokens",
              index: 1,
            ),
            _navItem(
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications,
              label: "Alerts",
              index: 2,
            ),
            _navItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: "Account",
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;

    return BottomNavigationBarItem(
      label: label,
      icon: AnimatedScale(
        scale: isSelected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: isSelected ? 1.0 : 0.7,
          duration: const Duration(milliseconds: 180),
          child: Icon(icon),
        ),
      ),
      activeIcon: AnimatedScale(
        scale: isSelected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: Icon(activeIcon),
      ),
    );
  }

  /// 🔀 TAB SWITCHER
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _homeTab();
      case 1:
        return _emptyState(
          icon: Icons.confirmation_number,
          title: "No Active Tokens",
          subtitle: "Your joined queues will appear here",
        );
      case 2:
        return _emptyState(
          icon: Icons.notifications,
          title: "No Notifications",
          subtitle: "Queue updates will be shown here",
        );
      case 3:
        return _accountTab();
      default:
        return _homeTab();
    }
  }

  /// 🏠 HOME TAB
  Widget _homeTab() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.indigo, Colors.indigoAccent],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome Back",
                  style:  TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Skip the waiting line",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Join virtual queues in seconds",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Join a Queue",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),


          const SizedBox(height: 16),

          _actionTile(
            icon: Icons.qr_code_scanner,
            title: "Scan QR Code",
            subtitle: "Fastest way to join",
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScanQRScreen(userId: widget.userId),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          _actionTile(
            icon: Icons.dialpad,
            title: "Enter Queue Code",
            subtitle: "Type the code manually",
            color: Colors.deepOrange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EnterCodeScreen(userId: widget.userId),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          _actionTile(
            icon: Icons.apps,
            title: "Browse Services",
            subtitle: "Discover nearby queues",
            color: Colors.blueAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BrowseServicesScreen(userId: widget.userId),
                ),
              );
            },
          ),

        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material( // 🔥 REQUIRED
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color, // 🔥 solid background for contrast
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: Colors.white, // 🔥 always visible
                ),
              ),


              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }


  Widget _accountTab() {
    return AccountPage(
      firstName: "",
      email: "",
      mobile: "",
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}