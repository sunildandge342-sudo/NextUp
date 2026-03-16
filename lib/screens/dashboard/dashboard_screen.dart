import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nextup/screens/scan_qr_screen.dart';
import 'package:nextup/services/notifications_store.dart';
import 'help_page.dart';
import 'account_page.dart';
import 'package:nextup/screens/dashboard/my_tokens_page.dart';
class UserDashboard extends StatefulWidget {
  final int userId;
  final String userName;
  const UserDashboard({
    super.key,
    required this.userId,
    required this.userName});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}
class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;
  // ── Back button exit confirmation ────────────────────────────────────────
  Future<bool> _onBackPressed() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Do you want to exit the application?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    ) ??
        false;
  }

  // ✅ FIX: Removed unused `late String firstName` that was never initialized.
  // widget.userName is used directly everywhere now.

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),

        // ── App bar ───────────────────────────────────────────────────────
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

        // ── Body ──────────────────────────────────────────────────────────
        body: _buildBody(),

        // ── Bottom navigation ─────────────────────────────────────────────
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE6E8F0), width: 1),
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
            onTap: (index) => setState(() => _currentIndex = index),
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

  // ── Tab switcher ─────────────────────────────────────────────────────────
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _homeTab();

      case 1:
        return MyTokensPage(userId: widget.userId);

      case 2:
        final notifications = NotificationStore.notifications;
        if (notifications.isEmpty) {
          return _emptyState(
            icon: Icons.notifications,
            title: "No Notifications",
            subtitle: "Queue updates will be shown here",
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.serviceName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${notification.time.hour}:${notification.time.minute}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );

      case 3:
        return _accountTab();

      default:
        return _homeTab();
    }
  }

  // ── Home tab ─────────────────────────────────────────────────────────────
  Widget _homeTab() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // ✅ FIX: Pass widget.userName directly (guaranteed non-null from widget)
          WelcomeCard(firstName: widget.userName),

          const SizedBox(height: 36),

          // Section heading — pill tag
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x144F46E5),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  "Join a Queue",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.9,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Scan a QR code to get your token instantly",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9090A8),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Ghost shimmer button
          Center(
            child: _GhostShimmerButton(
              label: "Scan QR & Join",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanQRScreen(userId: widget.userId),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FIX: Pass actual widget.userName to AccountPage instead of empty string
  Widget _accountTab() {
    return AccountPage(firstName: widget.userName, email: "", mobile: "");
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// WELCOME CARD
// ─────────────────────────────────────────────────────────────────────────────

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key, required this.firstName});
  final String firstName;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return "Good morning";
    if (h < 17) return "Good afternoon";
    return "Good evening";
  }

  // ✅ FIX: Sanitize the name — treat "null", empty, or whitespace-only as Guest
  String get _displayName {
    final trimmed = firstName.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return "Guest";
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4845D4), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative orbs
          Positioned(top: -55, right: -55, child: _Orb(180, 0.06)),
          Positioned(bottom: -30, right: 30, child: _Orb(90, 0.04)),
          Positioned(top: 24, right: 88, child: _Orb(50, 0.035)),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                _greeting.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0x8CFFFFFF),
                  letterSpacing: 1.4,
                ),
              ),

              const SizedBox(height: 6),

              // ✅ FIX: Use _displayName getter instead of raw firstName
              Text(
                _displayName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 20),

              // Hairline divider
              Container(height: 0.5, color: const Color(0x24FFFFFF)),

              const SizedBox(height: 18),

              // Tagline
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0x99FFFFFF),
                    letterSpacing: 0.1,
                    height: 1.5,
                  ),
                  children: const [
                    TextSpan(text: "Join "),
                    TextSpan(
                      text: "virtual queues",
                      style: TextStyle(
                        color: Color(0xEBFFFFFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(text: " in seconds"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Orb helper ───────────────────────────────────────────────────────────────
class _Orb extends StatelessWidget {
  const _Orb(this.size, this.opacity);
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(opacity),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// GHOST SHIMMER BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _GhostShimmerButton extends StatefulWidget {
  const _GhostShimmerButton({
    required this.label,
    required this.onTap,
    this.width = 240,
    this.height = 54,
  });

  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  State<_GhostShimmerButton> createState() => _GhostShimmerButtonState();
}

class _GhostShimmerButtonState extends State<_GhostShimmerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.972 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _pressed
                ? const Color(0x194F46E5)
                : const Color(0x0D4F46E5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _pressed
                  ? const Color(0x994F46E5)
                  : const Color(0x664F46E5),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Top edge highlight
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0x334F46E5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Label + icon
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QrIcon(color: const Color(0xCC4F46E5), size: 18),
                    const SizedBox(width: 10),
                    const Text(
                      "Scan QR & Join",
                      style: TextStyle(
                        color: Color(0xFF4F46E5),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),

              // Shimmer sweep
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shimmer,
                  builder: (_, __) {
                    final t = _shimmer.value < 0.4
                        ? Curves.easeInOut.transform(_shimmer.value / 0.4)
                        : 1.0;
                    return FractionallySizedBox(
                      alignment: Alignment(-1.6 + (t * 3.2), 0),
                      widthFactor: 0.28,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0x1A4F46E5),
                              Color(0x1A4F46E5),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.35, 0.65, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QR ICON — custom painted
// ─────────────────────────────────────────────────────────────────────────────

class _QrIcon extends StatelessWidget {
  const _QrIcon({required this.color, this.size = 18});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _QrPainter(color: color),
    );
  }
}

class _QrPainter extends CustomPainter {
  const _QrPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size sz) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = sz.width * 0.085
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final u = sz.width;
    final r = Radius.circular(u * 0.18);
    final boxW = u * 0.38;

    void square(double x, double y) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, boxW, boxW),
        r,
      );
      canvas.drawRRect(rect, stroke);
      canvas.drawCircle(
        Offset(x + boxW / 2, y + boxW / 2),
        boxW * 0.22,
        fill,
      );
    }

    square(0, 0);
    square(u - boxW, 0);
    square(0, u - boxW);

    final dotR = u * 0.075;
    final ox = u - boxW + (boxW - 2 * dotR * 2.6) / 2;
    final oy = u - boxW + (boxW - 2 * dotR * 2.6) / 2;
    for (var c = 0; c < 2; c++) {
      for (var row = 0; row < 2; row++) {
        canvas.drawCircle(
          Offset(
            ox + c * dotR * 2.6 + dotR,
            oy + row * dotR * 2.6 + dotR,
          ),
          dotR,
          fill,
        );
      }
    }
  }
  @override
  bool shouldRepaint(_QrPainter old) => old.color != color;
}
