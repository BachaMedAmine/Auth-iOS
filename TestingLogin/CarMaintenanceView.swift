//
//  CarMaintenanceView.swift
//  TestingLogin
//
//  Created by Becha Med Amine on 22/11/2024.
//

import Foundation
import SwiftUI

struct CarMaintenanceView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text("Car Maintenance")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Upcoming Maintenance Section
                    SectionView(title: "Upcoming Maintenance") {
                        MaintenanceCard(
                            title: "Oil Change",
                            date: "Nov 25, 2024",
                            car: "Toyota Land Cruiser",
                            icon: "drop.fill"
                        )
                        MaintenanceCard(
                            title: "Tire Rotation",
                            date: "Dec 5, 2024",
                            car: "Volkswagen Polo",
                            icon: "arrow.triangle.2.circlepath"
                        )
                    }
                    
                    // Recent Services Section
                    SectionView(title: "Recent Services") {
                        MaintenanceCard(
                            title: "Brake Pad Replacement",
                            date: "Nov 10, 2024",
                            car: "Hyundai i10",
                            icon: "wrench.fill"
                        )
                    }
                    
                    // Service History Section
                    SectionView(title: "Service History") {
                        MaintenanceCard(
                            title: "Battery Check",
                            date: "Oct 1, 2024",
                            car: "Toyota Land Cruiser",
                            icon: "bolt.fill"
                        )
                        MaintenanceCard(
                            title: "AC Repair",
                            date: "Sep 15, 2024",
                            car: "Volkswagen Polo",
                            icon: "thermometer"
                        )
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            VStack(spacing: 10) {
                content
            }
            .padding(.horizontal)
        }
    }
}

struct MaintenanceCard: View {
    let title: String
    let date: String
    let car: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(Color.blue)
                .frame(width: 50, height: 50)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                Text("Car: \(car)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Due: \(date)")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CarMaintenanceView_Previews: PreviewProvider {
    static var previews: some View {
        CarMaintenanceView()
    }
}
