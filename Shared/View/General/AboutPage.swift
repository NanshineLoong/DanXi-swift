import SwiftUI
import CryptoKit

struct AboutPage: View {
    @AppStorage("debug-unlocked") private var debugUnlocked = false
    @State private var tappedCount = 0
    
    private var version: String {
        Bundle.main.releaseVersionNumber ?? ""
    }
    
    private var build: String {
        Bundle.main.buildVersionNumber ?? ""
    }
    
    private func checkPassword() {
        if UIPasteboard.general.hasStrings {
            if let password = UIPasteboard.general.string {
                let hash = SHA256.hash(data: password.data(using: .utf8)!)
                let hashString = hash.map { String(format: "%02hhx", $0) }.joined()
                if hashString == "2a71f797c0c5b266e885fb8f9a137936aba75e9a9d9e9fca747f965452b35463" {
                    withAnimation {
                        debugUnlocked = true
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                List {
                    Section {
                        LinkView(url: "https://danxi.fduhole.com", text: "Website", icon: "safari")
                        LinkView(url: "https://danxi.fduhole.com/doc/app-terms-and-condition", text: "Terms and Conditions", icon: "info.circle")
                        LinkView(url: "https://apps.apple.com/app/id1568629997?action=write-review", text: "Write a Review", icon: "star")
                        
                        NavigationLink {
                            CreditPage()
                        } label: {
                            Label("Acknowledgements", systemImage: "heart")
                        }
                    } header: {
                        appIcon
                            .textCase(.none)
                            .onTapGesture {
                                tappedCount += 1
                                if tappedCount > 5 && !debugUnlocked {
                                    checkPassword()
                                }
                            }
                    }
                    
                    if debugUnlocked {
                        Section {
                            NavigationLink {
                                DebugPage()
                            } label: {
                                Label("Debug", systemImage: "ant.circle.fill")
                            }
                        }
                    }
                }
            }
            
            
            VStack {
                Text("Copyright © 2024 DanXi-Dev")
                Text("沪ICP备2021032046号-4A")
                    .onPress {
                        let url = URL(string: "https://beian.miit.gov.cn/")!
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:])
                        }
                    }
            }
            .foregroundStyle(.secondary)
            .font(.footnote)
            .padding()
        }
        .labelStyle(.titleOnly)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .background(.systemGroupedBackground)
    }
    
    private var appIcon: some View {
        HStack {
            Spacer()
            VStack {
                Image("Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                Text("DanXi")
                    .font(.title)
                    .bold()
                Text("Version \(version) (\(build))")
                    .font(.callout)
            }
            .padding(.bottom)
            Spacer()
        }
    }
}
