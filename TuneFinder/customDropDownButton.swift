import SwiftUI

struct DropdownButton: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var isDropdownVisible = false
    
    let countryOptions = [
        ("US", "United States"),
        ("UK", "United Kingdom"),
        ("CA", "Canada"),
        ("AU", "Australia"),
        ("DE", "Germany"),
        ("FR", "France"),
        ("IT", "Italy"),
        ("JP", "Japan"),
        ("KR", "South Korea"),
        ("MX", "Mexico"),
        ("NL", "Netherlands"),
        ("RU", "Russia"),
        ("SE", "Sweden"),
        ("BR", "Brazil"),
        ("ES", "Spain"),
        ("TW", "Taiwan"),
        ("ZA", "South Africa"),
        ("SG", "Singapore"),
        ("HK", "Hong Kong"),
        ("CN", "China")
    ]
    
    var body: some View {
        Button(action: {
            isDropdownVisible.toggle()
        }) {
            HStack {
                Text("🌎")
                Image(systemName: "chevron.down")
                    .foregroundColor(.blue)
            }
        }
        .popover(isPresented: $isDropdownVisible, arrowEdge: .top) {
            VStack {
                Text("filterCountry").localize()
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.vertical, 18)
                
                ScrollView (showsIndicators: false) {
                    ForEach(countryOptions, id: \.0) { country in
                        Button(action: {
                            viewModel.selectedCountry = country.0
                            isDropdownVisible.toggle()
                            if(!viewModel.searchText.isEmpty){
                                // refresh the result with current selected country
                                viewModel.performSearch()
                            }
                        }) {
                            let countryLoc = Text(LocalizedStringKey(country.0))
                            countryLoc.localize()
                                .padding(.vertical, 10)
                                .foregroundColor(viewModel.selectedCountry == country.0 ? .green : .primary)
                        }
                        .tag(country.0)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 52.0/255.0, green: 55/255.0, blue: 53.0/255.0, opacity: 0.36))
                .padding(.horizontal, 15)
                .cornerRadius(8)

                

            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}
