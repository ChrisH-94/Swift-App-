# Digital Music Tutors

A native iOS SwiftUI app for online piano teachers to manage student progress, homework, lessons, and resources.

---

## How to Open in Xcode

1. Clone or download this repository.
2. Open `DigitalMusicTutors.xcodeproj` in **Xcode 15** (File → Open… or double-click the `.xcodeproj` file).
3. Xcode will index the project automatically.

---

## How to Run on Simulator (iOS 16+)

1. Select a simulator target from the scheme selector (e.g. **iPhone 15 — iOS 17.x**).
2. Press **⌘R** (Product → Run) to build and launch the app.
3. On first launch, the app will request notification permissions — accept to enable lesson reminders.

> **Minimum target:** iOS 16.0

---

## How to Set the App Icon

1. In the app, go to **Settings → App Icon → Select Image**.
2. Choose a PNG image of at least 1024×1024px from your photo library.
3. Preview all icon sizes shown on-screen (20pt, 29pt, 40pt, 60pt, 76pt, 83.5pt, 1024pt).
4. Export the uploaded image from the app's Documents directory.
5. In Xcode, open **DigitalMusicTutors → Assets.xcassets → AppIcon**.
6. Drag the image into the appropriate slots, or use Xcode's icon set to auto-fill all sizes.

---

## How to Configure Push Notifications Entitlement

1. In Xcode, select the **DigitalMusicTutors** target.
2. Go to **Signing & Capabilities**.
3. Click **+ Capability** and add **Push Notifications**.
4. Ensure your Apple Developer account has a valid App ID with Push Notifications enabled at [developer.apple.com](https://developer.apple.com).
5. The app automatically requests user permission on first launch using `UNUserNotificationCenter`.

---

## How to Submit to the App Store

### 1. Signing & Provisioning
- In Xcode → Target → Signing & Capabilities, set your **Team** and enable **Automatically manage signing**.
- Ensure the Bundle ID (`com.digitalmusictutors.app`) matches one you've created in [App Store Connect](https://appstoreconnect.apple.com).

### 2. Archive
1. Select **Any iOS Device (arm64)** as the destination.
2. Go to **Product → Archive**.
3. Wait for the archive to complete.

### 3. Distribute via TestFlight
1. In the **Organizer** window (Window → Organizer), select your archive.
2. Click **Distribute App → App Store Connect → Upload**.
3. Follow the prompts to upload. The build will appear in **TestFlight** within minutes.
4. Add internal testers in App Store Connect → TestFlight → Internal Testing.

### 4. App Store Submission
1. In App Store Connect, create a new app version.
2. Fill in the metadata (screenshots, description, keywords).
3. Select the uploaded build.
4. Submit for **App Review**.

---

## SPM Dependencies

This project uses **no third-party Swift Package Manager dependencies**. All functionality is implemented using Apple frameworks:

| Framework | Usage |
|-----------|-------|
| `SwiftUI` | All UI views |
| `CoreData` | Local persistence (students, tasks, lessons, resources) |
| `UserNotifications` | Push notification scheduling |
| `LinkPresentation` | URL metadata & thumbnail fetching |
| `SafariServices` | In-app web browser |
| `PDFKit` / `UIGraphicsPDFRenderer` | Progress report PDF generation |
| `PhotosUI` | App icon image picker |

---

## Project Structure

```
DigitalMusicTutors/
├── App/
│   └── DigitalMusicTutorsApp.swift        ← App entry point, TabView
├── Theme/
│   ├── AppTheme.swift                      ← All colours, fonts, spacing constants
│   └── ThemeManager.swift                  ← @Published colours, environment injection
├── Models/
│   └── GradeLevel.swift                    ← Grade enum with displayName
├── CoreData/
│   ├── DigitalMusicTutors.xcdatamodeld/    ← CoreData model
│   └── PersistenceController.swift
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── HomeworkViewModel.swift
│   ├── CalendarViewModel.swift
│   ├── ProgressViewModel.swift
│   └── ResourceViewModel.swift
├── Views/
│   ├── Dashboard/DashboardView.swift
│   ├── Homework/HomeworkView.swift + AddTaskSheet.swift
│   ├── Calendar/CalendarView.swift + CalendarGrid.swift + AddLessonSheet.swift
│   ├── Progress/ProgressView.swift + StudentProgressProfile.swift + StarRatingView.swift
│   ├── Resources/ResourcesView.swift + AddResourceSheet.swift
│   ├── Settings/SettingsView.swift + AppIconUploaderView.swift + BrandingColoursView.swift
│   └── Shared/GradeBadge.swift + ProgressBarView.swift + StudentAvatarView.swift + EmptyStateView.swift
├── Utilities/
│   ├── PDFGenerator.swift
│   ├── NotificationManager.swift
│   ├── LinkMetadataFetcher.swift
│   ├── JSONExporter.swift
│   └── ImagePersistence.swift
└── Info.plist
```

---

## Design System

The app uses a single dark mode aesthetic matching [digitalmusictutors.com](https://www.digitalmusictutors.com):

- **Background:** `#0A0A0A` – near-black, cinematic
- **Surface/cards:** `#1A1A1A`
- **Accent/gold:** `#C9A84C` → `#E8C97A` (gradient)
- **Text:** `#F5F5F3` – off-white
- **Danger:** `#8B3A3A` – muted crimson
- **Success:** `#3A6B4A` – muted sage
- **Typography:** Georgia (serif display) + SF Pro/system (labels)
- All theme values defined in `AppTheme.swift` — no hardcoded hex values elsewhere.

---

## Architecture

- **MVVM** — ViewModels are `ObservableObject` classes injected via `@StateObject`/`@ObservedObject`
- **CoreData** persistence via `PersistenceController.shared`
- **UserDefaults** for teacher preferences (name, studio, Moodle URL, notification settings)
- **Dark mode only** — `UIUserInterfaceStyle = Dark` in Info.plist
