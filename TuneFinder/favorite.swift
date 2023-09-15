import SwiftUI

struct FavoritesView: View {
    @State private var favoritedSongs: [String] = [
        "Song 1",
        "Song 2",
        "Song 3"
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(favoritedSongs, id: \.self) { song in
                    Text(song)
                }
                .onDelete(perform: removeSong)
            }
            .navigationTitle("Favorites")
        }
    }
    
    private func removeSong(at offsets: IndexSet) {
        favoritedSongs.remove(atOffsets: offsets)
    }
}
