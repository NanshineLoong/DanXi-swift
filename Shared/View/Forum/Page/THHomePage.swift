import SwiftUI

struct THHomePage: View {
    @ObservedObject private var appModel = THModel.shared
    @StateObject private var model = THNavigationModel()
    
    var body: some View {
        NavigationStack(path: $model.path) {
            AsyncContentView(finished: appModel.loaded) {
                try await appModel.loadAll()
                try await DXModel.shared.loadUser()
            } content: {
                Group {
                    switch model.page {
                    case .browse:
                        THBrowseWrapper()
                    case .favorite:
                        THFavoritesPage()
                    case .mypost:
                        THMyPostPage()
                    case .tags:
                        THTagsPage()
                    case .report:
                        THReportPage()
                    case .notifications:
                        THNotificationPage()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        menu
                    }
                }
                .navigationDestination(for: THHole.self) { hole in
                    THHolePage(hole)
                        .environmentObject(model) // prevent crash on NavigationSplitView, reason unknown
                }
                .navigationDestination(for: THHoleLoader.self) { loader in
                    THLoaderPage(loader)
                        .environmentObject(model) // prevent crash on NavigationSplitView, reason unknown
                }
                .navigationDestination(for: THTag.self) { tag in
                    THSearchTagPage(tagname: tag.name)
                        .environmentObject(model) // prevent crash on NavigationSplitView, reason unknown
                }
            }
        }
        .environmentObject(model)
        .onOpenURL { url in
            model.openURL(url)
        }
    }
    
    private var menu: some View {
        Menu {
            Picker("Page Selection", selection: $model.page) {
                Label("Tree Hole", systemImage: "doc.plaintext")
                    .tag(THPage.browse)
                Label("Favorites", systemImage: "star")
                    .tag(THPage.favorite)
                Label("My Post", systemImage: "person")
                    .tag(THPage.mypost)
                Label("All Tags", systemImage: "tag")
                    .tag(THPage.tags)
                Label("Notifications", systemImage: "bell")
                    .tag(THPage.notifications)
                if DXModel.shared.isAdmin {
                    Label("Report", systemImage: "exclamationmark.triangle")
                        .tag(THPage.report)
                }
            }
        } label: {
            Image(systemName: "rectangle.stack")
        }
    }
}
