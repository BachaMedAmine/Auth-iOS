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
                                            .onTapGesture {
                                                logNavigation(from: "HomePage", to: "PhotosView")
                                                navigateToPhotosView = true

                                                }
                                    }

                                    Spacer()

                                    NavigationLink(destination: ProfileView()) {
                                        Image(systemName: "person.crop.circle")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                            .onTapGesture {
                                                logNavigation(from: "HomePage", to: "ProfileView")
                                                navigateToProfileView = true
                                                }
                                            
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
                                    ForEach(carManager.cars, id: \.self) { car in
                                        CarCardView(car: car)
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
            .onAppear {
                print("Fetching cars...") // Debug message
                print("CarManager.shared.cars before fetch:", CarManager.shared.cars) // Debug the existing cars list

                fetchCars() // Fetch cars from the backend
                
                // Print the cars after fetching them (add a slight delay to ensure fetchCars completes)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    print("CarManager.shared.cars after fetch:", CarManager.shared.cars) // Debug the updated cars list
                    CarManager.shared.cars.forEach { car in
                        print("Car details - Model: \(car.carModel), Make: \(car.make), Year: \(car.year), Image URL: \(car.imageUrl ?? "No URL")")
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToPhotosView) {
                PhotosView()
                }
                .navigationDestination(isPresented: $navigateToProfileView) {
                    ProfileView()
                }
        }
    }

    // Fetch cars logic
    private func fetchCars() {
        isLoading = true
        NetworkService.shared.fetchUserCars { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedCars):
                    print("Fetched Cars:", fetchedCars) // Debugging
                    CarManager.shared.cars = fetchedCars
                    errorMessage = nil
                case .failure(let error):
                    print("Error Fetching Cars:", error.localizedDescription)
                    errorMessage = "Failed to load cars: \(error.localizedDescription)"
                }
            }
        }
    }
}



struct CarCardView: View {
    let car: Car

    var body: some View {
        VStack(alignment: .leading) {
            // Display car image from imageUrl or show a placeholder
            if let imageUrl = car.imageUrl?.replacingOccurrences(of: "localhost", with: "127.0.0.1"),
                           let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .cornerRadius(25)
                    } else if let error = phase.error {
                        
                        Image(systemName: "car.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .cornerRadius(10)
                            .foregroundColor(.gray)
                    } else {
                        ProgressView() // Show a loader while the image loads
                            .frame(height: 180)
                    }
                }
            } else {
                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .cornerRadius(10)
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
        }
        .padding()
        .background(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255).opacity(0.2)) // Background color for the card
        .cornerRadius(15)
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

