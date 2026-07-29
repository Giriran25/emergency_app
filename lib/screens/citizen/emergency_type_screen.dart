import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmergencyTypeScreen extends StatefulWidget {
  final String currentSelection;
  final ValueChanged<String> onTypeSelected;

  const EmergencyTypeScreen({
    super.key,
    required this.currentSelection,
    required this.onTypeSelected,
  });

  @override
  State<EmergencyTypeScreen> createState() => _EmergencyTypeScreenState();
}

class _EmergencyTypeScreenState extends State<EmergencyTypeScreen> {
  late String _selectedType;

  final List<Map<String, dynamic>> _emergencyCategories = [
    {
      "id": "Cardiac",
      "title": "Cardiac Arrest",
      "subtitle": "Chest pain, unresponsiveness, stroke symptoms",
      "icon": Icons.heart_broken_rounded,
      "color": const Color(0xFFE53935), // Urgent Red
    },
    {
      "id": "Accident",
      "title": "Vehicle Accident",
      "subtitle": "Road collisions, trapped victims, high impact",
      "icon": Icons.car_crash_rounded,
      "color": const Color(0xFFF57C00), // High Alert Orange
    },
    {
      "id": "Trauma",
      "title": "Severe Trauma",
      "subtitle": "Heavy bleeding, deep wounds, fractures, falls",
      "icon": Icons.bloodtype_rounded,
      "color": const Color(0xFFD32F2F), // Crimson
    },
    {
      "id": "Maternity",
      "title": "Maternity / OBGYN",
      "subtitle": "Active labor complications, severe prenatal pain",
      "icon": Icons.pregnant_woman_rounded,
      "color": const Color(0xFF8E24AA), // Purple
    },
    {
      "id": "General",
      "title": "General Medical",
      "subtitle": "High fever, severe allergic reaction, breathing difficulty",
      "icon": Icons.medical_services_rounded,
      "color": const Color(0xFF1976D2), // Clinical Blue
    },
    {
      "id": "Other",
      "title": "Other Crisis",
      "subtitle": "Unlisted critical hazards requiring dispatch triage",
      "icon": Icons.help_center_rounded,
      "color": const Color(0xFF607D8B), // Slate Grey
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentSelection;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "EMERGENCY TYPE",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What is the nature of the crisis?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Selecting the correct category optimizes specialized first-responder unit allocation.",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _emergencyCategories.length,
                itemBuilder: (context, index) {
                  final item = _emergencyCategories[index];
                  final String itemId = item['id'];
                  final bool isSelected = _selectedType == itemId;
                  final Color categoryColor = item['color'];

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _selectedType = itemId;
                      });
                      widget.onTypeSelected(itemId);

                      // Auto close/return after selection feedback delay
                      Future.delayed(const Duration(milliseconds: 250), () {
                        if (mounted) Navigator.pop(context);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? categoryColor
                            : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? categoryColor
                              : (isDark
                                    ? Colors.white10
                                    : Colors.grey.shade200),
                          width: 2,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: categoryColor.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          else
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
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : categoryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: isSelected
                                    ? Colors.white
                                    : categoryColor,
                                size: 28,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['subtitle'] as String,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
