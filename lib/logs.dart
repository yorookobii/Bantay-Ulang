import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'landing_page.dart';
import 'tasks.dart';
import 'yield.dart';
import 'profile.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> with SingleTickerProviderStateMixin {
  // High-Contrast Aquatic Palette
  final Color tealLight = const Color(0xFFE6FFF9);
  final Color teal = const Color(0xFF0D9488);
  final Color tealDark = const Color(0xFF0F766E);
  final Color seaBlue = const Color(0xFF0369A1);
  final Color textDark = const Color(0xFF1F2937);
  final Color textMuted = const Color(0xFF6B7280);

  late GlobalKey<ScaffoldState> _scaffoldKey;
  late AnimationController _fadeController;

  // Mock Data Storage
  final List<Map<String, dynamic>> ulangLogs = [];
  final List<Map<String, dynamic>> plantLogs = [];

  // Controllers - Ulang
  final sizeController = TextEditingController();
  final weightController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  // Controllers - Plant
  final plantHeightController = TextEditingController();
  final plantConditionController = TextEditingController();
  String? selectedPlantStage;
  String? selectedPlantName;
  DateTime plantDate = DateTime.now();

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
    sizeController.dispose();
    weightController.dispose();
    plantHeightController.dispose();
    plantConditionController.dispose();
    super.dispose();
  }

  // =======================
  // Logic Helpers
  // =======================
  double parseWeight(String weight) {
    return double.tryParse(weight.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
  }

  List<Map<String, dynamic>> getWeightByLast7Days() {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> data = [];

    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      double total = 0;

      for (var log in ulangLogs) {
        DateTime d = log['date'];
        if (d.year == day.year && d.month == day.month && d.day == day.day) {
          total += parseWeight(log['weight']);
        }
      }

      data.add({
        'label': "${day.month}/${day.day}",
        'total': total,
      });
    }
    return data;
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: tealDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // =======================
  // UI Build
  // =======================
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF3F4F6),
        drawer: _buildSidebar(context),
        appBar: _buildTopBar(context),
        body: FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
          ),
          child: TabBarView(
            children: [
              _buildUlangTab(),
              _buildPlantTab(),
            ],
          ),
        ),
      ),
    );
  }

  // =======================
  // Ulang Tab UI
  // =======================
  Widget _buildUlangTab() {
    final weekData = getWeightByLast7Days();
    final maxWeight = weekData.map((e) => e['total'] as double).fold(0.0, max);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Tala ng Ulang", "I-record ang sukat at timbang ng mga ulang."),
          const SizedBox(height: 24),

          // Statistics
          _statCard("Kabuuang Tala", ulangLogs.length.toString(), Icons.pets),
          const SizedBox(height: 24),

          // Weekly Chart
          _buildSectionTitle("Lingguhang Timbang"),
          const SizedBox(height: 12),
          _buildChartCard(weekData, maxWeight),
          const SizedBox(height: 24),

          // Data Entry Form
          _buildSectionTitle("Magdagdag ng Tala (Log)"),
          const SizedBox(height: 12),
          _buildUlangForm(),
          const SizedBox(height: 24),

          // Logs List
          if (ulangLogs.isNotEmpty) ...[
            _buildSectionTitle("Mga Nakaraang Tala"),
            const SizedBox(height: 12),
            ...ulangLogs.map((log) => _buildUlangLogCard(log)),
          ],
        ],
      ),
    );
  }

  // =======================
  // Plant Tab UI
  // =======================
  Widget _buildPlantTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Tala ng Tanim", "I-record ang paglaki at kondisyon ng mga halaman."),
          const SizedBox(height: 24),

          // Statistics
          _statCard("Kabuuang Tala", plantLogs.length.toString(), Icons.eco),
          const SizedBox(height: 24),

          // Data Entry Form
          _buildSectionTitle("Magdagdag ng Tala (Log)"),
          const SizedBox(height: 12),
          _buildPlantForm(),
          const SizedBox(height: 24),

          // Logs List
          if (plantLogs.isNotEmpty) ...[
            _buildSectionTitle("Mga Nakaraang Tala"),
            const SizedBox(height: 12),
            ...plantLogs.map((log) => _buildPlantLogCard(log)),
          ],
        ],
      ),
    );
  }

  // =======================
  // Component Widgets
  // =======================
  PreferredSizeWidget _buildTopBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(115), // Extended height for TabBar
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
          child: Column(
            children: [
              Padding(
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
              TabBar(
                indicatorColor: teal,
                indicatorWeight: 3,
                labelColor: tealDark,
                unselectedLabelColor: textMuted,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                tabs: const [
                  Tab(text: "Tala ng Ulang"),
                  Tab(text: "Tala ng Tanim"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: textMuted,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textDark,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tealLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tealDark, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: tealDark,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<Map<String, dynamic>> weekData, double maxWeight) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: weekData.map((d) {
          double pct = maxWeight > 0 ? d['total'] / maxWeight : 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    d['label'],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 28, // Slightly taller for easier reading
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: pct > 0 ? pct : 0.01, // Give a tiny width even if 0 for visuals
                      child: Container(
                        decoration: BoxDecoration(
                          color: pct > 0 ? teal : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 60,
                  child: Text(
                    "${d['total'].toStringAsFixed(1)} g",
                    textAlign: TextAlign.right,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: tealDark,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUlangForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildInputField(sizeController, "Laki (cm)", keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildInputField(weightController, "Bigat (g)", keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          _buildSaveButton("I-save ang Ulang Log", () {
            if (sizeController.text.isNotEmpty && weightController.text.isNotEmpty) {
              setState(() {
                ulangLogs.insert(0, {
                  "size": sizeController.text,
                  "weight": weightController.text,
                  "date": selectedDate
                });
                sizeController.clear();
                weightController.clear();
              });
              _showSuccessSnackbar("Matagumpay na na-save ang tala ng Ulang.");
            }
          }),
        ],
      ),
    );
  }

  Widget _buildPlantForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildCustomDropdown(
            value: selectedPlantName,
            hint: "Pumili ng uri ng tanim",
            label: "Pangalan ng Tanim",
            items: const [
              DropdownMenuItem(value: 'Mint', child: Text('Mint')),
              DropdownMenuItem(value: 'Oregano', child: Text('Oregano')),
              DropdownMenuItem(value: 'Kangkong', child: Text('Kangkong')),
            ],
            onChanged: (value) => setState(() => selectedPlantName = value),
          ),
          const SizedBox(height: 16),
          _buildInputField(plantHeightController, "Taas (cm)", keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildInputField(plantConditionController, "Kondisyon (hal. Malusog, Dilaw)"),
          const SizedBox(height: 16),
          _buildCustomDropdown(
            value: selectedPlantStage,
            hint: "Pumili ng yugto ng paglaki",
            label: "Yugto ng Paglaki",
            items: const [
              DropdownMenuItem(value: 'Seedling', child: Text('Seedling (Punla)')),
              DropdownMenuItem(value: 'Vegetative', child: Text('Vegetative (Lumalaki)')),
              DropdownMenuItem(value: 'Pre-Flowering', child: Text('Pre-Flowering')),
              DropdownMenuItem(value: 'Harvest', child: Text('Harvest (Handa na anihin)')),
            ],
            onChanged: (value) => setState(() => selectedPlantStage = value),
          ),
          const SizedBox(height: 20),
          _buildSaveButton("I-save ang Plant Log", () {
            if (selectedPlantName != null &&
                plantHeightController.text.isNotEmpty &&
                plantConditionController.text.isNotEmpty &&
                selectedPlantStage != null) {
              setState(() {
                plantLogs.insert(0, {
                  "name": selectedPlantName,
                  "height": plantHeightController.text,
                  "condition": plantConditionController.text,
                  "stage": selectedPlantStage,
                  "date": plantDate
                });
                selectedPlantName = null;
                selectedPlantStage = null;
                plantHeightController.clear();
                plantConditionController.clear();
              });
              _showSuccessSnackbar("Matagumpay na na-save ang tala ng Tanim.");
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSaveButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType, // Crucial for UX on numbers
      style: GoogleFonts.poppins(fontSize: 15, color: textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: teal, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
      ),
    );
  }

  Widget _buildCustomDropdown<T>({
    required T? value,
    required String hint,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      hint: Text(hint, style: GoogleFonts.poppins(fontSize: 14, color: textMuted)),
      style: GoogleFonts.poppins(fontSize: 15, color: textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: teal, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
      ),
      items: items,
      onChanged: onChanged,
      dropdownColor: Colors.white,
    );
  }

  Widget _buildUlangLogCard(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: seaBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.pets, color: seaBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Laki: ${log['size']} cm",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                Text(
                  "Timbang: ${log['weight']} g",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantLogCard(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1), // Green for plants
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco, color: Color(0xFF10B981), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['name'] ?? "Tanim",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Taas: ${log['height']}cm • Yugto: ${log['stage'] ?? '-'}",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: textMuted,
                  ),
                ),
                if (log['condition'] != null && log['condition']!.isNotEmpty)
                  Text(
                    "Kondisyon: ${log['condition']}",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: textMuted,
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
                  _buildNavLink(Icons.show_chart, "Inaasahang Ani", context, page: const YieldEstimationPage()),
                  _buildNavLink(Icons.list, "Logs & Record", context, isActive: true),
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