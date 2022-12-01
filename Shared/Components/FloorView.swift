import SwiftUI

struct FloorView: View {
    @State var floor: THFloor
    var isPoster: Bool
    let interactable: Bool
    
    @State var showReplyPage = false
    @State var showEditPage = false
    @State var showErrorAlert = false
    @State var errorTitle: LocalizedStringKey = ""
    @State var errorInfo = ""
    @State var showDeleteAlert = false
    @State var showRemoveSheet = false
    @State var showReportSheet = false
    @State var showHistorySheet = false
    @State var showSelectionSheet = false
    
    @ObservedObject var holeViewModel: HoleDetailViewModel
    var proxy: ScrollViewProxy? = nil
    
    @State var mentionNavigationActive = false
    @State var mentionFloorId = 0
    
    init(floor: THFloor, interactable: Bool = true) {
        self._floor = State(initialValue: floor)
        isPoster = false
        self.interactable = interactable
        self.holeViewModel = HoleDetailViewModel()
    }
    
    init(floor: THFloor, isPoster: Bool) {
        self._floor = State(initialValue: floor)
        self.isPoster = isPoster
        interactable = true
        self.holeViewModel = HoleDetailViewModel()
    }
    
    init(floor: THFloor,
         isPoster: Bool,
         model: HoleDetailViewModel,
         hideReplyTo: Bool = false,
         proxy: ScrollViewProxy) {
        self._floor = State(initialValue: floor)
        self.isPoster = isPoster
        self.holeViewModel = model
        self.proxy = proxy
        interactable = true
    }
    
    func like() {
        Task {
            do {
                let likeStatus = floor.liked ? 0 : 1
                let newFloor = try await TreeholeRequests.like(floorId: floor.id, like: likeStatus)
                self.floor = newFloor
                haptic()
            } catch {
                errorTitle = "Like Failed"
                showErrorAlert = true
                errorInfo = error.localizedDescription
            }
        }
    }
    
    func delete(reason: String = "") {
        Task {
            do {
                let newFloor = try await TreeholeRequests.deleteFloor(floorId: floor.id, reason: reason)
                self.floor = newFloor
            } catch {
                errorTitle = "Delete Failed"
                showErrorAlert = true
                errorInfo = error.localizedDescription
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .center) {
                HStack {
                    poster
                    if !floor.spetialTag.isEmpty {
                        SpecialTagView(content: floor.spetialTag)
                    }
                    Spacer()
                    if !floor.deleted && interactable {
                        actions
                    }
                    menu
                }
                
                // invisible watermark for screenshot tracing
                if let user = UserStore.shared.user {
                    Text(String(user.id))
                        .foregroundColor(.gray.opacity(0.01))
                }
            }
            bodyText
            info
        }
        .sheet(isPresented: $showReplyPage) {
            ReplyForm(
                holeId: floor.holeId,
                content: "##\(String(floor.id))\n",
                floors: holeViewModel.floors,
                endReached: $holeViewModel.endReached)
        }
        .sheet(isPresented: $showEditPage) {
            EditReplyForm(
                floor: $floor,
                content: floor.content)
        }
        .sheet(isPresented: $showReportSheet) {
            ReportForm(floor: floor)
        }
        .sheet(isPresented: $showRemoveSheet) {
            DeleteForm(floor: $floor)
        }
        .sheet(isPresented: $showHistorySheet, content: {
            HistoryList(floor: $floor)
        })
        .sheet(isPresented: $showSelectionSheet, content: {
            TextSelectionView(text: floor.content)
        })
        .alert("Delete Floor", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                delete()
            }
        } message: {
            Text("This floor will be deleted")
        }
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorInfo)
        }
    }
    
    private var poster: some View {
        HStack {
            if isPoster {
                Text("DZ")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6.0)
                    .background(randomColor(floor.posterName))
                    .cornerRadius(3.0)
            }
            
            Text(floor.posterName)
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .foregroundColor(randomColor(floor.posterName))
        .padding(.leading, 10)
        .overlay(
            Rectangle()
                .frame(width: 3, height: nil, alignment: .leading)
                .foregroundColor(randomColor(floor.posterName))
                .padding(.vertical, 1), alignment: .leading)
        
    }
    
    @ViewBuilder
    private var bodyText: some View {
        if floor.deleted {
            Text(floor.content)
                .foregroundColor(.secondary)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            ReferenceView(bodyContent,
                          proxy: proxy,
                          mentions: floor.mention,
                          floors: mentionSearchContext)
            .foregroundColor(.primary)
            .multilineTextAlignment(.leading)
        }
    }
    
    private var bodyContent: String {
        switch holeViewModel.filterOption {
        case .conversation(_):
            return floor.removeFirstMention()
        default:
            return floor.content
        }
    }
    
    private var mentionSearchContext: [THFloor] {
        if holeViewModel.floors.isEmpty, let hole = holeViewModel.hole {
            return hole.floors
        } else {
            return holeViewModel.floors
        }
    }
    
    private var info: some View {
        HStack {
            Text("\(String(floor.storey))F")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            Text("(##\(String(floor.id)))")
                .font(.caption2)
            
            Spacer()
            
            if floor.deleted {
                Text("Deleted")
            }
            
            Spacer()
            
            Text(floor.createTime.formatted(.relative(presentation: .named, unitsStyle: .wide)))
        }
        .font(.caption)
        .foregroundColor(Color.secondary.opacity(0.7))
        .padding(.top, 2.0)
    }
    
    private var actions: some View {
        HStack(alignment: .center, spacing: 20) {
            Button(action: like) {
                HStack(alignment: .center, spacing: 3) {
                    Image(systemName: floor.liked ? "heart.fill" : "heart")
                    Text(String(floor.like))
                }
                .foregroundColor(floor.liked ? .pink : .secondary)
            }
            
            Button {
                showReplyPage = true
            } label: {
                Image(systemName: "arrowshape.turn.up.left")
            }
        }
        .buttonStyle(.borderless) // prevent multiple tapping
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.trailing, 10)
    }
    
    @ViewBuilder
    private var menu: some View {
        let admin = UserStore.shared.isAdmin
        
        if !floor.deleted {
            Menu {
                menuNormalFunctions
                if admin {
                    Menu {
                        menuAdminFunctions
                    } label: {
                        Label("Admin Actions", systemImage: "person.badge.key")
                    }
                }
            } label: {
                menuLabel
            }
        } else if admin {
            Menu {
                menuAdminFunctions
            } label: {
                menuLabel
            }
        } else {
            menuLabel
                .opacity(0)
        }
    }
    
    private var menuLabel: some View {
        Image(systemName: "ellipsis.circle.fill")
            .symbolRenderingMode(.hierarchical)
            .imageScale(.large)
            .font(.body)
            .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    private var menuNormalFunctions: some View {
        Button {
            showReportSheet = true
        } label: {
            Label("Report", systemImage: "exclamationmark.triangle")
        }
        
        Button {
            showSelectionSheet = true
        } label: {
            Label("Select Text", systemImage: "selection.pin.in.out")
        }
        
        Button {
            holeViewModel.filterOption = .user(name: floor.posterName)
        } label: {
            Label("Show This Person", systemImage: "message")
        }
        
        Button {
            holeViewModel.filterOption = .conversation(starting: floor.id)
        } label: {
            Label("View Conversation", systemImage: "bubble.left.and.bubble.right")
        }
        
        if floor.isMe {
            Divider()
            
            Button {
                showEditPage = true
            } label: {
                Label("Edit Reply", systemImage: "square.and.pencil")
            }
            
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    @ViewBuilder
    private var menuAdminFunctions: some View {
        Button {
            showEditPage = true
        } label: {
            Label("Modify Floor", systemImage: "pencil")
        }
        
        Button(role: .destructive) {
            showRemoveSheet = true
        } label: {
            Label("Remove Floor", systemImage: "xmark.square")
        }
        
        Button(role: .destructive) {
            // TODO: ban user
        } label: {
            Label("Ban User", systemImage: "person.fill.xmark")
        }
        
        Button {
            showHistorySheet = true
        } label: {
            Label("Show Edit History", systemImage: "clock.arrow.circlepath")
        }
    }
}

struct FloorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FloorView(floor: PreviewDecode.decodeObj(name: "floor")!, isPoster: true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Floor")
            
            FloorView(floor: PreviewDecode.decodeObj(name: "deleted-floor")!)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Deleted Floor")
            
            FloorView(floor: PreviewDecode.decodeObj(name: "long-floor")!)
                .previewDisplayName("Long Floor")
            
            ScrollView {
                FloorView(floor: PreviewDecode.decodeObj(name: "styled-floor")!)
            }
            .previewDisplayName("Styled Floor")
        }
        .padding()
    }
}
