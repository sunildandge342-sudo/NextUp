import 'package:flutter/material.dart';
import 'home_page.dart';
import 'my_tokens_page.dart';
import 'notification_page.dart';
import '../account_page.dart';
import '../feedback_page.dart';
// ✅ correct import for AccountPage

class UserDashboard extends StatefulWidget {
  final int userId;
  final String? name;  // optional for personalization
  final String? email;
  final String? role;

  const UserDashboard({
    Key? key,
    required this.userId,
    this.name,
    this.email,
    this.role,
  }) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(userId: widget.userId),
      MyTokensPage(userId: widget.userId),
      NotificationsPage(userId: widget.userId),
      AccountPage(
        userId: widget.userId,
        name: widget.name ?? "User",
        email: widget.email ?? "Not Provided",
        role: widget.role ?? "USER",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: "Tokens"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}


