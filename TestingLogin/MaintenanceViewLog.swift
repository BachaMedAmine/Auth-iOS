//
//  MaintenanceViewLog.swift
//  TestingLogin
//
//  Created by Becha Med Amine on 4/1/2025.
//

import Foundation
import SwiftUI

struct MaintenanceViewLog: View {
    let car: Car
    @State private var completedTasks: [MaintenanceTask] = [] // Completed tasks
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            // Car Header Section
            carDetailsSection

            // Completed Tasks Section
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else if completedTasks.isEmpty {
                Text("No completed tasks found.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(completedTasks) { task in
                            MaintenanceTaskLogView(task: task)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Maintenance Log")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchCompletedTasks()
        }
    }

    private var carDetailsSection: some View {
        HStack {
            AsyncImage(url: URL(string: car.imageUrl ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Image(systemName: "car.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 100, height: 100)
            .cornerRadius(8)

            VStack(alignment: .leading) {
                Text(car.carModel)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Year: \(car.year)")
                    .foregroundColor(.gray)
                Text("Mileage: \(car.mileage) km")
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
    }

    private func fetchCompletedTasks() {
        NetworkService.shared.fetchCompletedTasks(for: car.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tasks):
                    self.completedTasks = tasks
                case .failure(let error):
                    self.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }
    }
}

struct MaintenanceTaskLogView: View {
    let task: MaintenanceTask

    var body: some View {
        HStack {
            Image(systemName: task.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundColor(.gray)

            VStack(alignment: .leading) {
                Text(task.task)
                    .font(.headline)
                if let completedDate = task.completedDate {
                    Text("Completed on: \(task.formattedCompletedDate)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("Completion date unavailable")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}
