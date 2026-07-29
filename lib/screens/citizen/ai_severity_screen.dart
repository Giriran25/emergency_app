import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ThreatLevel { low, medium, high, critical }

class AISeverityScreen extends StatefulWidget {
  final ThreatLevel initialSeverity;
  final String patientCondition;

  const AISeverityScreen({
    super.key,
    this.initialSeverity = ThreatLevel.critical,
    this.patientCondition =
        "Patient presenting suspected cardiac arrest with severe chest pain and breathlessness.",
  });

  @override
  State<AISeverityScreen> createState() => _AISeverityScreenState();
}

class _AISeverityScreenState extends State<AISeverityScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _dispatchInitiated = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getSeverityMetrics(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.critical:
        return {
          "label": "CRITICAL THREAT",
          "color": const Color(0xFFD32F2F),
          "window": "10–15 Minutes",
          "action": "Immediate ALS Dispatch",
          "progress": 1.0,
        };
      case ThreatLevel.high:
        return {
          "label": "HIGH SEVERITY",
          "color": const Color(0xFFF57C00),
          "window": "30–45 Minutes",
          "action": "BLS Ambulance Fleet",
          "progress": 0.75,
        };
      case ThreatLevel.medium:
        return {
          "label": "MODERATE RISK",
          "color": const Color(0xFFFBC02D),
          "window": "1–2 Hours",
          "action": "Clinical Tele-Triage",
          "progress": 0.50,
        };
      case ThreatLevel.low:
        return {
          "label": "LOW/STABLE",
          "color": const Color(0xFF388E3C),
          "window": "Routine Window",
          "action": "Self-Care Guidance",
          "progress": 0.25,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final metrics = _getSeverityMetrics(widget.initialSeverity);
    final Color severityColor = metrics["color"];

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "AI TRIAGE MONITOR",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated Circular Threat Gauge HUD
              ScaleTransition(
                scale: Tween<double>(begin: 0.97, end: 1.02).animate(
                  CurvedAnimation(
                    parent: _pulseController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: severityColor.withOpacity(0.25),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 170,
                        height: 170,
                        child: CircularProgressIndicator(
                          value: metrics["progress"],
                          strokeWidth: 10,
                          backgroundColor: isDark
                              ? Colors.white10
                              : Colors.grey.shade200,
                          color: severityColor,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_rounded,
                            color: severityColor,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            metrics["label"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: severityColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Technical Telemetry Metrics Group
              _buildDataTile(
                "Recommended System Action",
                metrics["action"],
                Icons.emergency_share_rounded,
                isDark,
              ),
              _buildDataTile(
                "Estimated Survival Window",
                metrics["window"],
                Icons.hourglass_top_rounded,
                isDark,
              ),

              const SizedBox(height: 24),

              // AI Clinical Reasoning Block
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "AI SYSTEM ANALYSIS",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white38 : Colors.black45,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.psychology_rounded,
                          color: Colors.blue,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Triage Log Reference",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      widget.patientCondition,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Decision Rules: Algorithmic cross-referencing maps historical dispatch criteria against geolocation telemetry.",
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white30 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Main Operational Control Switch Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _dispatchInitiated
                      ? null
                      : () {
                          HapticFeedback.vibrate();
                          setState(() {
                            _dispatchInitiated = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Emergency Protocol Initialized. Dispatching Unit...",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dispatchInitiated
                        ? Colors.grey
                        : severityColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _dispatchInitiated
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "DISPATCH COMMITTED",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            "CONFIRM DISPATCH PROTOCOL",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTile(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
