import Foundation

struct MockCampaign: Identifiable {
    let id = UUID()
    let name: String
    let spent: Double
    let taps: Int
    let impressions: Int
    let isActive: Bool
}

struct MockLocation: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let status: String
}

let mockCampaigns = [
    MockCampaign(name: "Pizza Shop - Downtown", spent: 45.50, taps: 92, impressions: 3200, isActive: true),
    MockCampaign(name: "Sushi Restaurant", spent: 22.30, taps: 44, impressions: 1800, isActive: true),
    MockCampaign(name: "Coffee House", spent: 67.80, taps: 135, impressions: 4100, isActive: false),
    MockCampaign(name: "Gym Fitness", spent: 89.20, taps: 178, impressions: 5600, isActive: true)
]

let mockLocations = [
    MockLocation(name: "Joe's Pizza", address: "123 Main St, Austin, TX", status: "Connected"),
    MockLocation(name: "Sushi Master", address: "456 Oak Ave, Austin, TX", status: "Connected"),
    MockLocation(name: "Coffee House", address: "789 Pine Rd, Austin, TX", status: "Pending")
]
