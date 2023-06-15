import SwiftUI

struct THPostSheet: View {
    @ObservedObject private var appModel = THModel.shared
    @State var divisionId: Int
    @AppStorage("post-content") private var content = ""
    @AppStorage("post-tag") private var tags: [String] = []
    
    var body: some View {
        Sheet("New Post") {
            try await THRequests.createHole(
                content: content,
                divisionId: divisionId,
                tags: tags)
            
            // reset stashed draft content after success post
            content = ""
            tags = []
            
            Task { // reload favorites since new post will automatically be favorited
                try await appModel.loadFavoriteIds()
            }
        } content: {
            Section {
                Picker(selection: $divisionId,
                       label: Label("Select Division", systemImage: "rectangle.3.group")) {
                    ForEach(appModel.divisions) { division in
                        Text(division.name)
                            .tag(division.id)
                    }
                }
            }
            
            THTagEditor($tags, maxSize: 5)
            
            THContentEditor(content: $content)
        }
        .completed(!tags.isEmpty && !content.isEmpty)
        .scrollDismissesKeyboard(.immediately)
    }
}
