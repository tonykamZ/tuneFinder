import SwiftUI

struct SettingsView: View {
    @State private var selectedLanguage = "English"
    @State private var isDarkModeEnabled = false
    
    var body: some View {
        Form {
            Section(header: Text("Language")) {
                Picker("Language", selection: $selectedLanguage) {
                    Text("English").tag("English")
                    Text("Spanish").tag("Spanish")
                    Text("French").tag("French")
                }
            }
            
            Section(header: Text("Theme")) {
                Toggle("Dark Mode", isOn: $isDarkModeEnabled)
            }
        }
        .navigationTitle("Settings")
    }
}
