import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel = HomeViewModel()
    
    // handle paging in front end
    @State private var currentPage: Int = 1

    var displayedResults: [iTuneFilterApiResponse] {
        let startIndex = (currentPage - 1) * 20
        let endIndex = min(startIndex + 20, viewModel.searchResults.count)
        if(startIndex > endIndex){ // avoid lower bound error
            currentPage = 1
            let newEndIndex = min(20, viewModel.searchResults.count)
            return Array(viewModel.searchResults[0..<newEndIndex])
        }
        return Array(viewModel.searchResults[startIndex..<endIndex])
    }
    
    func previousPage() {
        if currentPage > 1 {
            currentPage -= 1
        }
    }

    func nextPage() {
        let totalPages = Int(ceil(Double(viewModel.searchResults.count) / 20))
        if currentPage < totalPages {
            currentPage += 1
        }
    }
    
    func currentPageRange() -> some View {
        let startRange = currentPage * 20 - 20 + 1
        let endRange = currentPage * 20 - 20 + displayedResults.count
        
        return Text("\(startRange)-\(endRange)")
            .font(.system(size: 12))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func reInitCurrentPage() {
          currentPage = 1
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Tune Finder")
                        .font(Font.custom("Noteworthy-Bold", size: 36.0))
                        .foregroundColor(Color(red: 0.0, green: 208.0/255.0, blue: 240.0/255.0, opacity: 0.81))
                    
                    SearchBarView(viewModel: viewModel, searchText: $viewModel.searchText, selectedEntities: viewModel.selectedEntities)

                    HStack {
                        EntitySelectionButton(entity: .song, viewModel: viewModel)
                        EntitySelectionButton(entity: .album, viewModel: viewModel)
                        EntitySelectionButton(entity: .musicArtist, viewModel: viewModel)
                    }
                    .padding(.horizontal)

                        VStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding()
                            } else if viewModel.isSearchedEmpty  {
                                VStack {
                                    Text("No results found in \(viewModel.currentSearchedEntities)")
                                        .font(.subheadline)
                                    Text("Search keyword: \"\(viewModel.currentSearchedKeyword)\"")
                                        .font(.subheadline)
                                        .padding()
                                }
                            } else {
                                if(!viewModel.currentSearchedEntities.isEmpty){
                                    Text("Total \(viewModel.searchResults.count) results (\(viewModel.currentSearchedEntities))")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    currentPageRange()
                                    ForEach(displayedResults) { result in
                                        SearchResultView(result: result)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: 100, alignment: .leading)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                                    .padding(.bottom, 5)
                                    
                                    
                                    currentPageRange()
                                    
                                    
                                    HStack {
                                        Button(action: {
                                            previousPage()
                                        }) {
                                            Image(systemName: "chevron.left")
                                        }
                                        .disabled(currentPage == 1)
                                        
                                        Text("\(currentPage)")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 18)
                                        
                                        Button(action: {
                                            nextPage()
                                        }) {
                                            Image(systemName: "chevron.right")
                                        }
                                        .disabled(currentPage * 20 >= viewModel.searchResults.count)
                                    }
                                    .padding()
                                }else{
                                    // initial home page UI
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .onChange(of: viewModel.isLoading) { isLoading in
                                    if isLoading {
                                        reInitCurrentPage()
                                    }
                                }

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
                .navigationBarItems(trailing:
                    HStack {
                        NavigationLink(destination: FavoritesView()) {
                            Text("My fav")
                                .font(Font.custom("Noteworthy-Bold", size: 18.0))
                                .foregroundColor(Color(red: 222.0/255.0, green: 245/255.0, blue: 63.0/255.0, opacity: 0.66))
                        }
                        
                    NavigationLink(destination: SettingsView()) {
                           Image(systemName: "gearshape")
                               .font(.system(size: 20))
                               .foregroundColor(.gray)
                       }
                    }
                )
            }
            .onAppear {
                viewModel.loadData()
            }
        }
    }
}

struct SearchBarView : View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding
    var searchText: String
    var selectedEntities: Set<Entity>
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var body: some View {
        HStack {
            TextField("Search for \(getEntityStringForDisplay(viewModel.selectedEntities))", text: $viewModel.searchText)
                .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 0))
                .background(Color(.systemGray5))
                .cornerRadius(8)

            Button(action: {
                viewModel.performSearch()
                hideKeyboard()
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(red: 0.2, green: 0.4, blue: 0.6))
                    .cornerRadius(8)
                    .padding(.leading, 8)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct SearchResultView: View {
    var result: iTuneFilterApiResponse
    
    var body: some View {
        NavigationLink(destination: DetailView(previewUrl: result.previewUrl, cid: result.collectionId)) {
            HStack {
                AsyncImage(url: URL(string: result.artworkUrl100)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 100, height: 100)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(result.collectionName)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    Text(result.artistName)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                    Text(result.primaryGenreName)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
                .padding(12)
            }
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .leading)
            .background(Color(.systemGray5))
            .cornerRadius(8)
            .padding(.bottom, 5)
        }
    }
}
