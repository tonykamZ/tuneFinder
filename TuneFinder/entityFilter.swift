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

func getEntityText(_ entities: Set<Entity>) -> Text {
    if entities.isEmpty {
        let allEntityLoc = LocalizedStringKey("allEntity")
        return Text(allEntityLoc)
    }

    let entityNames = entities.map { $0 == .musicArtist ? "artist" : $0.rawValue }
    
    if entityNames.count == 1 {
        let entityLoc = LocalizedStringKey(entityNames[0])
        return Text(entityLoc)
    } else if entityNames.count == 2 {
        let entityLoc1 = LocalizedStringKey(entityNames[0])
        let entityLoc2 = LocalizedStringKey(entityNames[1])
        let and = LocalizedStringKey("and")
        let combined = Text(entityLoc1) + Text(" ")  + Text(and) + Text(" ")  + Text(entityLoc2)
        return combined
    } else {
        let lastEntityName = entityNames.last!
        let lastEntityLoc = LocalizedStringKey(lastEntityName)
        let entityLoc1 = LocalizedStringKey(entityNames[0])
        let entityLoc2 = LocalizedStringKey(entityNames[1])
        let and = LocalizedStringKey("and")

        let combined = Text(entityLoc1) + Text(", ")  + Text(entityLoc2) + Text(" ")  + Text(and) + Text(" ") + Text(lastEntityLoc)
        return combined
    }
}

func getEntityStringForDisplay(_ entities: Set<Entity>) -> String {
    if entities.isEmpty {
        let allEntityLoc = NSLocalizedString("allEntity", comment: "")
        return allEntityLoc
    }

    let entityNames = entities.map { $0 == .musicArtist ? "artist" : $0.rawValue }
    
    if entityNames.count == 1 {
        let entityLoc = NSLocalizedString(entityNames[0], comment: "")
        return entityLoc
    } else if entityNames.count == 2 {
        let entityLoc1 = NSLocalizedString(entityNames[0], comment: "")
        let entityLoc2 = NSLocalizedString(entityNames[1], comment: "")
        let and = NSLocalizedString("and", comment: "")
        return "\(entityLoc1) \(and) \(entityLoc2)"
    } else {
        let lastEntityName = entityNames.last!
        let lastEntityLoc = NSLocalizedString(lastEntityName, comment: "")
        let entityLoc1 = NSLocalizedString(entityNames[0], comment: "")
        let entityLoc2 = NSLocalizedString(entityNames[1], comment: "")
        let and = NSLocalizedString("and", comment: "")

        return "\(entityLoc1), \(entityLoc2), \(and) \(lastEntityLoc)"
    }
}

struct EntitySelectionButton: View {
    let entity: Entity
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        Button(action: {
            viewModel.toggleEntitySelection(entity)
        }) {
            let converted = entity == .musicArtist ? "artist" : entity.rawValue
            let entityLoc = Text(LocalizedStringKey(converted))
            entityLoc.localize()
                .font(.subheadline)
                .padding(8)
                .foregroundColor(viewModel.isEntitySelected(entity) ? .white : .gray)
                .background(viewModel.isEntitySelected(entity) ? Color(red: 0.2, green: 0.4, blue: 0.6) : Color(UIColor.systemBackground))
                .cornerRadius(8)
        }
        .padding(.trailing, 6)
    }
}

