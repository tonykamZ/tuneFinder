import SwiftUI

// for Media type entities param

enum Entity: String {
    case song
    case album
    case musicArtist
}

func getEntityString(_ entities: Set<Entity>) -> String {
    if(entities.isEmpty){
        return "song,album,musicArtist"
    }
    let entityNames = entities.map { $0.rawValue }
    return entityNames.joined(separator: ",")
}

func getEntityStringForDisplay(_ entities: Set<Entity>) -> String {
    if entities.isEmpty {
        return "song, album, and artist"
    }

    let entityNames = entities.map { $0 == .musicArtist ? "artist" : $0.rawValue }
    
    if entityNames.count == 1 {
        return entityNames[0]
    } else if entityNames.count == 2 {
        return "\(entityNames[0]) and \(entityNames[1])"
    } else {
        let lastEntityName = entityNames.last!
        let joinedNames = entityNames.dropLast().joined(separator: ", ")
        return "\(joinedNames), and \(lastEntityName)"
    }
}

struct EntitySelectionButton: View {
    let entity: Entity
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        Button(action: {
            viewModel.toggleEntitySelection(entity)
        }) {
            Text(entity == .musicArtist ? "artist" : entity.rawValue)
                .font(.subheadline)
                .padding(8)
                .foregroundColor(viewModel.isEntitySelected(entity) ? .white : .gray)
                .background(viewModel.isEntitySelected(entity) ? Color(red: 0.2, green: 0.4, blue: 0.6) : Color(UIColor.systemBackground))
                .cornerRadius(8)
        }
        .padding(.trailing, 6)
    }
}

