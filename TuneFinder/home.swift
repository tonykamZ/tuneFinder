import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        TextField("Search for \(getEntityStringForDisplay(viewModel.selectedEntities))", text: $viewModel.searchText)
                            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 0))
                            .background(Color(.systemGray5))
                            .cornerRadius(8)

                        Button(action: {
                            viewModel.performSearch()
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
                                ForEach(viewModel.searchResults) { result in
                                    HStack {
                                        AsyncImage(url: URL(string: result.artworkUrl100)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 100, height: 100)
                                        } placeholder: {
                                            Color.gray
                                        }
                                        .frame(width: 100)
                                        
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
                            }else{
                                // initial home page UI
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
                .navigationBarTitle("Tune Finder")
            }
            .onAppear {
                viewModel.loadData()
            }
        }
    }
}
