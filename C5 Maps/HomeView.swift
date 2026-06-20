import SwiftUI
import MapKit

struct HomeView: View {
    @State private var showingAIAssistant = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Map (Full Width, Top)
                    Map(coordinateRegion: $region, interactionModes: [.zoom])
                        .frame(height: 280)
                        .overlay(
                            LinearGradient(
                                colors: [Color.clear, Color(.systemGray6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 60)
                            .offset(y: 220)
                        )
                    
                    // MARK: - Content
                    VStack(spacing: 24) {
                        
                        // Hero Icon + Title
                        VStack(spacing: 8) {
                            Image(systemName: "map.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.blue)
                            
                            Text("C5 Maps")
                                .font(.title)
                                .bold()
                            
                            Text("Apple Maps ads for local businesses")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                        
                        // Divider
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1)
                            .padding(.horizontal, 32)
                        
                        // Description
                        Text("Get found when customers search 'near me' on Apple Maps. Run ads, track performance, and grow your business.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                        
                        // MARK: - Connect Business Button
                        NavigationLink(destination: BusinessView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "building.2.fill")
                                    .font(.body)
                                Text("Connect Your Business")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                                    .font(.body)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        
                        // MARK: - AI Assistant Button
                        Button(action: {
                            showingAIAssistant = true
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.body)
                                Text("Need help? Ask AI")
                                    .font(.subheadline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 20)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showingAIAssistant) {
            AIAssistantView()
        }
    }
}

#Preview {
    HomeView()
}
