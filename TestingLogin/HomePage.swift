import SwiftUI


struct HomePage: View {
    @ObservedObject var carManager = CarManager.shared

    @State private var cars: [Car] = [] // List of fetched cars
    @State private var isLoading: Bool = true // Loading state
    @State private var errorMessage: String? // Error message
    @State private var navigateToPhotosView = false // State for PhotosView navigation
    @State private var navigateToProfileView = false // State for EditProfile navigation
    @State private var selectedCar: Car? // Holds the selected car for navigation
    @State private var navigateToDetailView = false // State for CarDetailView navigation
    @State private var navigateToUpdateView = false // State for CarUpdateView navigation
    @State private var selectedCarForMaintenance: Car? // Track selected car for MaintenanceView
      @State private var navigateToMaintenance = false // Trigger for MaintenanceView navigation
  


    
    
    
    
    var body: some View {
            VStack(spacing: 0) {
                ZStack {
                    if carManager.cars.isEmpty {
                        VStack {
                                // Header (placé en haut)
                                HStack {
                                    Image(systemName: "square.grid.2x2")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                    
                                    Spacer().frame(width: 250)
                                    
                                    NavigationLink(destination: PhotosView()) {
                                        Image(systemName: "plus.circle")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                    }
                                    
                                    NavigationLink(destination: ProfileView()) {
                                        Image(systemName: "person.crop.circle")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top)
                                
                                Spacer() // Espace pour pousser le contenu vers le bas
                                
                                // Texte centré
                                Text("No 🚘 available. Add a car to get started!")
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                
                                Spacer() // Espace pour pousser le contenu vers le haut
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity) // S'assure que le VStack occupe tout l'écran
                        .navigationBarBackButtonHidden(true)
                        } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                // Header
                                HStack {
                                    Image(systemName: "square.grid.2x2")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                    
                                    Spacer().frame(width: 250)
                                    
                                    
                                    NavigationLink(destination: PhotosView()) {
                                        Image(systemName: "plus.circle")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                    }

                            

                                    NavigationLink(destination: ProfileView()) {
                                        Image(systemName: "person.crop.circle")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255))
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top)

                                // Welcome Message
                                HStack(alignment: .center) {
                                    Spacer().frame(width: 100)
                                    Text("🚘 Car's List 🚘")
                                        .font(.title)
                                    
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal)

                                // Cars List
                                VStack(alignment: .center, spacing: 16) {
                                    ForEach(carManager.cars, id: \.id) { car in
                                        CarCardView(
                                            car: car,
                                            onFreeServiceTap: {
                                                self.selectedCarForMaintenance = car
                                                self.navigateToMaintenance = true
                                            },
                                            onUpdateTap: {
                                                self.selectedCar = car
                                                self.navigateToUpdateView = true
                                            }
                                        )
                                        .onTapGesture {
                                            self.selectedCar = car
                                            self.navigateToDetailView = true
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

            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .navigationDestination(isPresented: $navigateToMaintenance) {
                if let car = selectedCarForMaintenance {
                    MaintenanceView(car: car)
                }
            }
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
    @Environment(\.colorScheme) var colorScheme
    var onFreeServiceTap: (() -> Void)? // Closure for Free Service Icon tap
    var onUpdateTap: (() -> Void)? // Closure for Update Icon tap
    
    var dynamicBackgroundColor: Color {
            colorScheme == .dark
        ? Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255)
                : Color(red: 180 / 255, green: 196 / 255, blue: 36 / 255, opacity: 0.2) // Couleur pour Light Mode
        }
    
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
                                .padding(.top, 10)
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
                VStack(alignment: .leading, spacing: 16) {
                    Text(car.carModel) // Car model
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("\(car.year) - \(car.make)") // Year and make
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .padding(.leading, -5)
            }
            .frame(width: 380) // Fixed width for the entire card
            .background(dynamicBackgroundColor) // Background color for the card
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
                        .foregroundColor(.black)
                        .clipShape(Circle())
                        
                }

                Button(action: {
                    onUpdateTap?()
                }) {
                    Image(systemName: "pencil.and.list.clipboard") // Update Icon
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.black)
                        .frame(width: 25, height: 25)
                        .padding(8)
                        .clipShape(Circle())
                    
                }
            }
            .padding(8)
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden(true)
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
            imageUrl: "https://via.placeholder.com/300",
            engine: "1.0"
        ),
        Car(
            id: "2",
            make: "Honda",
            carModel: "Civic",
            year: 2020,
            mileage: 20000,
            owner: "Jane Doe",
            imageUrl: "https://via.placeholder.com/300",
            engine: "1.0"
        ),
        Car(
            id: "3",
            make: "Honda",
            carModel: "Civic",
            year: 2020,
            mileage: 20000,
            owner: "Jane Doe",
            imageUrl: nil ,
            engine: "1.0"
        )
    ]
}


