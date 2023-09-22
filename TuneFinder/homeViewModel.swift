import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var searchResults: [iTuneFilterApiResponse] = []
    @Published var searchText: String = ""
    @Published var selectedEntities: Set<Entity> = []
    @Published var selectedCountry: String = ""
    @Published var isLoading: Bool = false
    @Published var isSearchedEmpty: Bool = false
    @Published var currentSearchedEntities: String = ""
    @Published var currentSearchedEntitiesText: Text
    @Published var currentSearchedKeyword: String = ""
    
    init() {
        currentSearchedEntitiesText = Text("")
      }

    func performSearch() {
        let searchTerm = searchText.replacingOccurrences(of: " ", with: "+")
        let entityQuery = getEntityString(selectedEntities)
        
        isLoading = true
        
        var fetchedResults: [iTuneFilterApiResponse] = []
        
        func processResults() {
            DispatchQueue.main.async {
                self.searchResults = fetchedResults
                self.isLoading = false
                self.isSearchedEmpty = self.searchResults.isEmpty
                self.currentSearchedEntities = getEntityStringForDisplay(self.selectedEntities)
                self.currentSearchedEntitiesText = getEntityText(self.selectedEntities)
                self.currentSearchedKeyword = self.searchText
            }
        }
        
        func fetchResults() {
            let apiUrl = "https://itunes.apple.com/search?term=\(searchTerm)&entity=\(entityQuery)&limit=9999&country=\(selectedCountry)"
            
            print("apiUrl -> \(apiUrl)")
            guard let url = URL(string: apiUrl) else {
                print("Invalid URL")
                processResults()
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    print("No data received")
                    processResults()
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let results = json["results"] as? [[String: Any]] {
                                                
                        let searchResults = results.compactMap { resultDict in
                            if let artistName = resultDict["artistName"] as? String,
                               let collectionName = resultDict["collectionName"] as? String,
                               let artworkUrl100 = resultDict["artworkUrl100"] as? String,
                               let previewUrl = resultDict["previewUrl"] as? String,
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
                        fetchedResults.append(contentsOf: searchResults)
                        processResults()
                    } else {
                        print("Failed to decode JSON data: Invalid format.")
                        processResults()
                    }
                } catch let error {
                    print("Error decoding JSON data: \(error)")
                    processResults()
                }
            }.resume()
        }
        
        fetchResults()
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
    let collectionId: Int
    let artworkUrl100: String
    let previewUrl: String

    init(collectionId: Int, collectionName: String, artistName: String, primaryGenreName: String, artworkUrl100: String, previewUrl: String) {
        self.artistName = artistName
        self.primaryGenreName = primaryGenreName
        self.collectionName = collectionName
        self.collectionId = collectionId
        self.artworkUrl100 = artworkUrl100
        self.previewUrl = previewUrl
    }
}
