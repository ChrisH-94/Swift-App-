import SwiftUI
import UIKit
import UserNotifications
import CoreData

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var teacherName = UserDefaults.standard.string(forKey: "teacherName") ?? ""
    @State private var studioName = UserDefaults.standard.string(forKey: "studioName") ?? "Digital Music Tutors"
    @State private var tagline = UserDefaults.standard.string(forKey: "tagline") ?? "Expert Online Piano Tuition"
    @State private var moodleURL = UserDefaults.standard.string(forKey: "moodleURL") ?? ""
    @State private var contactEmail = UserDefaults.standard.string(forKey: "contactEmail") ?? ""
    @State private var showResetConfirmation = false
    @State private var showExportSheet = false
    @State private var exportURL: URL?

    // Notification prefs
    @State private var remindersEnabled = UserDefaults.standard.bool(forKey: "remindersEnabled")
    @State private var reminderMinutes: Int = {
        let stored = UserDefaults.standard.integer(forKey: "reminderMinutes")
        return stored == 0 ? 60 : stored
    }()
    @State private var notificationStatus: String = "Unknown"

    let reminderOptions = [30, 60, 120]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.paddingLarge) {
                settingsHeader

                // 1. Studio Identity
                SettingsSection(title: "Studio Identity") {
                    SettingsRow(label: "Teacher Name") {
                        TextField("Your Name", text: $teacherName)
                            .settingsTextField()
                    }
                    SettingsRow(label: "Studio Name") {
                        TextField("Studio Name", text: $studioName)
                            .settingsTextField()
                    }
                    SettingsRow(label: "Tagline") {
                        TextField("Expert Online Piano Tuition", text: $tagline)
                            .settingsTextField()
                    }
                    SettingsRow(label: "Moodle URL") {
                        TextField("https://", text: $moodleURL)
                            .settingsTextField()
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }
                    SettingsRow(label: "Contact Email") {
                        TextField("teacher@example.com", text: $contactEmail)
                            .settingsTextField()
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }

                    Button {
                        saveIdentity()
                    } label: {
                        Text("Save".uppercased())
                            .font(.dmtLabel(9))
                            .tracking(1.5)
                            .foregroundColor(.dmtBackground)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.dmtGold)
                            .cornerRadius(AppTheme.cornerRadius)
                    }
                }

                // 2. App Icon Upload
                SettingsSection(title: "App Icon") {
                    NavigationLink(destination: AppIconUploaderView()) {
                        HStack {
                            Text("Upload & Preview App Icon")
                                .font(.dmtBody(13))
                                .foregroundColor(.dmtPrimaryText)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .ultraLight))
                                .foregroundColor(.dmtMutedText)
                        }
                    }
                }

                // 3. Branding Colours
                SettingsSection(title: "Branding Colours") {
                    NavigationLink(destination: BrandingColoursView()) {
                        HStack {
                            Text("Customise Colours")
                                .font(.dmtBody(13))
                                .foregroundColor(.dmtPrimaryText)
                            Spacer()
                            HStack(spacing: 6) {
                                Circle().fill(themeManager.accentColor).frame(width: 16, height: 16)
                                Circle().fill(themeManager.backgroundColor).frame(width: 16, height: 16)
                                    .overlay(Circle().stroke(Color.dmtBorder, lineWidth: 1))
                            }
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .ultraLight))
                                .foregroundColor(.dmtMutedText)
                        }
                    }
                }

                // 4. Notification Preferences
                SettingsSection(title: "Notifications") {
                    Toggle("Lesson Reminders", isOn: $remindersEnabled)
                        .tint(.dmtGold)
                        .font(.dmtBody(13))
                        .foregroundColor(.dmtPrimaryText)
                        .onChange(of: remindersEnabled) { val in
                            UserDefaults.standard.set(val, forKey: "remindersEnabled")
                        }

                    if remindersEnabled {
                        VStack(alignment: .leading, spacing: AppTheme.paddingSmall) {
                            Text("Reminder Timing".uppercased())
                                .dmtLabel()

                            HStack(spacing: 0) {
                                ForEach(reminderOptions, id: \.self) { mins in
                                    Button {
                                        reminderMinutes = mins
                                        UserDefaults.standard.set(mins, forKey: "reminderMinutes")
                                    } label: {
                                        let label = mins < 60 ? "\(mins)m" : "\(mins/60)h"
                                        Text(label)
                                            .font(.dmtLabel(9))
                                            .tracking(1)
                                            .foregroundColor(reminderMinutes == mins ? .dmtBackground : .dmtMutedText)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(reminderMinutes == mins ? Color.dmtGold : Color.clear)
                                    }
                                    .clipShape(Capsule())
                                }
                            }
                            .padding(4)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth))
                        }
                    }

                    HStack {
                        Text("Permission: \(notificationStatus)")
                            .font(.dmtBody(12))
                            .foregroundColor(.dmtMutedText)
                        Spacer()
                        Button("Review Permissions") {
                            openSystemSettings()
                        }
                        .font(.dmtLabel(8))
                        .tracking(1)
                        .foregroundColor(.dmtGold)
                    }
                }

                // 5. Data Management
                SettingsSection(title: "Data") {
                    Button {
                        exportData()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .ultraLight))
                            Text("Export All Data as JSON")
                                .font(.dmtBody(13))
                        }
                        .foregroundColor(.dmtGold)
                    }

                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .font(.system(size: 14, weight: .ultraLight))
                            Text("Reset All Data")
                                .font(.dmtBody(13))
                        }
                        .foregroundColor(.dmtCrimson)
                    }
                }

                // 6. About
                SettingsSection(title: "About") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Version")
                                .font(.dmtBody(13))
                                .foregroundColor(.dmtMutedText)
                            Spacer()
                            Text(appVersion)
                                .font(.dmtBody(13))
                                .foregroundColor(.dmtPrimaryText)
                        }

                        Button {
                            UIApplication.shared.open(URL(string: "https://www.digitalmusictutors.com")!)
                        } label: {
                            Text("digitalmusictutors.com")
                                .font(.dmtBody(13))
                                .foregroundColor(.dmtGold)
                        }

                        Text("Built for Digital Music Tutors")
                            .font(.dmtBody(12))
                            .foregroundColor(.dmtMutedText)
                    }
                }

                Spacer(minLength: AppTheme.paddingXL)
            }
            .padding(.bottom, AppTheme.paddingXL)
        }
        .background(Color.dmtBackground.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset All Data", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) { resetAllData() }
        } message: {
            Text("This will permanently delete all students, tasks, lessons, and resources. This action cannot be undone.")
        }
        .sheet(isPresented: $showExportSheet) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            }
        }
        .onAppear { checkNotificationStatus() }
    }

    private var settingsHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Settings".uppercased())
                .font(.dmtDisplay(28))
                .foregroundColor(.dmtPrimaryText)
            Text("Studio Control Panel".uppercased())
                .dmtLabel()
        }
        .padding(.horizontal, AppTheme.paddingLarge)
        .padding(.top, AppTheme.paddingMedium)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func saveIdentity() {
        UserDefaults.standard.set(teacherName, forKey: "teacherName")
        UserDefaults.standard.set(studioName, forKey: "studioName")
        UserDefaults.standard.set(tagline, forKey: "tagline")
        UserDefaults.standard.set(moodleURL, forKey: "moodleURL")
        UserDefaults.standard.set(contactEmail, forKey: "contactEmail")
    }

    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized: notificationStatus = "Enabled"
                case .denied:     notificationStatus = "Denied"
                case .notDetermined: notificationStatus = "Not Set"
                default: notificationStatus = "Unknown"
                }
            }
        }
    }

    private func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func exportData() {
        exportURL = JSONExporter.export(context: PersistenceController.shared.container.viewContext)
        showExportSheet = true
    }

    private func resetAllData() {
        let context = PersistenceController.shared.container.viewContext
        let entities = ["Student", "HomeworkTask", "Lesson", "Resource",
                        "TeacherNote", "Piece", "SkillRating"]
        for entity in entities {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try? context.persistentStoreCoordinator?.execute(deleteRequest, with: context)
        }
        try? context.save()
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.paddingMedium) {
            Text(title.uppercased())
                .font(.dmtLabel(10))
                .tracking(3)
                .foregroundColor(.dmtMutedText)
                .padding(.horizontal, AppTheme.paddingLarge)

            VStack(alignment: .leading, spacing: AppTheme.paddingMedium) {
                content()
            }
            .padding(AppTheme.paddingMedium)
            .background(Color.dmtCard)
            .cornerRadius(AppTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(Color.dmtBorder, lineWidth: AppTheme.borderWidth)
            )
            .padding(.horizontal, AppTheme.paddingLarge)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow<Content: View>: View {
    let label: String
    let content: () -> Content

    init(label: String, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .dmtLabel()
            content()
        }
    }
}

// MARK: - Text field modifier
extension View {
    func settingsTextField() -> some View {
        self
            .font(.dmtBody(14))
            .foregroundColor(.dmtPrimaryText)
            .accentColor(.dmtGold)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(ThemeManager.shared)
    .preferredColorScheme(.dark)
}
