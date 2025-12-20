import Foundation
import SwiftUI

// MARK: - Weather Type
enum WeatherType: String, Codable {
    case sunny = "Sunny"
    case cloudy = "Cloudy"
    case rainy = "Rainy"
    case pleasant = "Pleasant"
    case foggy = "Foggy"
    
    var multiplier: Double {
        switch self {
        case .sunny: return 1.2
        case .pleasant: return 1.0
        case .cloudy: return 0.9
        case .foggy: return 0.85
        case .rainy: return 0.7
        }
    }
    
    var emoji: String {
        switch self {
        case .sunny: return "☀️"
        case .pleasant: return "⛅"
        case .cloudy: return "☁️"
        case .foggy: return "🌫️"
        case .rainy: return "🌧️"
        }
    }
}

// MARK: - Sheep Tier
struct SheepTier: Identifiable, Codable {
    let id: String
    let name: String
    let emoji: String
    let baseWool: Double
    let baseCost: Double
    let requirementTier: String?
    let requirementCount: Int
    
    static let allTiers: [SheepTier] = [
        SheepTier(id: "normal", name: "Icelandic Sheep", emoji: "🐑", baseWool: 0.1, baseCost: 10, requirementTier: nil, requirementCount: 0),
        SheepTier(id: "leader", name: "Leader Sheep", emoji: "🐏", baseWool: 0.5, baseCost: 50, requirementTier: "normal", requirementCount: 5),
        SheepTier(id: "merino", name: "Merino Sheep", emoji: "🐑", baseWool: 2.0, baseCost: 200, requirementTier: "leader", requirementCount: 10),
        SheepTier(id: "suffolk", name: "Suffolk Sheep", emoji: "🐏", baseWool: 10, baseCost: 1000, requirementTier: "merino", requirementCount: 20),
        SheepTier(id: "jacob", name: "Jacob Sheep", emoji: "🐑", baseWool: 50, baseCost: 5000, requirementTier: "suffolk", requirementCount: 30),
        SheepTier(id: "dorset", name: "Dorset Sheep", emoji: "🐏", baseWool: 250, baseCost: 25000, requirementTier: "jacob", requirementCount: 40),
        SheepTier(id: "romney", name: "Romney Sheep", emoji: "🐑", baseWool: 1250, baseCost: 125000, requirementTier: "dorset", requirementCount: 50),
        SheepTier(id: "leicester", name: "Leicester Sheep", emoji: "🐏", baseWool: 6250, baseCost: 625000, requirementTier: "romney", requirementCount: 60),
        SheepTier(id: "cotswold", name: "Cotswold Sheep", emoji: "🐑", baseWool: 30000, baseCost: 3000000, requirementTier: "leicester", requirementCount: 70),
        SheepTier(id: "golden", name: "Golden Fleece", emoji: "✨", baseWool: 150000, baseCost: 15000000, requirementTier: "cotswold", requirementCount: 80)
    ]
}

// MARK: - Upgrade
struct Upgrade: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let baseCost: Double
    let maxLevel: Int
    
    static let allUpgrades: [Upgrade] = [
        Upgrade(id: "shears", name: "Better Shears", description: "Increase wool production by 15% per level", baseCost: 100, maxLevel: 50),
        Upgrade(id: "staff", name: "Hire Staff", description: "Boost production by 25% per level", baseCost: 500, maxLevel: 30),
        Upgrade(id: "housing", name: "Better Housing", description: "Improve production by 10% per level", baseCost: 1000, maxLevel: 25),
        Upgrade(id: "clickPower", name: "Click Power", description: "Increase click wool by +1 per level", baseCost: 50, maxLevel: 100),
        Upgrade(id: "processing", name: "Wool Processing", description: "Increase processed product value by 20% per level", baseCost: 5000, maxLevel: 20)
    ]
}

// MARK: - Game State
class GameState: ObservableObject, Codable {
    @Published var currency: Double
    @Published var wool: Double
    @Published var products: Int
    @Published var sheepCounts: [String: Int]
    @Published var sheepCosts: [String: Double]
    @Published var upgradeLevels: [String: Int]
    @Published var weather: WeatherType
    @Published var farmerName: String
    @Published var region: String
    @Published var totalClicks: Int
    @Published var processingUnlocked: Bool
    @Published var autoSellWool: Bool
    @Published var autoProcess: Bool
    @Published var autoSellProducts: Bool
    
    // Bonuses from region
    var weatherBonus: Double = 1.0
    var productionBonus: Double = 1.0
    
    init() {
        self.currency = 200
        self.wool = 0
        self.products = 0
        self.sheepCounts = [:]
        self.sheepCosts = [:]
        self.upgradeLevels = [:]
        self.weather = .pleasant
        self.farmerName = "Farmer"
        self.region = "reykjavik"
        self.totalClicks = 0
        self.processingUnlocked = false
        self.autoSellWool = false
        self.autoProcess = false
        self.autoSellProducts = false
        
        // Initialize costs
        for tier in SheepTier.allTiers {
            sheepCounts[tier.id] = 0
            sheepCosts[tier.id] = tier.baseCost
        }
        
        for upgrade in Upgrade.allUpgrades {
            upgradeLevels[upgrade.id] = 0
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case currency, wool, products, sheepCounts, sheepCosts, upgradeLevels
        case weather, farmerName, region, totalClicks, processingUnlocked
        case autoSellWool, autoProcess, autoSellProducts
        case weatherBonus, productionBonus
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currency = try container.decode(Double.self, forKey: .currency)
        wool = try container.decode(Double.self, forKey: .wool)
        products = try container.decode(Int.self, forKey: .products)
        sheepCounts = try container.decode([String: Int].self, forKey: .sheepCounts)
        sheepCosts = try container.decode([String: Double].self, forKey: .sheepCosts)
        upgradeLevels = try container.decode([String: Int].self, forKey: .upgradeLevels)
        weather = try container.decode(WeatherType.self, forKey: .weather)
        farmerName = try container.decode(String.self, forKey: .farmerName)
        region = try container.decode(String.self, forKey: .region)
        totalClicks = try container.decode(Int.self, forKey: .totalClicks)
        processingUnlocked = try container.decode(Bool.self, forKey: .processingUnlocked)
        autoSellWool = try container.decodeIfPresent(Bool.self, forKey: .autoSellWool) ?? false
        autoProcess = try container.decodeIfPresent(Bool.self, forKey: .autoProcess) ?? false
        autoSellProducts = try container.decodeIfPresent(Bool.self, forKey: .autoSellProducts) ?? false
        weatherBonus = try container.decodeIfPresent(Double.self, forKey: .weatherBonus) ?? 1.0
        productionBonus = try container.decodeIfPresent(Double.self, forKey: .productionBonus) ?? 1.0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currency, forKey: .currency)
        try container.encode(wool, forKey: .wool)
        try container.encode(products, forKey: .products)
        try container.encode(sheepCounts, forKey: .sheepCounts)
        try container.encode(sheepCosts, forKey: .sheepCosts)
        try container.encode(upgradeLevels, forKey: .upgradeLevels)
        try container.encode(weather, forKey: .weather)
        try container.encode(farmerName, forKey: .farmerName)
        try container.encode(region, forKey: .region)
        try container.encode(totalClicks, forKey: .totalClicks)
        try container.encode(processingUnlocked, forKey: .processingUnlocked)
        try container.encode(autoSellWool, forKey: .autoSellWool)
        try container.encode(autoProcess, forKey: .autoProcess)
        try container.encode(autoSellProducts, forKey: .autoSellProducts)
        try container.encode(weatherBonus, forKey: .weatherBonus)
        try container.encode(productionBonus, forKey: .productionBonus)
    }
}

// MARK: - Number Formatting Extension
extension Double {
    func formatNumber() -> String {
        if self >= 1_000_000_000 {
            return String(format: "%.2fB", self / 1_000_000_000)
        } else if self >= 1_000_000 {
            return String(format: "%.2fM", self / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.1fK", self / 1_000)
        } else {
            return String(format: "%.0f", self)
        }
    }
}
