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
    @State private var tasks: [MaintenanceTask] = [
        MaintenanceTask(_id: "1", carId: "1", task: "Oil Change", dueDate: "2024-12-31", nextMileage: 15000, status: "Pending"),
        MaintenanceTask(_id: "2", carId: "1", task: "Brake Change", dueDate: nil, nextMileage: 20000, status: "Completed")
    ]
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isPresentingAddTask = false // Controls the add task sheet

    var body: some View {
            NavigationView {
                VStack(spacing: 16) {
                    // Car Details Section
                    carDetailsSection
                    
                    // Tasks Section
                    if isLoading {
                        ProgressView("Loading...")
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else if tasks.isEmpty {
                        Text("No maintenance tasks are currently due.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                    ForEach(tasks) { task in
                                        MaintenanceTaskView(
                                            task: task,
                                            onComplete: completeTask,
                                            onUpdate: { task, newMileage in
                                            updateTask(task: task, newMileage: newMileage)
                                                    }
                                                )
                                            }
                                        }
                                    .padding(.horizontal)
                            }
                    }
                    
                    // Add Task Button at the Bottom
                    Button(action: { isPresentingAddTask.toggle() }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add New Task")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
                .navigationTitle("Maintenance")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // "+" Button in Navigation Bar
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { isPresentingAddTask.toggle() }) {
                            Image(systemName: "plus")
                                .font(.title2)
                        }
                    }
                }
                .sheet(isPresented: $isPresentingAddTask) {
                    AddTaskView(carId: car.id, onTaskAdded: fetchMaintenanceTasks)
                }
                .onAppear(perform: fetchMaintenanceTasks)
            }
        }
        
        // Car Details Section
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
                    Text(car.carModel).font(.title2).fontWeight(.bold)
                    Text("Year: \(car.year)").foregroundColor(.gray)
                    Text("Mileage: \(car.mileage) km").foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 4)
        }

    // Fetch maintenance tasks
    private func fetchMaintenanceTasks() {
           NetworkService.shared.fetchMaintenancePredictions(for: car.id) { result in
               DispatchQueue.main.async {
                   switch result {
                   case .success(let fetchedTasks):
                       // Debug log for fetched tasks
                       print("Fetched Tasks: \(fetchedTasks)")

                       // Remove duplicates and update the `tasks` state
                       self.tasks = fetchedTasks.uniqued()

                       // Debug log for updated tasks
                       print("Updated Tasks: \(self.tasks)")

                       // Stop the loading indicator
                       self.isLoading = false

                       // Optional: Schedule notifications for pending tasks
                       for task in self.tasks where task.status == "Pending" {
                           scheduleMaintenanceNotification(task: task)
                       }
                   case .failure(let error):
                       // Handle failure cases and update UI accordingly
                       switch error {
                       case let NetworkService.NetworkError.rawData(rawResponse):
                           print("Raw Response Data: \(rawResponse)")
                           self.errorMessage = "Decoding Error: Unable to read data."
                       case let NetworkService.NetworkError.serverError(message):
                           self.errorMessage = message
                       case NetworkService.NetworkError.noData:
                           self.errorMessage = "No data received from the server."
                       default:
                           self.errorMessage = "An unknown error occurred."
                       }
                       self.isLoading = false
                   }
               }
           }
       }

    // Complete a task
    func completeTask(taskId: String) {
        print("Completing task with ID: \(taskId)")
        NetworkService.shared.completeTask(taskId: taskId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedTask):
                    print("Task completed: \(updatedTask)")
                    fetchMaintenanceTasks() // Reload tasks after completion
                case .failure(let error):
                    print("Error completing task: \(error.localizedDescription)")
                }
            }
        }
    }
    private func updateTask(task: MaintenanceTask, newMileage: Int) {
        print("Updating task \(task._id ?? "") with new mileage: \(newMileage)")

        NetworkService.shared.updateTaskMileage(task: task, newMileage: newMileage) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Update the task in the `tasks` array
                    if let index = tasks.firstIndex(where: { $0._id == task._id }) {
                        tasks[index].nextMileage = newMileage + 10000 // Example logic
                        tasks[index].dueDate = nil // Clear due date if it's mileage-based
                    }
                    print("Task updated successfully")
                case .failure(let error):
                    print("Error updating task:", error.localizedDescription)
                }
            }
        }
    }
}

struct MaintenanceTaskView: View {
    let task: MaintenanceTask
    let onComplete: (String) -> Void
    let onUpdate: (MaintenanceTask, Int) -> Void // Pass the task and new mileage
    @State private var isCompleting = false
    @State private var isUpdating = false

    var body: some View {
        HStack {
            Image(systemName: task.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundColor(task.status == "OVERDUE" ? .red : .gray)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.task)
                    .font(.headline)
                if let nextMileage = task.nextMileage {
                    Text("Next: \(nextMileage) km")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else if let dueDate = task.dueDate {
                    Text("Due: \(dueDate)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    Text("No Due Information")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            VStack(spacing: 8) {
                // Complete Button
                if task.status == "Pending" {
                    if isCompleting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                            .frame(width: 24, height: 24)
                    } else {
                        Button(action: {
                            guard let taskId = task._id else {
                                print("Invalid task ID")
                                return
                            }
                            isCompleting = true
                            onComplete(taskId)
                        }) {
                            Text("Complete")
                                .font(.caption)
                                .padding(8)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }
                } else {
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                // Update Button
                Button(action: {
                    isUpdating = true
                }) {
                    Text("Update")
                        .font(.caption)
                        .padding(8)
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                .sheet(isPresented: $isUpdating) {
                    UpdateMileageView(taskId: task._id ?? "") { newMileage in
                        onUpdate(task, newMileage) // Pass the task and new mileage
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

struct UpdateMileageView: View {
    let taskId: String
    let onUpdate: (Int) -> Void // Change closure type to directly pass an `Int`
    @State private var newMileage: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Update Mileage")
                    .font(.headline)
                    .padding()

                TextField("Enter New Mileage", text: $newMileage)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(5)

                    Button("Update") {
                        guard let mileage = Int(newMileage), mileage > 0 else {
                            print("Invalid mileage")
                            return
                        }
                        onUpdate(mileage) // Pass the new mileage to the closure
                        dismiss() // Automatically dismiss the pop-up
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                }
                .padding()
            }
            .navigationTitle("Update Task")
        }
    }
}
func scheduleMaintenanceNotification(task: MaintenanceTask) {
    let content = UNMutableNotificationContent()
    content.title = "Upcoming Maintenance Task"
    content.body = "Your \(task.task) is due soon. Check the app for details."
    content.sound = .default

    var trigger: UNNotificationTrigger?

    if let dueDate = task.dueDate, let date = ISO8601DateFormatter().date(from: dueDate) {
        let calendarTriggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        trigger = UNCalendarNotificationTrigger(dateMatching: calendarTriggerDate, repeats: false)
    } else if let nextMileage = task.nextMileage {
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false) // Placeholder
        content.body = "Your \(task.task) is due at \(nextMileage) km."
    } else {
        trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        content.body = "Your \(task.task) is pending but lacks due information."
    }

    guard let validTrigger = trigger else {
        print("Error: Failed to create notification trigger for \(task.task).")
        return
    }

    let request = UNNotificationRequest(
        identifier: task.id,
        content: content,
        trigger: validTrigger
    )

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error scheduling notification for \(task.task):", error.localizedDescription)
        } else {
            print("Notification scheduled for \(task.task).")
        }
    }
}
struct AddTaskView: View {
    let carId: String
    var onTaskAdded: () -> Void
    
    @State private var taskName = ""
    @State private var dueDate = Date()
    @State private var nextMileage: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Name", text: $taskName)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    TextField("Next Mileage (Optional)", text: $nextMileage)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTask() }
                }
            }
        }
    }
    
    private func saveTask() {
        guard !taskName.isEmpty else {
            print("Error: Task name is empty.")
            return
        }

        let nextMileageValue = Int(nextMileage) ?? nil
        let dateFormatter = ISO8601DateFormatter()
        let formattedDueDate = dateFormatter.string(from: dueDate)

        let taskData: [String: Any] = [
            "carId": carId,
            "task": taskName,
            "dueDate": formattedDueDate,
            "nextMileage": nextMileageValue ?? NSNull(),
            "status": "Pending"
        ]

        NetworkService.shared.addTask(for: carId, taskData: taskData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    onTaskAdded()
                    dismiss()
                case .failure(let error):
                    print("Error adding task:", error.localizedDescription)
                }
            }
        }
    }
}
