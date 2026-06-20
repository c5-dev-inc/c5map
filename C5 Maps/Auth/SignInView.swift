import SwiftUI

struct SignInView: View {
    var onSignIn: () -> Void
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    Color(.systemGray6),
                    Color(.systemGray5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    // Logo Section
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 140, height: 140)
                                .blur(radius: 20)
                            
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 110, height: 110)
                                .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "map.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                        }
                        
                        Text("C5 Maps")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Apple Maps advertising made simple")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    Spacer(minLength: 20)
                    
                    // Feature Cards
                    VStack(spacing: 12) {
                        FeatureRow(
                            icon: "building.2.fill",
                            title: "Add & Claim Your Business on Apple Maps",
                            color: .blue
                        )
                        
                        FeatureRow(
                            icon: "megaphone.fill",
                            title: "Run Campaigns & Ads",
                            color: .orange
                        )
                        
                        FeatureRow(
                            icon: "brain.head.profile",
                            title: "AI-Powered Optimization",
                            color: .purple
                        )
                        
                        FeatureRow(
                            icon: "chart.bar.fill",
                            title: "Real-time Analytics",
                            color: .teal
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 20)
                    
                    // Sign In Button
                    VStack(spacing: 12) {
                        Button(action: mockSignIn) {
                            HStack(spacing: 12) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.0)
                                } else {
                                    Image(systemName: "applelogo")
                                        .font(.title3)
                                    Text("Continue with Apple")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.black, Color.gray.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isLoading)
                        
                        // Terms & Privacy Links
                        HStack(spacing: 8) {
                            Link("Terms of Service", destination: URL(string: "https://c5-dev.com/map/terms")!)
                                .font(.caption2)
                                .foregroundColor(.blue)
                            
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Link("Privacy Policy", destination: URL(string: "https://c5-dev.com/map/privacy")!)
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        
                        Text("By continuing, you agree to our Terms\nand Privacy Policy")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                    
                    Spacer(minLength: 0)
                }
                .frame(minHeight: geometry.size.height)
                .padding(.horizontal, 0)
            }
        }
        .overlay(
            Group {
                if isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .overlay(
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.3)
                                    .tint(.blue)
                                    .colorScheme(.dark)
                                Text("Connecting to Apple...")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            )
                        )
                }
            }
        )
    }
    
    private func mockSignIn() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            onSignIn()
        }
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground).opacity(0.6))
        .cornerRadius(14)
    }
}

#Preview {
    SignInView(onSignIn: {})
}
