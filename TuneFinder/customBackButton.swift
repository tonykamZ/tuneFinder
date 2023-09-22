import SwiftUI

struct CustomBackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 0) {
                Image(systemName: "chevron.left")
            }
            .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
        }
    }
}
