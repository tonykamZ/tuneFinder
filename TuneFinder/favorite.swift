import SwiftUI

struct FavoriteCollection: Hashable, Decodable {
    let collectionId: Int
    let collectionName: String
    let artworkUrl100: String
}

struct FavoritesView: View {
    @State private var favoriteCollections: [FavoriteCollection] = []
    @State private var isLoading = false

    var body: some View {
        VStack {
            ScrollView {
                if isLoading {
                    ProgressView()
                        .padding()
                } else {
                    let subtitle = Text("total") + Text(" \(favoriteCollections.count) ") + Text("fav")
                    VStack {
                        subtitle.localize()
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(favoriteCollections, id: \.self) { collection in
                            FavoriteListView(result: collection, cid: collection.collectionId)
                        }
                    }
                    .padding(.horizontal)
                    .onAppear {
                        loadFavoriteCollections()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBackButton())
    }
    
    private func loadFavoriteCollections() {
        guard let storageColl = UserDefaults.standard.array(forKey: "FavoriteCollections") as? [[String: Any]] else {
            return
        }
        
        isLoading = true
        favoriteCollections = storageColl.compactMap { dictionary in
            guard let collectionId = dictionary["collectionId"] as? Int,
                  let collectionName = dictionary["collectionName"] as? String,
                  let artworkUrl100 = dictionary["artworkUrl100"] as? String else {
                return nil
            }
            
            isLoading = false
            return FavoriteCollection(collectionId: collectionId, collectionName: collectionName, artworkUrl100: artworkUrl100)
        }
    }
}


struct FavoriteListView: View {
    let result: FavoriteCollection
    let cid: Int
    
    var body: some View {
        NavigationLink(destination: DetailView(previewUrl: "", cid: cid)) {
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
                }
                .padding(12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray5))
            .cornerRadius(8)
            .padding(.bottom, 5)
        }
    }
}
