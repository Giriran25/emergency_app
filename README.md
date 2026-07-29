<p align="center">
  <img src="assets/logo.png" width="220" alt="SERO Logo">
</p>
# 🚑 SERO — Smart Emergency Response Orchestrator

<p align="center">
  <b>An AI-powered emergency response platform that intelligently connects citizens, ambulance drivers, hospitals, traffic authorities, and administrators into one coordinated emergency ecosystem.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter">
  <img src="https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase">
  <img src="https://img.shields.io/badge/Google%20Maps-Location-green?logo=googlemaps">
  <img src="https://img.shields.io/badge/License-MIT-success">
  <img src="https://img.shields.io/badge/Hackathon-HCF%20Mark%201-red">
</p>

---

## 📖 Overview

**SERO (Smart Emergency Response Orchestrator)** is an AI-assisted emergency response platform designed to reduce emergency response time through intelligent coordination between multiple stakeholders.

Instead of treating citizens, ambulance services, hospitals, and traffic management as separate systems, SERO orchestrates them into a **single real-time emergency workflow**, ensuring faster medical assistance and improved patient outcomes.

With just **one SOS button**, the platform automatically initiates a coordinated emergency response—from ambulance dispatch to hospital notification and live tracking.

---

# 🎯 Problem Statement

Medical emergencies often suffer because emergency services operate independently.

Typical delays include:

- Delayed ambulance allocation
- Lack of communication with hospitals
- Traffic congestion
- Manual coordination between multiple authorities
- Poor visibility of emergency progress

In critical situations, even a few minutes can determine patient survival.

---

# 💡 Solution

SERO transforms a simple emergency request into an intelligent, automated emergency response.

Once the user presses **SOS**, the system automatically:

- 📍 Detects the user's live GPS location
- 🚑 Identifies the nearest available ambulance
- 🧠 Estimates emergency severity (AI-ready architecture)
- 🏥 Notifies the destination hospital
- 🚦 Alerts traffic controllers for faster clearance
- 📲 Provides live ETA updates to the citizen
- 👨‍👩‍👧 Notifies emergency contacts
- 📡 Tracks the ambulance until hospital arrival

> **One SOS. One Coordinated Response. Zero Delays.**

---

# ✨ Key Features

## 👤 Citizen Module

- Secure Authentication
- Smart SOS Activation
- Emergency Type Selection
- Live GPS Detection
- Reverse Geocoding
- Medical Profile Management
- AI Severity Prediction *(Architecture Ready)*
- Live Ambulance Tracking
- Assigned Hospital Details
- Real-Time ETA Updates
- Emergency Contact Notifications

---

## 🚑 Ambulance Driver Module

- Real-Time Emergency Requests
- Assigned Patient Information
- Navigation Support
- Live Status Updates
- Mission Completion Workflow

---

## 🚦 Traffic Controller Module

- Active Emergency Dashboard
- Ambulance Route Monitoring
- Emergency Corridor Support
- Incident Monitoring
- Traffic Clearance Coordination

---

## 🛠️ Admin Module

- User Management
- Driver Management
- Emergency Monitoring
- Analytics Dashboard
- System Overview
- Platform Insights

---

# 🧠 Intelligent Emergency Workflow

```text
Citizen Presses SOS
          │
          ▼
Detect Live GPS Location
          │
          ▼
Estimate Emergency Severity
          │
          ▼
Locate Nearest Ambulance
          │
 ┌────────┼─────────────┐
 ▼        ▼             ▼
Driver   Traffic      Hospital
Alert    Alert        Alert
          │
          ▼
Citizen Receives Live ETA
          │
          ▼
Real-Time Ambulance Tracking
          │
          ▼
Patient Safely Reaches Hospital
```

---

# 🏗️ System Architecture

```text
                    Citizen Application
                           │
                           ▼
                Firebase Authentication
                           │
                           ▼
                 Cloud Firestore Database
                           │
      ┌────────────────────┼────────────────────┐
      ▼                    ▼                    ▼
Driver Dashboard   Traffic Controller     Admin Panel
      │                    │                    │
      └────────────────────┴────────────────────┘
                           │
                           ▼
                 Google Maps Platform
                           │
                           ▼
              Real-Time Emergency Tracking
```

---

# 📱 Application Modules

### Citizen

- Login & Registration
- Dashboard
- Emergency Type Selection
- Medical Profile
- AI Emergency Assessment
- Live Ambulance Tracking

### Ambulance Driver

- Emergency Dashboard
- Mission Details
- Navigation
- Status Updates

### Traffic Controller

- Emergency Monitoring
- Ambulance Tracking
- Route Clearance

### Administrator

- User Management
- Driver Management
- Emergency Analytics
- Platform Monitoring

---

# 🛠️ Technology Stack

## Mobile Development

- Flutter
- Dart
- Material Design

## Backend

- Firebase Authentication
- Cloud Firestore
- Firebase Storage

## Maps & Location

- Google Maps Flutter
- Geolocator
- Geocoding

## State Management

- Provider
- Stateful Widgets

---

# 🔥 Firebase Services

- Firebase Authentication
- Cloud Firestore
- Firebase Storage

### Planned

- Firebase Cloud Messaging
- Firebase Analytics

---

# 📂 Project Structure

```text
lib/
│
├── core/
│   ├── constants.dart
│   └── themes.dart
│
├── models/
│
├── screens/
│   ├── auth/
│   ├── citizen/
│   ├── driver/
│   ├── traffic_controller/
│   └── admin/
│
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── location_service.dart
│
├── widgets/
│
└── main.dart
```

---

# 📊 Firestore Collections

```text
users/

drivers/

traffic_controllers/

emergencies/

emergency_alerts/
```

---

# 🚀 Getting Started

## 1. Clone the Repository

```bash
git clone https://github.com/Giriran25/emergency_app.git
```

---

## 2. Navigate to the Project

```bash
cd emergency_app
```

---

## 3. Install Dependencies

```bash
flutter pub get
```

---

## 4. Configure Firebase

Place the Firebase configuration files in their respective directories.

### Android

```
android/app/google-services.json
```

### iOS

```
ios/Runner/GoogleService-Info.plist
```

---

## 5. Configure Google Maps API

Add your API key inside:

```
android/app/src/main/AndroidManifest.xml
```

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

---

## 6. Run the Application

```bash
flutter run
```

---

# 🚀 Future Roadmap

- 🤖 AI-Based Emergency Severity Prediction
- 🚑 Intelligent Ambulance Allocation
- 📲 Push Notifications
- 🚦 Smart Traffic Signal Integration
- 🏥 Live Hospital Bed Availability
- 🎙️ Voice Activated SOS
- 📡 Offline Emergency Mode
- ⌚ Wearable Device Integration
- 👨‍👩‍👧 Automatic Emergency Contact Alerts
- 📈 Predictive Emergency Analytics
- 🛰️ Government Emergency Service Integration

---

# 🏆 Hackathon

SERO was developed during the **HCF Hackathon – Mark 1**, held on **12 February 2026** at **Dayananda Sagar University**.

The event was organized in collaboration with:

- Humans Care Foundation (HCF)
- IEEE Computational Intelligence Society Student Branch, DSU
- IEEE Robotics & Automation Society Student Branch, DSU

Although initially built within a hackathon, the platform has been architected with scalability and real-world deployment in mind.

---

# 🤝 Contributing

Contributions are welcome!

1. Fork the repository

2. Create a feature branch

```bash
git checkout -b feature/awesome-feature
```

3. Commit your changes

```bash
git commit -m "Add awesome feature"
```

4. Push to your branch

```bash
git push origin feature/awesome-feature
```

5. Open a Pull Request

---

# 👥 Team Neurova

Developed with passion during **HCF Hackathon – Mark 1**

### Team Members

- **Ranjith Kumar G**
- **N. Vikas**
- **Manish**
- **Kishore B**

Together, Team Neurova envisioned SERO as an intelligent emergency response ecosystem capable of reducing emergency response time through AI, real-time communication, and seamless coordination.

---

# 🌍 Vision

To build a smarter emergency healthcare ecosystem where technology enables faster decisions, stronger coordination, and quicker medical assistance—helping save lives when every second matters.

---

# 📄 License

This project is licensed under the **MIT License**.

See the **LICENSE** file for more information.

---

<p align="center">

# 🚑 SERO

### Smart Emergency Response Orchestrator

**Building the future of intelligent emergency response through AI, real-time communication, and seamless coordination.**

**One SOS. One Coordinated Response. Zero Delays.**

Made with ❤️ by **Team Neurova**

</p>
