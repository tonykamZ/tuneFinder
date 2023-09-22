import SwiftUI
import AVFoundation

struct DetailView: View {
    let previewUrl: String
    let cid: Int
    @State private var isLoading = false
    @State private var isBookmarked = false
    @State private var showPopup = false
    @State private var fetchedResults: [iTuneFilterApiResponse] = []
    
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .padding()
            } else {
                VStack {
                    if let result = fetchedResults.first {
                        VStack {
                            AsyncImage(url: URL(string: result.artworkUrl100)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                            } placeholder: {
                                Color.gray
                                    .frame(width: 100, height: 100)
                            }
                            .frame(width: 100, height: 100)
                            
                            VStack(alignment: .leading) {
                                Text(result.collectionName)
                                    .font(.title)
                                
                                Text(result.artistName)
                                    .font(.subheadline)
                                
                                Text(result.primaryGenreName)
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    if showPopup {
                        ProgressView()
                            .padding()
                    } else {
                        Button(action: {
                            isBookmarked.toggle()
                            updateFavorites()
                        }) {
                            HStack {
                                Text(isBookmarked ? "bookmarked" : "bookmark").localize()
                                    .font(.subheadline)
                                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                    .font(.title)
                            }
                            .padding()
                           
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            fetchSongDetails()
            checkIsBookmarked()
        }
        .overlay(
            Group {
                if showPopup {
                    VStack {
                        Text("bookmarked").localize()
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(red: 0.2, green: 0.4, blue: 0.6).opacity(0.7))
                            .cornerRadius(10)
                            .transition(.opacity)
//                            .animation(Animation.easeInOut(duration: 1.4), value: showPopup)
                            .onAppear {
                                schedulePopupDismissal()
                            }
                            .padding(.top, 250)
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        )
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBackButton())
    }
    
    private func fetchSongDetails() {
        let collectionId = String(cid)
        let apiUrl = "https://itunes.apple.com/lookup?id=\(collectionId)"

        print(apiUrl)
        guard let url = URL(string: apiUrl) else {
            print("Invalid URL")
            return
        }
        
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data received")
                isLoading = false
                return
            }
            
            do{
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let results = json["results"] as? [[String: Any]] {
                                            
                    let searchResults = results.compactMap { resultDict in
                        if let artistName = resultDict["artistName"] as? String,
                           let collectionName = resultDict["collectionName"] as? String,
                           let artworkUrl100 = resultDict["artworkUrl100"] as? String,
                           let previewUrl = resultDict["collectionViewUrl"] as? String,
                           let collectionId = resultDict["collectionId"] as? Int,
                           let primaryGenreName = resultDict["primaryGenreName"] as? String {
                            return iTuneFilterApiResponse(
                                collectionId: collectionId,
                                collectionName: collectionName,
                                artistName: artistName,
                                primaryGenreName: primaryGenreName,
                                artworkUrl100: artworkUrl100,
                                previewUrl: previewUrl
                            )
                        }
                        return nil
                    }
                    
                    print("successfully get \(searchResults.count) data")
                    DispatchQueue.main.async {
                        fetchedResults.append(contentsOf: searchResults)
                        isLoading = false
                    }
                } else {
                    print("Failed to decode JSON data: Invalid format.")
                    isLoading = false
                }
            } catch let error {
                print("Error decoding JSON data: \(error)")
                isLoading = false
            }
        }.resume()
        
    }
    
    private func updateFavorites() {
        var favoriteCollections = UserDefaults.standard.array(forKey: "FavoriteCollections") as? [[String: Any]] ?? []

        if isBookmarked, let currentItem = fetchedResults.first {
            let collectionName = currentItem.collectionName
            let artworkUrl100 = currentItem.artworkUrl100
            
            let newCollection = ["collectionId": cid, "collectionName": collectionName, "artworkUrl100": artworkUrl100] as [String : Any]
            favoriteCollections.append(newCollection)
            
            showPopup = true
            schedulePopupDismissal()
        } else {
            favoriteCollections.removeAll { ($0["collectionId"] as? Int) == cid }
        }
        
        UserDefaults.standard.setValue(favoriteCollections, forKey: "FavoriteCollections")
    }
    
    private func schedulePopupDismissal() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            showPopup = false
        }
    }
    
    private func checkIsBookmarked() {
        let favoriteCollections = UserDefaults.standard.array(forKey: "FavoriteCollections") as? [[String: Any]] ?? []
        isBookmarked = favoriteCollections.contains { ($0["collectionId"] as? Int) == cid }
    }
    
}
