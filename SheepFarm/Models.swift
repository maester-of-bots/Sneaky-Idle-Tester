//
//  Models.swift
//  Fjallabær Sheep Farm
//

import Foundation

// MARK: - Extensions
extension Double {
    func formatNumber() -> String {
        if self >= 1_000_000_000 {
            return String(format: "%.2fB", self / 1_000_000_000)
        } else if self >= 1_000_000 {
            return String(format: "%.2fM", self / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.2fK", self / 1_000)
        } else {
            return String(format: "%.0f", self)
        }
    }
}

// MARK: - Weather Type
enum WeatherType: String, Codable, CaseIterable {
    case sunny = "Sunny"
    case pleasant = "Pleasant"
    case cloudy = "Cloudy"
    case foggy = "Foggy"
    case rainy = "Rainy"
    
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
        case .pleasant: return "🌤"
        case .cloudy: return "☁️"
        case .foggy: return "🌫"
        case .rainy: return "🌧"
        }
    }
}

// MARK: - Region
struct Region: Identifiable, Codable {
    let id: String
    let name: String
    let difficulty: String
    let difficultyColor: String // "green", "yellow", "red"
    let description: String
    let startingCurrency: Double
    let weatherBonus: Double
    let productionBonus: Double
    
    static let allRegions: [Region] = [
        Region(
            id: "reykjavik",
            name: "Reykjavík",
            difficulty: "Easy",
            difficultyColor: "green",
            description: "The capital region offers mild weather and good market access. Perfect for beginning farmers!",
            startingCurrency: 200,
            weatherBonus: 1.0,
            productionBonus: 1.0
        ),
        Region(
            id: "south",
            name: "South Iceland",
            difficulty: "Easy",
            difficultyColor: "green",
            description: "Rich pastures and favorable climate make this an excellent starting location with slight weather advantages.",
            startingCurrency: 180,
            weatherBonus: 1.1,
            productionBonus: 1.0
        ),
        Region(
            id: "north",
            name: "North Iceland",
            difficulty: "Medium",
            difficultyColor: "yellow",
            description: "Cooler climate but excellent grazing lands boost sheep productivity significantly.",
            startingCurrency: 150,
            weatherBonus: 0.9,
            productionBonus: 1.2
        ),
        Region(
            id: "eastfjords",
            name: "East Fjords",
            difficulty: "Medium",
            difficultyColor: "yellow",
            description: "Remote fjords provide isolation and premium wool quality with increased production.",
            startingCurrency: 140,
            weatherBonus: 0.85,
            productionBonus: 1.25
        ),
        Region(
            id: "westfjords",
            name: "Westfjords",
            difficulty: "Hard",
            difficultyColor: "red",
            description: "The harshest conditions in Iceland, but your sheep produce the finest wool. For experienced farmers only!",
            startingCurrency: 100,
            weatherBonus: 0.7,
            productionBonus: 1.5
        )
    ]
}

// MARK: - Sheep Tier
struct SheepTier: Identifiable, Codable {
    let id: Int
    let name: String
    let emoji: String
    let baseWool: Double
    let baseCost: Double
    let requirementTier: Int? // Which tier must be owned
    let requirementCount: Int // How many needed to unlock
    
    static let allTiers: [SheepTier] = [
        SheepTier(id: 0, name: "Icelandic Sheep", emoji: "🐑", baseWool: 0.1, baseCost: 10, requirementTier: nil, requirementCount: 0),
        SheepTier(id: 1, name: "Leader Sheep", emoji: "🐏", baseWool: 0.5, baseCost: 50, requirementTier: 0, requirementCount: 5),
        SheepTier(id: 2, name: "Merino Sheep", emoji: "🐑", baseWool: 2.0, baseCost: 200, requirementTier: 1, requirementCount: 10),
        SheepTier(id: 3, name: "Suffolk Sheep", emoji: "🐏", baseWool: 10, baseCost: 1000, requirementTier: 2, requirementCount: 20),
        SheepTier(id: 4, name: "Jacob Sheep", emoji: "🐑", baseWool: 50, baseCost: 5000, requirementTier: 3, requirementCount: 30),
        SheepTier(id: 5, name: "Dorset Sheep", emoji: "🐏", baseWool: 250, baseCost: 25000, requirementTier: 4, requirementCount: 40),
        SheepTier(id: 6, name: "Romney Sheep", emoji: "🐑", baseWool: 1250, baseCost: 125000, requirementTier: 5, requirementCount: 50),
        SheepTier(id: 7, name: "Leicester Sheep", emoji: "🐏", baseWool: 6250, baseCost: 625000, requirementTier: 6, requirementCount: 60),
        SheepTier(id: 8, name: "Cotswold Sheep", emoji: "🐑", baseWool: 30000, baseCost: 3000000, requirementTier: 7, requirementCount: 70),
        SheepTier(id: 9, name: "Golden Fleece", emoji: "✨", baseWool: 150000, baseCost: 15000000, requirementTier: 8, requirementCount: 80)
    ]
}

// MARK: - Upgrade Type
enum UpgradeType: String, Codable, CaseIterable {
    case shears = "Better Shears"
    case staff = "Hire Staff"
    case housing = "Better Housing"
    case clickPower = "Click Power"
    case processing = "Wool Processing"
    
    var icon: String {
        switch self {
        case .shears: return "✂️"
        case .staff: return "👥"
        case .housing: return "🏠"
        case .clickPower: return "👆"
        case .processing: return "🏭"
        }
    }
    
    var description: String {
        switch self {
        case .shears: return "+15% production per level"
        case .staff: return "+25% production per level"
        case .housing: return "+10% production per level"
        case .clickPower: return "+1 wool per click"
        case .processing: return "+20% wool sell price per level"
        }
    }
    
    var baseCost: Double {
        switch self {
        case .shears: return 100
        case .staff: return 500
        case .housing: return 1000
        case .clickPower: return 50
        case .processing: return 5000
        }
    }
    
    var maxLevel: Int {
        switch self {
        case .shears: return 50
        case .staff: return 30
        case .housing: return 25
        case .clickPower: return 100
        case .processing: return 20
        }
    }
    
    var bonusPerLevel: Double {
        switch self {
        case .shears: return 0.15
        case .staff: return 0.25
        case .housing: return 0.10
        case .clickPower: return 1.0
        case .processing: return 0.20
        }
    }
}

// MARK: - Game State
class GameState: ObservableObject, Codable {
    @Published var farmerName: String = ""
    @Published var selectedRegion: Region?
    @Published var currency: Double = 0
    @Published var wool: Double = 0
    @Published var sheepCounts: [Int: Int] = [:] // tierID : count
    @Published var sheepCosts: [Int: Double] = [:] // tierID : current cost
    @Published var upgradeLevels: [String: Int] = [:] // upgradeType.rawValue : level
    @Published var currentWeather: WeatherType = .pleasant
    @Published var lastWeatherChange: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case farmerName, selectedRegion, currency, wool, sheepCounts, sheepCosts, upgradeLevels, currentWeather, lastWeatherChange
    }
    
    init() {
        // Initialize sheep costs
        for tier in SheepTier.allTiers {
            sheepCounts[tier.id] = 0
            sheepCosts[tier.id] = tier.baseCost
        }
        
        // Initialize upgrade levels
        for upgradeType in UpgradeType.allCases {
            upgradeLevels[upgradeType.rawValue] = 0
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        farmerName = try container.decode(String.self, forKey: .farmerName)
        selectedRegion = try container.decode(Region?.self, forKey: .selectedRegion)
        currency = try container.decode(Double.self, forKey: .currency)
        wool = try container.decode(Double.self, forKey: .wool)
        sheepCounts = try container.decode([Int: Int].self, forKey: .sheepCounts)
        sheepCosts = try container.decode([Int: Double].self, forKey: .sheepCosts)
        upgradeLevels = try container.decode([String: Int].self, forKey: .upgradeLevels)
        currentWeather = try container.decode(WeatherType.self, forKey: .currentWeather)
        lastWeatherChange = try container.decode(Date.self, forKey: .lastWeatherChange)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(farmerName, forKey: .farmerName)
        try container.encode(selectedRegion, forKey: .selectedRegion)
        try container.encode(currency, forKey: .currency)
        try container.encode(wool, forKey: .wool)
        try container.encode(sheepCounts, forKey: .sheepCounts)
        try container.encode(sheepCosts, forKey: .sheepCosts)
        try container.encode(upgradeLevels, forKey: .upgradeLevels)
        try container.encode(currentWeather, forKey: .currentWeather)
        try container.encode(lastWeatherChange, forKey: .lastWeatherChange)
    }
}
