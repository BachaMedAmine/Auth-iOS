//
//  CarDetailView.swift
//  TestingLogin
//
//  Created by Becha Med Amine on 27/11/2024.
//

import SwiftUI

struct CarDetailView: View {
    let car: Car
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ScrollView {
            
            VStack(spacing: 30) {
                
                

                // Car details section with a colorful card style
                LazyVStack(alignment: .center, spacing: 15) {
                    
                    ZStack {
                        if let imageUrl = car.imageUrl?.replacingOccurrences(of: "localhost", with: "127.0.0.1"),
                           let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 340, height: 180)
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
                        
                    }
                    
                    HStack{
                        
                        
                        // Make
                        HStack {
                            Image(systemName: "bolt.car")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(car.make)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        HStack {
                            Image(systemName: "calendar")
                            .foregroundColor(.gray)
                           
                            Spacer()
                            Text("\(car.year)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }

                    HStack {
                        Image(systemName: "car.fill")
                            .foregroundColor(.gray)
                        Spacer()
                        Text(car.carModel)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                                    // Year
                                    
                                
                    HStack{
                        // Mileage
                        HStack {
                            Image(systemName: "gauge.open.with.lines.needle.67percent.and.arrowtriangle.and.car")
                                .foregroundColor(.gray)
                            
                            Spacer()
                            Text("\(car.mileage) km")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        
                        // Engine
                        HStack {
                            Image(systemName: "camera.filters")
                                .foregroundColor(.gray)
                            
                            Spacer()
                            Text(car.engine ?? "Unknown")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        
                    }
                                   
                                }
                                .padding(.horizontal)
                            }
                        }
        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))// Change la couleur ici
                                        Text("Back")
                                            .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255)) // Change la couleur ici
                                        
                                        Spacer().frame(width:90)
                                        Text("Car Details")
                                            .font(.headline)
                                      
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                    .navigationBarBackButtonHidden(true)
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
            imageUrl: "https://via.placeholder.com/300",
            engine: "1.0"
        ))
    }
}
