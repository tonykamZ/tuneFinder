import SwiftUI

struct SettingsView: View {
    @Environment(\.locale) private var locale
    @Environment(\.appLanguage) var appLanguage
    @State private var isPickerVisible = false
    @State private var selectedLanguage = LanguageManager.shared.currentLanguage
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 8) {
            Text("setting")
                .font(Font.custom("Noteworthy-Bold", size: 20.0))
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)

            VStack {
                Button(action: {
                    withAnimation {
                        isPickerVisible.toggle()
                    }
                }) {
                    HStack {
                        Text("swlan")
                            .font(Font.custom("Noteworthy-Bold", size: 18.0))
                            .foregroundColor(Color(red: 122.0/255.0, green: 245/255.0, blue: 63.0/255.0, opacity: 0.66))
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        Image(systemName: isPickerVisible ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 14)
            }
            .frame(height: 40)

            if isPickerVisible {
                ScrollView {
                    VStack {
                        Picker("Language", selection: $selectedLanguage) {
                            Text("English").tag("en")
                            Text("繁體中文").tag("zh-hk")
                            Text("简体中文").tag("zh-Hans")
                        }
                        .pickerStyle(.wheel)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 150) // Adjust the height as needed
                .transition(.move(edge: .bottom))
                .animation(Animation.easeInOut(duration: 0.4), value: isPickerVisible)
            }

            Spacer()
        }
        .overlay {
            if isLoading {
                loadingView
            }
        }
        .onChange(of: selectedLanguage) { _ in
//            appLanguage = selectedLanguage
            languageChanged()
        }
        .onAppear {
            selectedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") ?? locale.identifier
        }
        .environment(\.locale, .init(identifier: selectedLanguage))
    }

    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.2)
            ProgressView()
                .scaleEffect(2)
                .opacity(1)
        }
        .ignoresSafeArea()
    }

    private func languageChanged() {
        LanguageManager.shared.currentLanguage = selectedLanguage
        UserDefaults.standard.set(selectedLanguage, forKey: "AppLanguage")
        UIApplication.sharedApplication().keyWindow?.rootViewController = storyboard!.instantiateViewControllerWithIdentifier("Root_View")
    }
}


