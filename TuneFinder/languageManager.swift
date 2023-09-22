import SwiftUI

extension Notification.Name {
    static let languageChanged = Notification.Name("LanguageChangedNotification")
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    private let selectedLanguageKey = "selectedLanguageKey"
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: selectedLanguageKey)
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }

    init() {
        self.currentLanguage = UserDefaults.standard.string(forKey: selectedLanguageKey) ?? NSLocale.current.language.languageCode?.identifier ?? "en"
    }
}
