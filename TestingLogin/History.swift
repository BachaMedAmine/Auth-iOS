//
//  History.swift
//  TestingLogin
//
//  Created by Meriem Abid on 19/11/2024.
//

import SwiftUI

struct History: View {
    @State private var selectedServices: [String: Bool] = [
            "Car Painting": false,
            "Alloy Wheel": false,
            "Car Polishing": false,
            "Car Tinkering": false,
            "Windshield Glass": false,
            "Other Services": false,
            "Seat Cover": false,
            "Car Alterations": false
        ]
        
    let columns = [
            GridItem(.flexible(), spacing: 16, alignment: .leading),
            GridItem(.flexible(), spacing: 16, alignment: .leading)
        ]
        
        var body: some View {
            NavigationView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Service Details")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color.primary) // S'adapte au mode clair/sombre
                        .padding(.horizontal)
                    
                    // Conteneur avec styles compatibles Light/Dark mode
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground)) // Arrière-plan adaptatif
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(selectedServices.keys.sorted(), id: \.self) { service in
                                HStack {
                                    Button(action: {
                                        selectedServices[service]?.toggle()
                                    }) {
                                        Image(systemName: selectedServices[service] == true ? "checkmark.square.fill" : "square")
                                            .foregroundColor(Color.green) // Couleur verte pour les cases cochées
                                    }
                                    
                                    Text(service)
                                        .font(.body)
                                        .foregroundColor(Color.secondary) // Texte adaptatif
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
                .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)) // Fond adaptatif
                .navigationTitle("History")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            print("Settings tapped")
                        }) {
                            Image(systemName: "gearshape")
                                .foregroundColor(Color.primary)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            print("Notifications tapped")
                        }) {
                            Image(systemName: "bell")
                                .foregroundColor(Color.primary)
                        }
                    }
                }
            }
        }
    }



#Preview {
    History()
}
