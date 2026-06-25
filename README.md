# 🚌 StarTraval - Real-Time Bus Booking & Fleet Tracking Platform

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org)

**StarTraval** is a high-performance, multi-tenant mobile platform designed to modernize regional transit systems. It bridges the gap between passengers, conductors, and fleet administrators by providing robust real-time bus location tracking, dynamic seat allocation, and automated digital ticketing infrastructure.

---

## 📸 UI Screenshots & Demo

### 📱 Passenger App (Booking Flow)
<table align="center">
  <tr>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/149d1527-5b9d-44e0-9f77-e87d005743f6" width="250" alt="Passenger Home"/>
      <br><sub><b>1. Home / Route Search</b></sub>
    </td>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/e6e20ecf-3c54-4d8a-bc55-984ec557bfb1" width="250" alt="Passenger Home"/>
      <br><sub><b>2. Dynamic Seat Matrix</b></sub>
    </td>
    <td align="center" width="25%">
       <img src="https://github.com/user-attachments/assets/d49a33ab-3f5c-4717-93f1-73611321efab" width="250" alt="Passenger Home"/>
      <br><sub><b>3. Live Location Tracking</b></sub>
    </td>
    <td align="center" width="25%">
       <img src="https://github.com/user-attachments/assets/d49e73cc-012f-45b9-8870-38cb31a2c9c7" width="250" alt="Passenger Home"/>
      <br><sub><b>4. Digital Boarding Pass</b></sub>
    </td>
  </tr>
</table>

### 🧑‍✈️ Conductor Dashboard (Live Tracking)
<table align="center">
  <tr>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/b52b6e8d-7679-46a2-b9b1-18c77c777053" width="210" alt="Conductor Login"/>
      <br><sub><b>1. Conductor Auth / Login</b></sub>
    </td>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/9133bab7-87dd-4636-bbd0-d8fafe17684d" width="210" alt="Trip Selection"/>
      <br><sub><b>2. Assigned Trip Select</b></sub>
    </td>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/6072ed9d-81d5-445c-af5b-9b4d05210de1" width="210" alt="Active Dashboard"/>
      <br><sub><b>3. Live Pulse Dashboard</b></sub>
    </td>
    <td align="center" width="25%">
      <img src="https://github.com/user-attachments/assets/10a1a6d5-568e-45dc-a68a-706c390ecbcd" width="210" alt="GPS Telemetry Broadcast"/>
      <br><sub><b>4. Real-time Map Stream</b></sub>
    </td>
  </tr>
</table>

### 💻 Fleet Admin Monitor (Management)
<table align="center">
  <tr>
    <td align="center" width="20%">
      <img src="https://github.com/user-attachments/assets/ca9f209b-6550-4d35-8c63-cdea882da99e" width="210" alt="Admin Login"/>
      <br><sub><b>1. Admin Dashboardf</b></sub>
    </td>
    <td align="center" width="20%">
      <img src="https://github.com/user-attachments/assets/cf2261ff-467c-47d5-913b-3d0ea1d0f0c4"  width="210" alt="Live Fleet Monitor"/>
      <br><sub><b>2. Edit Bus Details</b></sub>
    </td>
    <td align="center" width="20%">
      <img src="https://github.com/user-attachments/assets/c9431afa-0511-461e-b0dd-808261e2cfc1" width="210" alt="Bus & Route Management"/>
      <br><sub><b>3. Assign the Conductor</b></sub>
    </td>
    <td align="center" width="20%">
      <img src="https://github.com/user-attachments/assets/8a859e63-09d2-42b4-93ad-456ab411348d" width="210" alt="Transaction Analytics"/>
      <br><sub><b>4. Reports & Analytics</b></sub>
    </td>
    <td align="center" width="20%">
      <img src="https://via.placeholder.com/210x440?text=Admin+Reports" width="210" alt="Transaction Analytics"/>
      <br><sub><b>4. Reports & Analytics</b></sub>
    </td>
  </tr>
</table>


> 🎥 **Video Demonstration:** [Click here to watch the complete walkthrough on YouTube](YOUR_YOUTUBE_LINK_HERE)
 
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
