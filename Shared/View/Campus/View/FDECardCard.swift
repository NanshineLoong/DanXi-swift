import SwiftUI

struct FDECardCard: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                        Text("ECard")
                        Spacer()
                    }
                    .bold()
                    .font(.callout)
                    .foregroundColor(.danxiDeepOrange)
                    
                    Spacer()
                    
                    Text("Balance")
                        .foregroundColor(.danxiGrey)
                        .bold()
                        .font(.subheadline)
                    
                    Text("25.00")
                        .bold()
                        .font(.title2)
                        .foregroundColor(.primary)
                    + Text(" yuan")
                        .bold()
                        .font(.subheadline)
                        .foregroundColor(.danxiGrey)
                    
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Spacer()
                    
                    ForEach(1..<2) { _ in
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                            Text("食堂 10.00")
                        }
                        .bold()
                        .font(.footnote)
                        .foregroundColor(.danxiDeepOrange)
                    }
                }
            }
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
                .bold()
                .font(.footnote)
        }
    }
}

#Preview {
    List {
        FDECardCard()
            .frame(height: 85)
    }
}
