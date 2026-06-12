import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Added for ScrollDirection
import 'package:google_fonts/google_fonts.dart';
import 'tasks.dart';
import 'yield.dart';
import 'logs.dart';
import 'profile.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  // Aquatic Color Palette
  final Color tealLight = const Color(0xFFE6FFF9);
  final Color teal = const Color(0xFF0D9488);
  final Color tealDark = const Color(0xFF0F766E);
  final Color deepsea = const Color(0xFF001F3F);
  final Color warningRed = const Color(0xFFDC2626);
  final Color textDark = const Color(0xFF1F2937);
  final Color textMuted = const Color(0xFF6B7280);

  int _currentNavIndex = 0;
  bool _showNotificationDropdown = false;
  bool _isNavBarVisible = true; // State for nav bar visibility
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (index == _currentNavIndex) return;
    setState(() {
      _currentNavIndex = index;
      // Ensure nav bar is visible when switching tabs
      _isNavBarVisible = true; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      extendBody: true, // Allows content to scroll behind the bottom nav bar
      appBar: _buildTopBar(context),
      
      // ── MAIN CONTENT AREA WITH SCROLL LISTENER ─────────────────────────
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is UserScrollNotification) {
            // User dragging up, content moving down -> hide nav bar
            if (notification.direction == ScrollDirection.reverse) {
              if (_isNavBarVisible) {
                setState(() => _isNavBarVisible = false);
              }
            } 
            // User dragging down, content moving up -> show nav bar
            else if (notification.direction == ScrollDirection.forward) {
              if (!_isNavBarVisible) {
                setState(() => _isNavBarVisible = true);
              }
            }
          }
          
          // Re-show nav bar when user hits the very bottom of the page
          if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 20) {
            if (!_isNavBarVisible) {
              setState(() => _isNavBarVisible = true);
            }
          }
          
          return false; // Let the notification bubble up
        },
        child: Stack(
          children: [
            IndexedStack(
              index: _currentNavIndex,
              children: [
                _buildDashboardView(), // Index 0: Dashboard
                const TasksPage(),     // Index 1: Gawain
                const YieldEstimationPage(), // Index 2: Ani
                const LogsPage(),      // Index 3: Logs
              ],
            ),

            // Notification dropdown overlay
            if (_showNotificationDropdown)
              Positioned(
                top: 0,
                right: 12,
                child: _buildNotificationDropdown(),
              ),
          ],
        ),
      ),

      // ── ANIMATED BOTTOM NAVIGATION BAR ─────────────────────────────────
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        // Slide out (down) if not visible, stay at 0 if visible
        offset: _isNavBarVisible ? Offset.zero : const Offset(0, 1.0),
        child: _buildBottomNavBar(),
      ),
    );
  }

  // ── DASHBOARD TAB CONTENT ──────────────────────────────────────────────
  Widget _buildDashboardView() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
      ),
      child: SingleChildScrollView(
        // The 100px bottom padding ensures content isn't permanently hidden behind the floating nav bar
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              "Magandang Araw!",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Narito ang buod ng iyong Bantay Ulang system ngayon.",
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),

            _buildStatusCard(),
            const SizedBox(height: 24),

            _buildUrgentTasksSection(),
            const SizedBox(height: 24),

            _buildYieldSection(),
            const SizedBox(height: 24),

            // Water Conditions
            Text(
              "Kondisyon ng Tubig",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildConditionCard(
              Icons.thermostat,
              "Temperatura",
              "Tamang-tama para sa paglaki ng ulang.",
              "KATAMTAMAN",
              teal,
            ),
            const SizedBox(height: 12),
            _buildConditionCard(
              Icons.water_drop,
              "Linis ng Tubig",
              "Walang nakitang lason o dumi.",
              "MAAYOS",
              teal,
            ),
            const SizedBox(height: 12),
            _buildConditionCard(
              Icons.air,
              "Hangin (Oxygen)",
              "May sapat na hangin para sa mga ulang.",
              "MATAAS",
              teal,
            ),
            const SizedBox(height: 24),

            // Plant Status
            Text(
              "Status ng mga Tanim",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildConditionCard(
              Icons.eco,
              "Mga Halaman",
              "Malusog at patuloy na lumalaki.",
              "MAAYOS",
              const Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR (no hamburger) ─────────────────────────────────────────────
  PreferredSizeWidget _buildTopBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(65),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // App logo / icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tealLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: teal, width: 1.5),
                  ),
                  child: Icon(Icons.water_drop, color: tealDark, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Bantay Ulang",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: tealDark,
                    ),
                  ),
                ),

                // Notifications
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none,
                        color: textDark,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          _showNotificationDropdown =
                              !_showNotificationDropdown;
                        });
                      },
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: warningRed,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),

                // Profile Avatar
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: tealLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: teal, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        "JD",
                        style: TextStyle(
                          color: tealDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── BOTTOM NAV BAR ─────────────────────────────────────────────────────
  Widget _buildBottomNavBar() {
    const navItems = [
      (Icons.home_rounded, Icons.home_outlined, "Dashboard"),
      (Icons.assignment_turned_in_rounded, Icons.assignment_outlined, "Gawain"),
      (Icons.show_chart_rounded, Icons.show_chart_outlined, "Ani"),
      (Icons.list_alt_rounded, Icons.list_alt_outlined, "Logs"),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (i) {
              final isActive = i == _currentNavIndex;
              final (activeIcon, inactiveIcon, label) = navItems[i];
              return _buildNavItem(
                activeIcon: activeIcon,
                inactiveIcon: inactiveIcon,
                label: label,
                isActive: isActive,
                onTap: () => _onNavTapped(i),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? tealLight : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? tealDark : textMuted,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? tealDark : textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── NOTIFICATION DROPDOWN ──────────────────────────────────────────────
  Widget _buildNotificationDropdown() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Mga Abiso",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildNotifItem(
              Icons.assignment_late,
              "Ulang Data Capture — URGENT",
              "Kailangang gawin bago mag-March 06.",
              warningRed,
            ),
            const Divider(height: 16),
            _buildNotifItem(
              Icons.water_drop,
              "Temperatura — Normal",
              "Wala pang pagbabago sa kondisyon.",
              teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── CONTENT WIDGETS ────────────────────────────────────────────────────
  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tealDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: tealDark.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: tealDark, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mabuti ang Kalagayan",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Ligtas ang tubig at masigla ang mga ulang at tanim.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatusSubcard("Laki ng Ulang", "Malusog"),
              const SizedBox(width: 16),
              _buildStatusSubcard("Dami ng Tanim", "Sapat"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSubcard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assignment_late, color: warningRed, size: 22),
            const SizedBox(width: 8),
            Text(
              "Mahahalagang Gawain",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: warningRed.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: warningRed.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.water_drop, color: warningRed, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ulang Data Capture",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: warningRed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "URGENT",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Kailangang gawin bago mag-March 06.",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        // Switch directly to the Tasks page via IndexedStack
                        setState(() {
                          _currentNavIndex = 1;
                          _isNavBarVisible = true; // Ensure nav bar stays visible when jumping
                        });
                      },
                      child: Text(
                        "Tingnan ang gawain →",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: teal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYieldSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tealLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.scale, color: tealDark, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "Inaasahang Ani",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "55 kg",
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: tealDark,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Base sa kasalukuyang kondisyon at dami ng ulang.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionCard(
    IconData icon,
    String title,
    String description,
    String status,
    Color themeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: themeColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: themeColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}