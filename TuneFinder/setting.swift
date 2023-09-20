import SwiftUI

struct SettingsView: View {
    @State private var isPickerVisible = false
    @State private var selectedLanguage = "en"
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Setting")
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
                        Text("Switch Language")
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
            .alignmentGuide(.top) { _ in 0 }
            
            if isPickerVisible {
                VStack {
                    Spacer()
                    Picker("Language", selection: $selectedLanguage) {
                        Text("English").tag("en")
                        Text("Traditional Chinese (Hong Kong)").tag("hk")
                        Text("Simplified Chinese (China)").tag("cn")
                    }
                    .pickerStyle(.wheel)
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .bottom))
                .animation(Animation.easeInOut(duration: 0.4), value: isPickerVisible)
            }
            
            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
