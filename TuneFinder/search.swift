import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var showFilterSheet = false

    var body: some View {
        VStack {
            SearchBar(text: $searchText)
                .padding()
            
            Button(action: {
                showFilterSheet = true
            }) {
                Text("Filter")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            List {
                // Display search results here
                ForEach(0..<10) { index in
                    Text("Result \(index)")
                }
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterView()
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Search", text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct FilterView: View {
    var body: some View {
        Text("Filter View")
    }
}
