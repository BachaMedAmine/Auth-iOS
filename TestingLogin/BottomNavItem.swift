//
//  BottomNavItem.swift
//  TestingLogin
//
//  Created by Meriem Abid on 19/11/2024.
//

import SwiftUI


struct BottomNavItem: View {
    @Binding var selectedTab: TabBarItems
    var body: some View {
        HStack(spacing: 20) {
          
            ForEach(TabBarItems.allCases, id:\.self) {tab in
                Button(action:{
                    withAnimation {
                        selectedTab = tab
                    }
                }) {
                    HStack{
                        Spacer()
                        VStack {
                            Spacer()
                            tabIconFor(tab)
                            if tab != .pluslogo {
                                Text(tab.title)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.4)
                            }
                            Spacer()
                        }
                    
                    }
                }.buttonStyle(.plain)
            }
        
        }
        .background(Color.white)
    }
    @ViewBuilder
    private func tabIconFor(_ tab: TabBarItems) -> some View {
        if tab == .pluslogo {
            Image(tab.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44, alignment: .center)
        } else {
            if tab == selectedTab {
                Image(systemName: tab.selectedIcon)
            } else {
                Image(systemName: tab.icon)
            }
        }
    }
}
