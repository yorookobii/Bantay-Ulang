import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'landing_page.dart'; // Adjust if this should point to your dashboard
import 'yield.dart';
import 'logs.dart';
import 'profile.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with SingleTickerProviderStateMixin {
  // Unified High-Contrast Aquatic Palette
  final Color tealLight = const Color(0xFFE6FFF9);
  final Color teal = const Color(0xFF0D9488);
  final Color tealDark = const Color(0xFF0F766E);
  final Color seaBlue = const Color(0xFF0369A1);
  final Color warningRed = const Color(0xFFDC2626);
  final Color warningOrange = const Color(0xFFF59E0B);
  final Color textDark = const Color(0xFF1F2937);
  final Color textMuted = const Color(0xFF6B7280);

  late GlobalKey<ScaffoldState> _scaffoldKey;
  late AnimationController _fadeController;

  List<Map<String, dynamic>> tasks = [
    {
      "title": "Ulang Data Capture",
      "due": "Mar 06, 2026",
      "assignedBy": "Admin",
      "notes": "Kunin ang sukat at timbang ng ulang sa lahat ng tangke.",
      "status": "in-progress",
    },
  ];

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    
    // Quick, snappy fade transition instead of continuous loops
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

  void markAsCompleted(int index) {
    setState(() {
      tasks[index]["status"] = "done";
    });
  }

  Color statusColor(String status) {
    switch (status) {
      case "pending":
        return warningOrange;
      case "in-progress":
        return seaBlue;
      case "done":
        return teal;
      default:
        return textMuted;
    }
  }

  Color statusBackground(String status) {
    switch (status) {
      case "pending":
        return warningOrange.withOpacity(0.15);
      case "in-progress":
        return seaBlue.withOpacity(0.15);
      case "done":
        return teal.withOpacity(0.15);
      default:
        return Colors.grey.shade200;
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case "pending":
        return "Gagawin (Pending)";
      case "in-progress":
        return "Ginagawa (In Progress)";
      case "done":
        return "Tapos Na (Completed)";
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF3F4F6), // Light gray background for contrast
      drawer: _buildSidebar(context),
      appBar: _buildTopBar(context),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mga Gawain (Tasks)",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Mga nakatalagang gawain na kailangan mong tapusin.",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                "Kasalukuyang Listahan",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              
              tasks.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: List.generate(
                        tasks.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildTaskCard(tasks[index], index),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.menu, color: textDark, size: 28),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  tooltip: 'Buksan ang menu',
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Bantay Ulang",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: tealDark,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
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

  Widget _buildTaskCard(Map<String, dynamic> task, int index) {
    final bool isDone = task["status"] == "done";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LogsPage()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Icon and Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDone ? teal.withOpacity(0.1) : seaBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isDone ? Icons.check_circle : Icons.assignment,
                        color: isDone ? teal : seaBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task["title"],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task["notes"],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: textMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                ),

                // Task Details (Due Date & Assignee)
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: textMuted),
                    const SizedBox(width: 6),
                    Text(
                      "Due: ${task["due"]}",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.person, size: 16, color: textMuted),
                    const SizedBox(width: 6),
                    Text(
                      "By: ${task["assignedBy"]}",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Footer with Status Badge and Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBackground(task["status"]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel(task["status"]),
                        style: GoogleFonts.poppins(
                          color: statusColor(task["status"]),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (isDone)
                      Row(
                        children: [
                          Icon(Icons.verified, size: 20, color: teal),
                          const SizedBox(width: 6),
                          Text(
                            "Tapos Na",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: teal,
                            ),
                          ),
                        ],
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => markAsCompleted(index),
                        icon: const Icon(Icons.check, size: 18, color: Colors.white),
                        label: Text(
                          "Tapusin",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teal,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tealLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.task_alt, size: 48, color: tealDark),
          ),
          const SizedBox(height: 24),
          Text(
            "Wala kang nakatalagang gawain.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Maari kang magpahinga muna. Abangan ang susunod na ia-assign ng admin.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildSidebar(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1F2937),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                  Icon(Icons.water_drop, color: tealLight, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    "Bantay Ulang",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  // Note: Assuming 'landing_page.dart' contains DashboardPage based on your imports.
                  // If Dashboard is in a different file, adjust accordingly.
                  _buildNavLink(Icons.home, "Dashboard", context, page: const DashboardPage()), 
                  _buildNavLink(Icons.assignment_turned_in, "Mga Gawain", context, isActive: true),
                  _buildNavLink(Icons.show_chart, "Inaasahang Ani", context, page: const YieldEstimationPage()),
                  _buildNavLink(Icons.list, "Logs & Record", context, page: const LogsPage()),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: _buildNavLink(Icons.logout, "Mag-Log out", context, isLogout: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavLink(
    IconData icon,
    String title,
    BuildContext context, {
    Widget? page,
    bool isActive = false,
    bool isLogout = false,
  }) {
    final color = isLogout ? warningRed : (isActive ? tealLight : Colors.white70);
    
    return Material(
      color: isActive ? Colors.white.withOpacity(0.05) : Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // Close Drawer
          if (isLogout) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          } else if (page != null && !isActive) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isActive ? tealLight : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

