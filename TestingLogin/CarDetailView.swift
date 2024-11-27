//
//  CarDetailView.swift
//  TestingLogin
//
//  Created by Becha Med Amine on 27/11/2024.
//

import SwiftUI

struct CarDetailView: View {
    let car: Car

    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                Text(car.carModel)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
                    .padding(.bottom, 10)
            }
            VStack(spacing: 30) {
                // Display the car image with a gradient overlay
                ZStack {
                    if let imageUrl = car.imageUrl?.replacingOccurrences(of: "localhost", with: "127.0.0.1"),
                       let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(20)
                                    .overlay(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.black.opacity(0.6), .clear]),
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                            } else if phase.error != nil {
                                Image(systemName: "car.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .foregroundColor(.gray)
                            } else {
                                ProgressView()
                                    .frame(height: 200)
                            }
                        }
                    } else {
                        Image(systemName: "car.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(.gray)
                    }

                    // Car Model Overlay
                   
                }

                // Car details section with a colorful card style
                VStack(spacing: 12) {
                    DetailRow(title: "Make", value: car.make, color: .blue)
                    DetailRow(title: "Year", value: "\(car.year)", color: .green)
                    DetailRow(title: "Mileage", value: "\(car.mileage) km", color: .purple)
                }
                .padding()
                .background(LinearGradient(
                    gradient: Gradient(colors: [.white, Color.gray.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .cornerRadius(15)
                .shadow(radius: 10)
            }
            .padding()
        }
        .navigationTitle("Car Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(color)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct CarDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CarDetailView(car: Car(
            id: "1",
            make: "Hyundai",
            carModel: "i10",
            year: 2014,
            mileage: 75000,
            owner: "User1",
            imageUrl: "https://via.placeholder.com/300"
        ))
    }
}
