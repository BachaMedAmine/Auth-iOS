//
//  WelcomeView.swift
//  TestingLogin
//
//  Created by Meriem Abid on 10/11/2024.
//

import SwiftUI

struct WelcomeView: View {
    
    // An array of car images to rotate through
    let carImages = ["POrsche", "Lamboss", "Lambo"]
    var onContinue: () -> Void
    
    @State private var currentImageIndex = 0 // Keeps track of the current image
    @State private var timer: Timer? = nil // Timer to loop the images
    
    @State private var sliderOffset: CGFloat = 0 // Vertical offset for the slider
    @State private var navigateToContentView = false
    
    var body: some View {
        ZStack {
            // Background Image that changes based on currentImageIndex
            Image(carImages[currentImageIndex])
                .resizable()
                .scaledToFill()  // Fill the entire screen
                .edgesIgnoringSafeArea(.all)
            
            // Gradient overlay to enhance text readability
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            // Overlay Text and Button
            VStack {
                Spacer()
                
                Text("Hello There")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                    .offset(y: -sliderOffset * 0.5)
                
                Text("Slide Up to Open camera and capture your car")
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .offset(y: -sliderOffset * 0.5)

                ZStack(alignment: .bottom) { // Align the button to the bottom of the stack
                    Capsule()
                        .frame(width: 200, height: 60)
                        .foregroundColor(Color.white.opacity(0.3))

                    Text("Swipe up")
                        .foregroundColor(.primary)
                        .frame(width: 220, height: 60)
                        .background(Color(red: 191/255, green: 229/255, blue: 72/255))
                        .clipShape(Capsule())
                        .offset(y: -sliderOffset) // Move the button vertically
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if value.translation.height < 0 { // Only slide up
                                        sliderOffset = min(-value.translation.height, 200) // Limit to max upward offset
                                    }
                                }
                                .onEnded { value in
                                    if sliderOffset > 20 { // Trigger navigation if dragged sufficiently
                                        navigateToContentView = true
                                    }
                                    withAnimation {
                                        sliderOffset = 0 // Reset offset after drag
                                    }
                                }
                        )
                }
              .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Start a timer when the view appears to update the image index every 3 seconds
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                currentImageIndex = (currentImageIndex + 1) % carImages.count
            }
        }
        .onDisappear {
            // Invalidate the timer when the view disappears to stop the loop
            timer?.invalidate()
        }
        .fullScreenCover(isPresented: $navigateToContentView) {
            PhotosView() // Navigate to MainContentView on successful slide
        }
    }
}

struct MainContentView: View {
    var body: some View {
        Text("Welcome to the main content!") // Placeholder for the next screen
            .font(.largeTitle)
            .padding()
    }
}

