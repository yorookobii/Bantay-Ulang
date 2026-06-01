import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'landing_page.dart';
import 'tasks.dart';
import 'logs.dart';
import 'profile.dart';

class YieldEstimationPage extends StatefulWidget {
  const YieldEstimationPage({super.key});

  @override
  State<YieldEstimationPage> createState() => _YieldEstimationPageState();
}

class _YieldEstimationPageState extends State<YieldEstimationPage> with SingleTickerProviderStateMixin {
  // High-Contrast Aquatic Palette
  final Color tealLight = const Color(0xFFE6FFF9);
  final Color teal = const Color(0xFF0D9488);
  final Color tealDark = const Color(0xFF0F766E);
  final Color seaBlue = const Color(0xFF0369A1);
  final Color textDark = const Color(0xFF1F2937);
  final Color textMuted = const Color(0xFF6B7280);
  final Color successGreen = const Color(0xFF10B981);

  late GlobalKey<ScaffoldState> _scaffoldKey;
  late AnimationController _fadeController;
  
  bool _isRecalculating = false;

  // Dummy Data for Logic Transparency
  final double estimatedYieldKg = 55.0;
  final double marketPricePerKg = 500.0;
  
  double get estimatedRevenue => estimatedYieldKg * marketPricePerKg;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    
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

  // Simulated refresh function
  Future<void> _recalculateYield() async {
    setState(() {
      _isRecalculating = true;
    });
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isRecalculating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text("Updated na ang inaasahang ani at kita.", style: GoogleFonts.poppins()),
            ],
          ),
          backgroundColor: tealDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF3F4F6),
      drawer: _buildSidebar(context),
      appBar: _buildTopBar(context),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
        ),
        child: RefreshIndicator(
          onRefresh: _recalculateYield,
          color: teal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Inaasahang Ani at Kita",
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Pagtatantiya ng ani at kikitain base sa iyong mga tala at presyo sa merkado.",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: textMuted,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _isRecalculating ? null : _recalculateYield,
                      icon: _isRecalculating 
                          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: teal, strokeWidth: 2))
                          : Icon(Icons.refresh, color: tealDark, size: 28),
                      tooltip: 'I-update ang data',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main Yield & Revenue Highlight
                _buildMainYieldAndRevenueCard(),
                const SizedBox(height: 20),

                // Progress Card
                _buildSectionTitle(Icons.timelapse, "Siklo ng Paglaki (Cycle)"),
                const SizedBox(height: 12),
                _buildCycleProgressCard(),
                const SizedBox(height: 24),

                // Calculation Factors (Transparency for the user)
                _buildSectionTitle(Icons.calculate, "Mga Salik ng Pagtatantiya"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFactorCard("Avg. Timbang", "~50g", Icons.scale),
                    const SizedBox(width: 12),
                    _buildFactorCard("Buhay (Survival)", "85%", Icons.health_and_safety),
                  ],
                ),
                const SizedBox(height: 12),
                // Market Price Factor taking full width for emphasis
                _buildFactorCard(
                  "Kasalukuyang Presyo sa Merkado", 
                  "₱${marketPricePerKg.toStringAsFixed(0)} / kg", 
                  Icons.storefront,
                  isFullWidth: true,
                ),
                const SizedBox(height: 24),

                // Recommendation Section
                _buildSectionTitle(Icons.lightbulb, "Status at Rekomendasyon"),
                const SizedBox(height: 12),
                _buildRecommendationCard(),
              ],
            ),
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

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: tealDark),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textDark,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // UPDATED: Combined Yield and Revenue Card
  Widget _buildMainYieldAndRevenueCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tealDark, teal],
        ),
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
          // Yield Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Kabuuang Inaasahang Ani",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "ESTIMATE",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "${estimatedYieldKg.toStringAsFixed(0)} kg",
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1.0,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Target Harvest: Mar 15 – 20, 2026",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          
          // Revenue Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Inaasahang Kita (Gross Revenue)",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "₱${estimatedRevenue.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.payments, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleProgressCard() {
    const int totalDays = 120;
    const int currentDay = 65;
    const double progress = currentDay / totalDays;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Araw $currentDay ng $totalDays",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: tealDark,
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(teal),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Ang mga ulang ay kasalukuyang nasa yugto ng mabilisang paglaki.",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // Updated Factor Card to support full width
  Widget _buildFactorCard(String label, String value, IconData icon, {bool isFullWidth = false}) {
    Widget cardContent = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: seaBlue, size: 24),
              if (isFullWidth) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          if (!isFullWidth) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]
        ],
      ),
    );

    return isFullWidth ? cardContent : Expanded(child: cardContent);
  }

  Widget _buildRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tealLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: teal.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.check_circle, color: tealDark, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nasa Tamang Direksyon",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: tealDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Normal ang takbo ng paglaki. Panatilihin ang regular na pagpapakain upang maabot o mahigitan pa ang ₱27,500 na potensyal na kita.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: textDark.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
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
                  _buildNavLink(Icons.home, "Dashboard", context, page: const DashboardPage()),
                  _buildNavLink(Icons.assignment_turned_in, "Mga Gawain", context, page: const TasksPage()),
                  _buildNavLink(Icons.show_chart, "Inaasahang Ani", context, isActive: true),
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
    final color = isLogout ? const Color(0xFFDC2626) : (isActive ? tealLight : Colors.white70);
    
    return Material(
      color: isActive ? Colors.white.withOpacity(0.05) : Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
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