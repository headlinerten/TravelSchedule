import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isDarkMode: Bool = false
    @Published var selectedTheme: Theme = .auto
    @Published var showNoInternet = false
    @Published var showServerError = false
    @Published var showAgreement = false
    
    init() {
        // Загружаем сохраненную тему
        if let savedTheme = UserDefaults.standard.object(forKey: "theme") as? String {
            selectedTheme = Theme(rawValue: savedTheme) ?? .auto
        }
        updateDarkModeState()
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
        selectedTheme = isDarkMode ? .dark : .light
        saveTheme()
    }
    
    func updateForColorScheme(_ colorScheme: ColorScheme) {
        if selectedTheme == .auto {
            isDarkMode = colorScheme == .dark
        }
    }
    
    private func updateDarkModeState() {
        isDarkMode = selectedTheme == .dark ||
                    (selectedTheme == .auto && UIScreen.main.traitCollection.userInterfaceStyle == .dark)
    }
    
    private func saveTheme() {
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "theme")
    }
    
    func showNoInternetScreen() {
        showNoInternet = true
    }
    
    func showServerErrorScreen() {
        showServerError = true
    }
    
    func showAgreementScreen() {
        showAgreement = true
    }
}
