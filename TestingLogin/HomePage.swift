import SwiftUI




import SwiftUI

struct HomePage: View {
    @ObservedObject var carManager = CarManager.shared

    @State private var cars: [Car] = [] // List of fetched cars
    @State private var isLoading: Bool = true // Loading state
    @State private var errorMessage: String? // Error message
    @State private var selectedTab: TabBarItems = .home // Selected tab
    @State private var navigateToPhotosView = false // State for PhotosView navigation
    @State private var navigateToProfileView = false // State for EditProfile navigation
    @State private var selectedCar: Car? // Holds the selected car for navigation
    @State private var navigateToDetailView = false // State for CarDetailView navigation
    @State private var navigateToUpdateView = false // State for CarUpdateView navigation


    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    if carManager.cars.isEmpty {
                        Text("No cars available. Add a car to get started!")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                // Header
                                HStack {
                                    NavigationLink(destination: PhotosView()) {
                                        Image(systemName: "plus.circle")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                    }

                                    Spacer()

                                    NavigationLink(destination: ProfileView()) {
                                        Image(systemName: "person.crop.circle")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top)

                                // Welcome Message
                                VStack(alignment: .leading) {
                                    Text("Hello 👋")
                                        .font(.title)
                                        .fontWeight(.bold)

                                    Text("Let's discover your car here")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                                .padding(.horizontal)

                                // Cars List
                                VStack(alignment: .center, spacing: 16) {
                                    ForEach(carManager.cars, id: \.id) { car in
                                        CarCardView(
                                            car: car,
                                            onFreeServiceTap: {
                                                print("Free Service tapped for car: \(car.carModel)")
                                                // Handle Free Service action here
                                            },
                                            onUpdateTap: {
                                                selectedCar = car
                                                navigateToUpdateView = true
                                            }
                                        )
                                        .onTapGesture {
                                            selectedCar = car
                                            navigateToDetailView = true
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top)
                                .padding(.bottom, 100) // Avoid overlap with bottom nav bar
                            }
                        }
                    }
                }

                // Bottom Navigation Bar
                BottomNavItem(selectedTab: $selectedTab)
                    .frame(height: 70)
                    .background(
                        Color.white
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
                    )
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .navigationDestination(isPresented: $navigateToDetailView) {
                if let car = selectedCar {
                    CarDetailView(car: car)
                }
            }
            .navigationDestination(isPresented: $navigateToUpdateView) {
                if let car = selectedCar {
                    UpdateCarView(car: .constant(car), onUpdate: { updatedCar, updatedImage in
                        NetworkService.shared.updateCar(updatedCar: updatedCar, updatedImage: updatedImage) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let responseCar):
                                    // Update the local car list with the updated car
                                    if let index = carManager.cars.firstIndex(where: { $0.id == responseCar.id }) {
                                        carManager.cars[index] = responseCar
                                    }
                                    print("Car updated successfully!")
                                case .failure(let error):
                                    print("Failed to update car:", error.localizedDescription)
                                }
                            }
                        }
                        navigateToUpdateView = false // Return to HomePage after the update
                    })
                }
            }
        }
        .onAppear {
            fetchCars()
        }
    }

    // Fetch cars logic
    private func fetchCars() {
        NetworkService.shared.fetchUserCars { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedCars):
                    carManager.cars = fetchedCars
                case .failure(let error):
                    print("Error Fetching Cars:", error.localizedDescription)
                }
            }
        }
    }
}



struct CarCardView: View {
    let car: Car

    var onFreeServiceTap: (() -> Void)? // Closure for Free Service Icon tap
    var onUpdateTap: (() -> Void)? // Closure for Update Icon tap

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationLink(destination: CarDetailView(car: car)) {
            VStack(alignment: .leading) {
                // Display car image from imageUrl or show a placeholder
                if let imageUrl = car.imageUrl?.replacingOccurrences(of: "localhost", with: "127.0.0.1"),
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 340, height: 180)
                                .clipped()
                                .cornerRadius(15)
                        } else if phase.error != nil {
                            Image(systemName: "car.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 340, height: 180)
                                .cornerRadius(15)
                                .foregroundColor(.gray)
                        } else {
                            ProgressView() // Show a loader while the image loads
                                .frame(width: 340, height: 180)
                        }
                    }
                } else {
                    Image(systemName: "car.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 340, height: 180)
                        .cornerRadius(15)
                        .foregroundColor(.gray)
                }
                
                // Car details
                VStack(alignment: .leading, spacing: 4) {
                    Text(car.carModel) // Car model
                        .font(.headline)
                    Text("\(car.year) - \(car.make)") // Year and make
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .frame(width: 340) // Fixed width for the entire card
            .background(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255).opacity(0.2)) // Background color for the card
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
            // Icons in the bottom-right corner
            HStack(spacing: 16) {
                Button(action: {
                    onFreeServiceTap?()
                }) {
                    Image(systemName: "wrench.and.screwdriver") // Free Service Icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .padding(8)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }

                Button(action: {
                    onUpdateTap?()
                }) {
                    Image(systemName: "square.and.pencil") // Update Icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .padding(8)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
            .padding(8)
        }
        .padding(.horizontal)
    }
}

struct MockData {
    static let cars = [
        Car(
            id: "1",
            make: "Toyota",
            carModel: "Corolla",
            year: 2015,
            mileage: 75000,
            owner: "John Doe",
            imageUrl: "https://via.placeholder.com/300"
        ),
        Car(
            id: "2",
            make: "Honda",
            carModel: "Civic",
            year: 2020,
            mileage: 20000,
            owner: "Jane Doe",
            imageUrl: "https://via.placeholder.com/300"
        ),
        Car(
            id: "3",
            make: "Honda",
            carModel: "Civic",
            year: 2020,
            mileage: 20000,
            owner: "Jane Doe",
            imageUrl: nil // Testing placeholder
        )
    ]
}

enum TabBarItems: String, CaseIterable {
    case home
    case new
    case pluslogo
    case inbox
    case profile
    
    var title: String {
        if self != .pluslogo {
            return self.rawValue.capitalized
        } else {
            return ""
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house"
        case .new:
            return "person.2"
        case .pluslogo:
            return "plus.circle"
        case .inbox:
            return "arrow.down.message"
        case .profile:
            return "person"
        }
    }
    
    var selectedIcon: String{
        switch self {
        case .home:
            return "house.fill"
        case .new:
            return "person.2.fill"
        case .pluslogo:
            return "plus.circle"
        case .inbox:
            return "arrow.down.message.fill"
        case .profile:
            return "person.fill"
        }
    }
}

