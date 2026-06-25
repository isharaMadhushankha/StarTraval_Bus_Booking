# 🚌 StarTraval - Real-Time Bus Booking & Fleet Tracking Platform

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org)

**StarTraval** is a high-performance, multi-tenant mobile platform designed to modernize regional transit systems. It bridges the gap between passengers, conductors, and fleet administrators by providing robust real-time bus location tracking, dynamic seat allocation, and automated digital ticketing infrastructure.

---

## 📸 UI Screenshots & Demo

| Passenger App (Booking) | Conductor Dashboard (Live) | Fleet Admin Monitor |
| :---: | :---: | :---: |
| `<img width="720" height="1600" alt="img1" src="https://github.com/user-attachments/assets/4a4270e6-fa66-4685-9591-2ac26a1a2087" />
` | `[Insert Screenshot 2: Conductor Map]` | `[Insert Screenshot 3: Admin Console]` |
| *Smooth Seat Selection UI* | *Live Location Streaming* | *Fleet Management Dashboard* |

> 🎥 **Video Demonstration:** [Click here to watch the complete walkthrough on YouTube](YOUR_YOUTUBE_LINK_HERE)

---

## 🚀 Key Features & Architectural Points

### 👥 Multi-Role User Architecture
*   **Passenger Portal:** Advanced route discovery, interactive seat-selection matrix, instant checkout, and downloadable digital tickets.
*   **Conductor Portal:** Single-tap live location broadcasting with custom feedback indicators displaying active sync states.
*   **Admin Portal:** Comprehensive fleet administration, conductor-to-bus assignments, and real-time active fleet monitoring dashboards.

### 📍 Real-Time Fleet Tracking & Mapping
*   **High-Frequency Streaming:** Engineered a background location system using `geolocator` combined with PostgreSQL change streams (`Supabase Realtime Channels`) to broadcast coordinates every 10 seconds.
*   **Interactive Cartography:** Built a lightweight mapping interface using `flutter_map` ensuring fluid vehicle node rendering and translation.
*   **Automated Reverse-Geocoding:** Integrated the **OSM Nominatim API** to instantly resolve raw latitude/longitude inputs into human-readable landmark addresses.

### 🎫 Concurrency Controls & Dynamic Ticketing
*   **Race Condition Prevention:** Programmed transaction-level concurrency safeguards inside the database layer to check seat status fields immediately prior to checkout commits, eliminating double-booking hazards.
*   **Automated Document Engine:** Renders pixel-perfect A4 PDF boarding passes locally via device layout engines (`pdf` & `printing` packages).
*   **REST API Email Dispatcher:** Dispatches responsive HTML transaction receipts to passengers immediately upon payment using the **Resend API**.

---

## 💡 Smart Engineering Decisions

### ⚡ Optimistic UI Updates on Seat Matrix
To deliver an instantaneous, lag-free user experience, the seat booking matrix utilizes **Optimistic Rendering** managed via `Provider`. When a user taps an available seat, the UI state immediately toggles from *Available (Grey)* to *Selecting (Green)* locally in memory before the remote asynchronous Supabase transaction resolves. If the background network transaction fails, the state gracefully rolls back and syncs with the database, maintaining high perceived performance without visual stutter.

### 🌐 Bypassing OpenStreetMap Tile Blocking (403 Forbidden)
Standard mobile requests to basic OpenStreetMap asset servers frequently fail or get rate-limited with a *403 Forbidden* error due to strict User-Agent verification policies. To bypass this infrastructure bottleneck, this project routes map request pipelines through **CartoDB Voyager** tiles (`basemaps.cartocdn.com`) while injecting a custom `userAgentPackageName` header, ensuring 100% tile delivery uptime on both Android and iOS devices.

### 🔄 Custom Conductor Pulse Indicators
To keep conductors informed of their broadcast state without draining device resources, the live dashboard employs a custom-written pulse animation. Built entirely using explicit `AnimationController` and scale transitions, it provides low-overhead, tactical feedback proving that background sync telemetry remains operational.

---

## 🛠️ Tech Stack & Service Layer Blueprint

This application adheres to a strict modular separation of concerns, decoupling user interface controls from business data layers through the **Provider (ChangeNotifier)** pattern.

| Component / Library | Purpose | Service Tier |
| :--- | :--- | :--- |
| **Flutter (Dart SDK ^3.10.1)** | Cross-Platform UI | Client Application Layer |
| **Provider** | State Management | Reactive State & Business Logic Separation |
| **Supabase Flutter SDK** | Backend-as-a-Service | JWT Auth, Real-Time PostgreSQL Listeners, Storage |
| **`flutter_map` & `geolocator`** | Mapping & Telemetry | Live Asset Tracking & Device Coordinate Streams |
| **Nominatim API** | Reverse Geocoding | Raw Location-to-Address Parsing Engines |
| **`pdf` & `printing`** | Document Engineering | On-Device PDF Boarding Passes & Native Print Spoolers |
| **Resend API (REST HTTP)** | Email Infrastructure | Automated Transactional Dispatch & Responsive HTML HTML |
| **Google Fonts** | Design Typography | Application Visual Styling |

---

## ⚙️ Getting Started & Installation

Follow these steps to run the environment locally for testing or development.

### Prerequisites
* Flutter SDK (Version `^3.10.1` or higher installed)
* Active Supabase project containing table definitions for users, routes, seats, and booking histories.

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/YOUR_USERNAME/StarTraval-Bus-Booking.git](https://github.com/YOUR_USERNAME/StarTraval-Bus-Booking.git)
   cd StarTraval-Bus-Booking
