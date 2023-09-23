//
//  SettingView.swift
//  DualDepth
//
//  Created by MacBook Pro M1 on 2021/10/28.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var iconSelection = 0
    private let appIconList = DualDepthAppIcon.allCases
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(
                        destination: IconList(iconList: appIconList,
                        iconSelection: $iconSelection)) {
                            ListRow(key: "App icon", value: appIconList[iconSelection].displayName())
                    }
                    
                }
            }
            .listStyle(InsetGroupedListStyle())
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Done")
                    }

                }
            }
        }
    }
}

// MARK: -
struct IconList: View {
    var iconList: [DualDepthAppIcon]
    @Binding var iconSelection: Int
    
    var body: some View {
        List {
            ForEach(0..<iconList.count) { index in
                HStack {
                    Image(iconList[index].iconName())
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text(iconList[index].displayName())
                    if index == iconSelection {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                    .onTapGesture {
                        iconSelection = index
                        var iconName: String?
                        if index > 0 {
                            iconName = iconList[index].rawValue
                        } else {
                            iconName = nil
                        }
                        
                        UIApplication.shared.setAlternateIconName(iconName)
                    }
            }
        }
    }
}

// MARK: -
struct ListRow: View {
    var key: String
    var value: String
    
    var body: some View {
        HStack {
            Text(key)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview
struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
