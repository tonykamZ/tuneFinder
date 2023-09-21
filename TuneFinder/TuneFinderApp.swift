import SwiftUI

@main
struct TuneFinderApp: App {
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.appLanguage, languageManager.currentLanguage)
                .onChange(of: languageManager.currentLanguage) { newLanguage in
                    // When the language changes, update the environment value
                    // This should cause your views to recalculate their bodies
                    HomeView()
                        .environment(\.appLanguage, newLanguage)
                }
        }
    }
}
