//
//  MaintenanceView.swift
//  TestingLogin
//
//  Created by Becha Med Amine on 29/11/2024.
//

import Foundation
import SwiftUI

struct MaintenanceView: View {
    let car: Car
    @State private var tasks: [MaintenanceTask] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            // Car Details Section
            VStack {
                HStack {
                    if let imageUrl = car.imageUrl?.replacingOccurrences(of: "localhost", with: "127.0.0.1"),
                       let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                            } else {
                                Image(systemName: "car.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        Image(systemName: "car.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(car.carModel)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("\(car.year)")
                            .foregroundColor(.gray)
                        Text("Mileage: \(car.mileage) km")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }

                    Spacer()
                }
                .padding()
            }
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)

            // Tasks Section
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(tasks) { task in
                            MaintenanceTaskView(task: task)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .onAppear(perform: fetchMaintenanceTasks)
    }

    private func fetchMaintenanceTasks() {
        NetworkService.shared.fetchMaintenancePredictions(for: car.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedTasks):
                    print("Fetched Tasks: \(fetchedTasks)") // Debug log
                    self.tasks = fetchedTasks
                    self.isLoading = false
                case .failure(let error):
                    print("Error: \(error.localizedDescription)") // Debug log
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct MaintenanceTaskView: View {
    let task: MaintenanceTask

    var body: some View {
        HStack {
            // Task Icon
            Image(systemName: task.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(task.status == "OVERDUE" ? .red : .gray)

            VStack(alignment: .leading, spacing: 4) {
                // Last Maintenance Info
                if task.lastMileage != "Unknown" {
                    Text("Last: \(task.lastMileage)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("Last: Unknown")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // Next Maintenance Info
                if task.nextMileage != "0" {
                    Text("Next: \(task.nextMileage) km")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("Next: Unknown")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            // Status (e.g., "Pending", "OVERDUE")
            Text(task.status)
                .fontWeight(.bold)
                .foregroundColor(task.status == "OVERDUE" ? .red : .green)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}
