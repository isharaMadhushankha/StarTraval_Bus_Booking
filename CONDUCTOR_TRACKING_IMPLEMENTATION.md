# Phase 2: Conductor Location Tracking & Admin Assignment Implementation

## Features Implemented

### 1. **ConductorProvider** (`lib/data/conductor_provider.dart`)

- Manages conductor authentication and location sharing state
- **Key Methods**:
  - `_initializeConductor()` - Fetches conductor data and assigned bus from Supabase
  - `toggleLocationSharing()` - Start/stop location tracking
  - `_updateLocationToDatabase()` - Updates bus_locations table every 10 seconds with GPS coordinates
- **Features**:
  - Requests location permissions (Android/iOS)
  - Uses `geolocator` package for real-time GPS location
  - Updates Supabase `bus_locations` table with `latitude`, `longitude`, `timestamp`
  - Timer-based updates every 10 seconds when sharing is enabled
  - Status messages ("🔴 LIVE", "⚫ Offline")

### 2. **ConductorDashboardScreen** (`lib/features/admin/screens/conductor_dashboard_screen.dart`)

- UI for conductors to share their location
- **UI Components**:
  - Displays assigned bus number prominently
  - Toggle switch to start/stop location sharing
  - Pulse animation when LIVE
  - Status indicator (red pulse = LIVE, grey = Offline)
  - Shows current coordinates when sharing location
  - Smooth Material3 design with gradients

- **Key Features**:
  - Loading state while fetching conductor data
  - Error handling for unassigned conductors
  - Real-time coordinate display
  - Permission request handling

### 3. **AssignConductorDialog** (`lib/features/admin/screens/assign_conductor_dialog.dart`)

- Bottom sheet dialog for admin to assign conductors
- **Features**:
  - Lists all available conductors with name and phone
  - Shows already-assigned conductors (greyed out, disabled)
  - Radio button selection
  - Updates `conductors.assigned_bus_id` in Supabase
  - Scroll-enabled list
  - Success/error feedback via SnackBar

### 4. **Updated AdminDashboardScreen** (`admin_dashboard_screen_new_temp.dart`)

- Added "Assign Conductor" button (purple person_add icon) to each bus card
- Button triggers `AssignConductorDialog` in a modal bottom sheet
- Refresh buses after conductor assignment
- Preserves all existing functionality:
  - Search bar (From, To, Date)
  - Map tracking button
  - Live monitor button
  - Clear seats button
  - Delete button

## Database Updates Required

### Conductors Table

Must have these columns:

- `id` (UUID) - Primary key
- `name` (Text) - Conductor name
- `assigned_bus_id` (UUID) - Foreign key to buses.id (can be NULL)
- `phone` (Text) - Phone number

### Bus Locations Table

Already exists with:

- `bus_id` (UUID) - Primary key
- `latitude` (Float)
- `longitude` (Float)
- `timestamp` (Timestamp)

## Dependencies Added

- `geolocator: ^11.0.0` - For real-time GPS location tracking

## Android/iOS Permissions Required

### Android (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### iOS (`Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track the bus</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to track the bus in the background</string>
```

## User Workflows

### For Conductors:

1. Login as conductor
2. Navigate to Conductor Dashboard
3. View assigned bus number
4. Toggle "Share Location" switch
5. Confirm location permissions
6. See "🔴 LIVE" status and current coordinates
7. Location updates automatically every 10 seconds
8. Toggle off to stop sharing

### For Admins:

1. In Admin Dashboard, locate a bus card
2. Click purple "Assign Conductor" button
3. Select a conductor from the list
4. Conductor is now assigned to that bus
5. Monitor the bus location on Live Bus Tracking Map
6. Coordinates updated by conductor's device automatically

##Key Design Decisions

1. **10-Second Update Interval**: Balances battery life with smooth real-time movement
2. **Upsert Logic**: Automatically creates bus_location record if doesn't exist
3. **Permission Flow**: Requests both foreground and background location access
4. **Status Indicators**: Clear visual feedback (pulse animation for LIVE state)
5. **Separation of Concerns**: Conductors manage their own location, Admins view and assign

## Testing Checklist

- [ ] Conductor can login and see assigned bus
- [ ] "Share Location" toggle works
- [ ] Location permissions are requested correctly
- [ ] Bus location updates in Supabase every 10 seconds
- [ ] Map displays real-time location from conductor
- [ ] Admin can assign conductors to buses
- [ ] Already-assigned conductors are disabled in selection
- [ ] Assigned conductor appears in bus card
- [ ] Location updates stop when toggle is turned off
- [ ] App works on both Android and iOS emulators/devices
