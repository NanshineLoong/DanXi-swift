//
//  Settings.swift
//  DanXi-native
//
//  Created by Kavin Zhao on 2021/6/26.
//

import SwiftUI

struct SettingsPage: View {
    var body: some View {
        Form {
            Section {
                Button("logout") {
                    
                }
            }
        }
        .navigationBarTitle(Text("Settings"))
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage()
    }
}
