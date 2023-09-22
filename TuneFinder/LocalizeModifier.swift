import SwiftUI

struct LocalizeModifier: ViewModifier {
    @Environment(\.locale) var locale
    @State var currentLanguage: String = LanguageManager.shared.currentLanguage

    func body(content: Content) -> some View {
        content
            .environment(\.locale, .init(identifier: currentLanguage))
            .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                currentLanguage = LanguageManager.shared.currentLanguage
            }
    }
}

extension View {
    func localize() -> some View {
        self.modifier(LocalizeModifier())
    }
}
