import SwiftUI

struct TreeHoleCard: View {
    
    let floor: OTFloor
    let tagList: [OTTag]?
    
    init(floor: OTFloor, tagList: [OTTag]? = nil) {
        self.floor = floor
        self.tagList = tagList
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let tagList = tagList {
                TagList(tags: tagList)
            }
            poster
            Text(floor.content)
                //.font(.system(size: 12))
            
            info
            Divider()
            actions
        }
        .padding()
#if !os(watchOS)
        .background(Color(UIColor.systemGray6))
#endif
        .cornerRadius(13)
        .padding(.horizontal)
        .padding(.vertical, 5.0)
    }
    
    private var poster: some View {
        HStack {
            Rectangle()
                .frame(width: 3, height: 15)
            Text(floor.anonyname)
                .font(.system(size: 15))
                .fontWeight(.bold)
        }
        .foregroundColor(.red)
    }
    
    private var info: some View {
        HStack {
            Text("\(floor.storey + 1)F")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            Text("(##\(String(floor.floor_id)))")
                .font(.caption2)
                .foregroundColor(.gray)
            
            Spacer()
            Text(floor.timeCreated?.formatted(date: .abbreviated, time: .shortened) ?? "")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.top, 2.0)
    }
    
    private var actions: some View {
        HStack {
            Spacer()
            Label("点赞 (\(floor.like))", systemImage: floor.liked ?? false ? "heart.fill" : "heart" )
                .foregroundColor(floor.liked ?? false ? .pink : .secondary)
            
            Spacer()
            Label("举报", systemImage: "exclamationmark.circle")
            Spacer()
        }
        .font(.caption2)
        .foregroundColor(.secondary)
    }
}

struct TreeHoleCard_Previews: PreviewProvider {
    static let testFloor = OTFloor(
        floor_id: 1234567,
        hole_id: 123456,
        like: 12,
        storey: 5,
        content: """
        Hello, **SwiftLee** readers!
        
        We can make text *italic*, ***bold italic***, or ~~striked through~~.
        
        You can even create [links](https://www.twitter.com/twannl) that actually work.
        
        Or use `Monospace` to mimic `Text("inline code")`.
        
        """,
        anonyname: "Dax",
        time_updated: "",
        time_created: "2022-04-14T08:23:12.761042+08:00",
        deleted: false,
        is_me: false,
        liked: true,
        fold: [])
    
    static let tagObj = OTTag(name: "树洞", tag_id: 1, temperature: 0)
    
    static let tagList = Array(repeating: tagObj, count: 5)
    
    static var previews: some View {
        Group {
            TreeHoleCard(floor: testFloor)
            TreeHoleCard(floor: testFloor, tagList: tagList)
            TreeHoleCard(floor: testFloor)
                .preferredColorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
    }
}
