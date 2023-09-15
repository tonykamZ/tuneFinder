import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var searchResults: [iTuneFilterApiResponse] = []
    @Published var searchText: String = ""
    @Published var selectedEntities: Set<Entity> = []
    @Published var isLoading: Bool = false
    @Published var isSearchedEmpty: Bool = false
    @Published var currentSearchedEntities: String = ""
    @Published var currentSearchedKeyword: String = ""

    func performSearch() {
        let searchTerm = searchText.replacingOccurrences(of: " ", with: "+")
        let entityQuery = getEntityString(selectedEntities)
        let apiUrl = "https://itunes.apple.com/search?term=\(searchTerm)&entity=\(entityQuery)"
        
        guard let url = URL(string: apiUrl) else {
            return
        }
        
        isLoading = true // Set isLoading to true when starting the search
        
        print(apiUrl)
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isSearchedEmpty = self.searchResults.isEmpty
                    self.currentSearchedEntities = getEntityStringForDisplay(self.selectedEntities)
                    self.currentSearchedKeyword = self.searchText
                }
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                    let results = json["results"] as? [[String: Any]] {
                    let searchResults = results.compactMap { resultDict in
                        if let artistName = resultDict["artistName"] as? String,
                           let collectionName = resultDict["collectionName"] as? String,
                           let artworkUrl100 = resultDict["artworkUrl100"] as? String,
                            let primaryGenreName = resultDict["primaryGenreName"] as? String {
                            return iTuneFilterApiResponse(collectionName:collectionName, artistName: artistName, primaryGenreName: primaryGenreName, artworkUrl100: artworkUrl100)
                        }
                        return nil
                    }
                    DispatchQueue.main.async {
                        self.searchResults = searchResults
                    }
                } else {
                    print("Failed to decode JSON data: Invalid format.")
                    DispatchQueue.main.async {
                        self.searchResults = []
                    }
                }
            } catch let error {
                print("Error decoding JSON data: \(error)")
                self.searchResults = []
            }
        }.resume()
    }
    
    func loadData() {
        // Load initial data or perform any other setup tasks
    }

    func toggleEntitySelection(_ entity: Entity) {

        if selectedEntities.contains(entity) {
            selectedEntities.remove(entity)
        } else {
            selectedEntities.insert(entity)
        }
    }

    func isEntitySelected(_ entity: Entity) -> Bool {
        selectedEntities.contains(entity)
    }
}

struct iTuneFilterApiResponse: Identifiable {
    let id = UUID()
    let artistName: String
    let primaryGenreName: String
    let collectionName: String
    let artworkUrl100: String

    init(collectionName: String, artistName: String, primaryGenreName: String, artworkUrl100: String) {
        self.artistName = artistName
        self.primaryGenreName = primaryGenreName
        self.collectionName = collectionName
        self.artworkUrl100 = artworkUrl100
    }
}
