import SwiftUI
import UserNotifications

@main
struct DigitalMusicTutorsApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var themeManager = ThemeManager.shared

    init() {
        NotificationManager.shared.requestPermission()
        applyAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(themeManager)
                .environment(\.themeManager, themeManager)
                .preferredColorScheme(.dark)
        }
    }

    private func applyAppearance() {
        // Tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.dmtSurface)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().tintColor = UIColor(Color.dmtGold)
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.dmtMutedText)

        // Navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(Color.dmtSurface)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.dmtPrimaryText),
            .font: UIFont(name: "Georgia", size: 17) ?? UIFont.systemFont(ofSize: 17)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.dmtPrimaryText),
            .font: UIFont(name: "Georgia", size: 34) ?? UIFont.systemFont(ofSize: 34)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().tintColor = UIColor(Color.dmtGold)
    }
}

// MARK: - Root Content View
struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            HomeworkView()
                .tabItem {
                    Label("Homework", systemImage: "checklist")
                }

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            StudentProgressListView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar")
                }

            ResourcesView()
                .tabItem {
                    Label("Resources", systemImage: "books.vertical")
                }
        }
        .accentColor(.dmtGold)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(ThemeManager.shared)
}
