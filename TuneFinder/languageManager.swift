import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            loadLocalizedStrings()
        }
    }

    private var localizedStrings: [String: String] = [:]

    init() {
        if let languageCode = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String {
            currentLanguage = languageCode
        } else {
            currentLanguage = "en"
        }
        loadLocalizedStrings()
    }

    func getString(_ key: String) -> String {
        return localizedStrings[key] ?? ""
    }

    private func loadLocalizedStrings() {
        if let path = Bundle.main.path(forResource: currentLanguage, ofType: "strings"),
           let localizedDict = NSDictionary(contentsOfFile: path) as? [String: String] {
            localizedStrings = localizedDict
        } else {
            localizedStrings = [:]
        }
    }
}



struct LanguageKey: EnvironmentKey {
    static let defaultValue: String = "en"
}

extension EnvironmentValues {
    var appLanguage: String {
        get { self[LanguageKey.self] }
        set { self[LanguageKey.self] = newValue }
    }
}
