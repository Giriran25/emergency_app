import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../core/constants.dart';
import 'citizen_profile.dart';

enum ThreatLevel { low, medium, high, critical }

class CitizenHome extends StatefulWidget {
  const CitizenHome({super.key});

  @override
  State<CitizenHome> createState() => _CitizenHomeState();
}

class _CitizenHomeState extends State<CitizenHome>
    with SingleTickerProviderStateMixin {
  int currentTab = 0;
  bool sosActive = false;
  bool driverAccepted = false;
  String emergencyType = "None";
  String? currentAlertDocId;

  // Location & Map Data
  String locationArea = "Detecting Area...";
  String locationCity = "Searching...";
  String locationPincode = "------";
  double? userLat;
  double? userLng;
  late GoogleMapController mapController;
  final LatLng _initialLocation = const LatLng(12.9716, 77.5946);

  // User Data (Fetched from Firebase)
  String userName = "Loading...";
  String userAge = "--";
  String userBlood = "--";

  // Driver Response Data
  String assignedDriver = "Searching...";
  String eta = "Calculating...";

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _handleLocationAndPermissions();
    _listenToDriverNotifications();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ================= 1. AUTOMATIC FIREBASE DATA FETCH =================
  void _fetchUserData() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.exists && mounted) {
              final data = snapshot.data() as Map<String, dynamic>;
              setState(() {
                userName = data['name'] ?? user.displayName ?? "Citizen";
                userAge = data['age']?.toString() ?? "--";
                userBlood = data['bloodGroup'] ?? "--";
              });
            }
          });
    }
  }

  // ================= 2. LOGIC: NOTIFICATIONS & LOCATION =================
  void _listenToDriverNotifications() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection('emergency_alerts')
        .where('citizenId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty && mounted) {
            // Pick latest alert document
            var docs = snapshot.docs.toList()
              ..sort((a, b) {
                var aTime = a.data()['timestamp'] as Timestamp?;
                var bTime = b.data()['timestamp'] as Timestamp?;
                if (aTime == null || bTime == null) return 0;
                return bTime.compareTo(aTime);
              });

            var data = docs.first.data();
            String status = data['status'] ?? 'pending';

            if (status == 'accepted' || status == 'picked_up') {
              setState(() {
                sosActive = true;
                driverAccepted = true;
                assignedDriver = data['driverName'] ?? "Ravi Kumar";
                eta = data['eta'] ?? "5 Minutes";
              });
            } else if (status == 'completed') {
              setState(() {
                sosActive = false;
                driverAccepted = false;
                currentAlertDocId = null;
              });
              _snack("Emergency resolution completed by responder.");
            }
          }
        });
  }

  Future<void> _handleLocationAndPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          userLat = position.latitude;
          userLng = position.longitude;
        });
        _updateAddressInfo(position);
        try {
          mapController.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(position.latitude, position.longitude),
            ),
          );
        } catch (e) {}
      }
    });
  }

  Future<void> _updateAddressInfo(Position pos) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          locationArea = place.subLocality ?? place.name ?? "Unknown Area";
          locationCity = place.locality ?? "Unknown City";
          locationPincode = place.postalCode ?? "";
        });
      }
    } catch (e) {}
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ================= 3. UI BUILDERS =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Stack(
        children: [
          if (currentTab == 0) _buildMapBackground(),
          if (currentTab == 0) _buildTopGradientArea(),
          SafeArea(
            child: Column(
              children: [
                _buildProfessionalHeader(),
                Expanded(child: _buildTabSwitcher()),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialLocation,
          zoom: 15,
        ),
        onMapCreated: (controller) => mapController = controller,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }

  Widget _buildTopGradientArea() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildProfessionalHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "SERO",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              letterSpacing: 4,
            ),
          ),
          Row(
            children: [
              _headerIcon(Icons.notifications_active_outlined, driverAccepted),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const CitizenProfile()),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20,
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon, bool hasUpdate) {
    return Stack(
      children: [
        Icon(icon, color: Colors.black87, size: 28),
        if (hasUpdate)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              height: 10,
              width: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    switch (currentTab) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildEmergencyTypeView();
      case 2:
        return _buildAISeverityView();
      case 3:
        return _buildLiveTrackingView();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_getGreeting()}, $userName",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Medical ID: $userBlood | Age: $userAge | Type Selected: $emergencyType",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildUniqueLocationCard(),
          const SizedBox(height: 15),
          _buildBrandedHospitalCard(),
          const SizedBox(height: 30),
          _sosButton(),
          if (sosActive) _buildDriverResponseHUD(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // --- TAB 1: EMERGENCY TYPE SELECTOR ---
  Widget _buildEmergencyTypeView() {
    final List<Map<String, dynamic>> categories = [
      {
        "id": "Cardiac",
        "title": "Cardiac Arrest",
        "subtitle": "Chest pain, unresponsiveness, stroke symptoms",
        "icon": Icons.heart_broken_rounded,
        "color": const Color(0xFFE53935),
      },
      {
        "id": "Accident",
        "title": "Vehicle Accident",
        "subtitle": "Road collisions, trapped victims, high impact",
        "icon": Icons.car_crash_rounded,
        "color": const Color(0xFFF57C00),
      },
      {
        "id": "Trauma",
        "title": "Severe Trauma",
        "subtitle": "Heavy bleeding, deep wounds, fractures, falls",
        "icon": Icons.bloodtype_rounded,
        "color": const Color(0xFFD32F2F),
      },
      {
        "id": "Maternity",
        "title": "Maternity / OBGYN",
        "subtitle": "Active labor complications, severe prenatal pain",
        "icon": Icons.pregnant_woman_rounded,
        "color": const Color(0xFF8E24AA),
      },
      {
        "id": "General",
        "title": "General Medical",
        "subtitle":
            "High fever, severe allergic reaction, breathing difficulty",
        "icon": Icons.medical_services_rounded,
        "color": const Color(0xFF1976D2),
      },
      {
        "id": "Other",
        "title": "Other Crisis",
        "subtitle": "Unlisted critical hazards requiring dispatch triage",
        "icon": Icons.help_center_rounded,
        "color": const Color(0xFF607D8B),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 10, 8, 16),
            child: Text(
              "Select Emergency Type",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final item = categories[index];
                final String itemId = item['id'];
                final bool isSelected = emergencyType == itemId;
                final Color categoryColor = item['color'];

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      emergencyType = itemId;
                      currentTab = 0;
                    });
                    _snack("Selected Emergency Type: $itemId");
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? categoryColor : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? categoryColor
                            : Colors.grey.shade200,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? categoryColor.withOpacity(0.4)
                              : Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : categoryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: isSelected ? Colors.white : categoryColor,
                            size: 28,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['subtitle'] as String,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
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
    );
  }

  // --- TAB 2: AI SEVERITY ANALYSIS MONITOR ---
  Widget _buildAISeverityView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1.02).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.25),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 10,
                      backgroundColor: Colors.white,
                      color: Colors.red,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.analytics_rounded,
                        color: Colors.red,
                        size: 36,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "CRITICAL THREAT",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          _dataCard(
            "Recommended Action",
            "Immediate ALS Dispatch",
            Icons.emergency_share_rounded,
          ),
          _dataCard(
            "Estimated Survival Window",
            "10–15 Minutes",
            Icons.hourglass_top_rounded,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.psychology_rounded,
                      color: Colors.blue,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "AI Reasoning Log",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  "Selected Emergency Type ($emergencyType) cross-referenced against location response time metrics indicates severe risk profile.",
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _triggerSOS(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "CONFIRM & DISPATCH",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: LIVE TRACKING DISPLAY ---
  Widget _buildLiveTrackingView() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "STATUS TELEMETRY",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ETA: $eta",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flash_on_rounded, color: Colors.red),
              ),
            ],
          ),
          const Divider(height: 30),
          _dataCard(
            "Assigned Driver",
            assignedDriver,
            Icons.person_pin_rounded,
          ),
          _dataCard(
            "Destination Facility",
            "City General Hospital",
            Icons.local_hospital_rounded,
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => HapticFeedback.lightImpact(),
                  icon: const Icon(Icons.call_rounded),
                  label: const Text("CALL DRIVER"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _dataCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HOME CARDS ---
  Widget _buildUniqueLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_searching_rounded,
            color: AppColors.primary,
            size: 30,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationArea,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  "$locationCity, $locationPincode",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandedHospitalCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NEAREST HOSPITAL",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "City General Hospital",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _sosButton() {
    return Center(
      child: GestureDetector(
        onLongPress: _triggerSOS,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 180,
          width: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: sosActive ? Colors.blueGrey : Colors.red,
            boxShadow: [
              BoxShadow(
                color: (sosActive ? Colors.blueGrey : Colors.red).withOpacity(
                  0.4,
                ),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  sosActive
                      ? Icons.wifi_protected_setup_rounded
                      : Icons.emergency_rounded,
                  color: Colors.white,
                  size: 40,
                ),
                Text(
                  sosActive ? "ACTIVE" : "SOS",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverResponseHUD() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              color: driverAccepted
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    driverAccepted
                        ? "RESPONDER DISPATCHED"
                        : "BROADCASTING SIGNAL",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                  FadeTransition(
                    opacity: _pulseController,
                    child: const Icon(
                      Icons.radio_button_checked,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.emergency_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignedDriver,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "ESTIMATED ARRIVAL: $eta",
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Real-time SOS Triggering & Firestore document creation
  Future<void> _triggerSOS() async {
    if (sosActive) return;
    if (emergencyType == "None") {
      _snack("Select Emergency Type in 'Type' tab first!");
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() => sosActive = true);

    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('emergency_alerts')
        .add({
          'citizenId': FirebaseAuth.instance.currentUser?.uid,
          'citizenName': userName,
          'citizenBlood': userBlood,
          'citizenAge': userAge,
          'location': GeoPoint(userLat ?? 12.9716, userLng ?? 77.5946),
          'locationName': "$locationArea, $locationCity",
          'type': emergencyType,
          'status': 'pending',
          'driverId': null,
          'driverName': null,
          'eta': "4 min",
          'timestamp': FieldValue.serverTimestamp(),
        });

    setState(() {
      currentAlertDocId = docRef.id;
    });

    _snack("Emergency broadcasted to nearest responders!");
  }

  Widget _buildBottomNav() {
    final tabs = [
      {'icon': Icons.home_filled, 'label': 'Home'},
      {'icon': Icons.list_alt_rounded, 'label': 'Type'},
      {'icon': Icons.auto_awesome, 'label': 'AI'},
      {'icon': Icons.near_me_rounded, 'label': 'Track'},
    ];
    return Positioned(
      bottom: 25,
      left: 24,
      right: 24,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(tabs.length, (i) {
            bool isSel = currentTab == i;
            return GestureDetector(
              onTap: () => setState(() => currentTab = i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tabs[i]['icon'] as IconData,
                    color: isSel ? AppColors.primary : Colors.grey.shade400,
                  ),
                  if (isSel)
                    Text(
                      tabs[i]['label'] as String,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }
}
