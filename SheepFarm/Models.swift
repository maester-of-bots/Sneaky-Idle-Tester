import Foundation

// MARK: - Region
struct Region: Codable {
    let id: String
    let name: String
    let difficulty: String
    let description: String
    let startingCurrency: Double
    let weatherBonus: Double
    let productionBonus: Double
    
    static let all: [Region] = [
        Region(id: "reykjavik", name: "Reykjavík", difficulty: "Easy",
               description: "The capital region with mild weather and good infrastructure. Perfect for beginners!",
               startingCurrency: 1000, weatherBonus: 1.2, productionBonus: 1.0),
        Region(id: "southcoast", name: "South Coast", difficulty: "Easy",
               description: "Beautiful coastline with tourist traffic. Good market access!",
               startingCurrency: 800, weatherBonus: 1.1, productionBonus: 1.0),
        Region(id: "akureyri", name: "Akureyri", difficulty: "Medium",
               description: "Northern capital with variable seasons. Balanced challenge and rewards.",
               startingCurrency: 500, weatherBonus: 1.0, productionBonus: 1.2),
        Region(id: "eastfjords", name: "East Fjords", difficulty: "Medium",
               description: "Remote but beautiful. Harder logistics but premium wool prices!",
               startingCurrency: 400, weatherBonus: 1.0, productionBonus: 1.15),
        Region(id: "westfjords", name: "Westfjords", difficulty: "Hard",
               description: "Isolated and challenging terrain. Only for experienced farmers!",
               startingCurrency: 200, weatherBonus: 0.8, productionBonus: 2.0),
        Region(id: "highlands", name: "Highlands", difficulty: "Hard",
               description: "The interior wilderness. Extreme conditions but legendary wool quality!",
               startingCurrency: 100, weatherBonus: 0.7, productionBonus: 2.5)
    ]
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
        SheepTier(id: "normal", name: "Normal Sheep", emoji: "🐑", baseWool: 1.15, baseCost: 50, requirementTier: nil, requirementCount: 0),
        SheepTier(id: "comfort", name: "Comfort Sheep", emoji: "🛏️", baseWool: 3.45, baseCost: 500, requirementTier: "normal", requirementCount: 10),
        SheepTier(id: "pampered", name: "Pampered Sheep", emoji: "💅", baseWool: 6.90, baseCost: 2000, requirementTier: "comfort", requirementCount: 20),
        SheepTier(id: "elite", name: "Elite Sheep", emoji: "👑", baseWool: 20, baseCost: 10000, requirementTier: "pampered", requirementCount: 50),
        SheepTier(id: "rainbow", name: "Rainbow Sheep", emoji: "🌈", baseWool: 10, baseCost: 50000, requirementTier: "elite", requirementCount: 100),
        SheepTier(id: "golden", name: "Golden Fleece", emoji: "✨", baseWool: 75, baseCost: 100000, requirementTier: "rainbow", requirementCount: 150),
        SheepTier(id: "sheepzilla", name: "Sheepzilla", emoji: "🦖", baseWool: 300, baseCost: 500000, requirementTier: "golden", requirementCount: 200),
        SheepTier(id: "unicorn", name: "Unicorn Sheep", emoji: "🦄", baseWool: 100, baseCost: 1000000, requirementTier: "sheepzilla", requirementCount: 300),
        SheepTier(id: "shadow", name: "Shadow Sheep", emoji: "🌑", baseWool: 1500, baseCost: 5000000, requirementTier: "unicorn", requirementCount: 400),
        SheepTier(id: "dragon", name: "Dragon Sheep", emoji: "🐉", baseWool: 20000, baseCost: 50000000, requirementTier: "shadow", requirementCount: 500)
    ]
}

// MARK: - Upgrade
struct Upgrade: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let baseCost: Double
    let maxLevel: Int
    let effectType: String // "production", "processing", "clickPower"
    let effectValue: Double
    
    static let allUpgrades: [Upgrade] = [
        Upgrade(id: "processing", name: "Wool Processing", description: "Increase processed product value (+20% per level)",
                baseCost: 100, maxLevel: 100, effectType: "processing", effectValue: 0.20),
        Upgrade(id: "shears", name: "Quality Shears", description: "Better tools increase wool output (+15% per level)",
                baseCost: 250, maxLevel: 50, effectType: "production", effectValue: 0.15),
        Upgrade(id: "staff", name: "Skilled Staff", description: "Hire experienced farmers (+25% per level)",
                baseCost: 500, maxLevel: 30, effectType: "production", effectValue: 0.25),
        Upgrade(id: "housing", name: "Better Housing", description: "Improved barns increase sheep comfort (+10% per level)",
                baseCost: 10000, maxLevel: 20, effectType: "production", effectValue: 0.10),
        Upgrade(id: "clickPower", name: "Shearing Skill", description: "Increase wool per click",
                baseCost: 50, maxLevel: 50, effectType: "clickPower", effectValue: 1.0)
    ]
}

// MARK: - Weather
enum WeatherType: String, Codable {
    case pleasant, sunny, blizzard, storm, fog
    
    var emoji: String {
        switch self {
        case .pleasant: return "🌤️"
        case .sunny: return "☀️"
        case .blizzard: return "❄️"
        case .storm: return "⛈️"
        case .fog: return "🌫️"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .pleasant: return 1.15
        case .sunny: return 1.25
        case .blizzard: return 0.75
        case .storm: return 0.80
        case .fog: return 0.90
        }
    }
    
    var description: String {
        switch self {
        case .pleasant: return "Pleasant Weather (+15% production)"
        case .sunny: return "Sunny Day (+25% production)"
        case .blizzard: return "Blizzard (-25% production)"
        case .storm: return "Storm (-20% production)"
        case .fog: return "Foggy (-10% production)"
        }
    }
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
    
    var weatherBonus: Double = 1.0
    var productionBonus: Double = 1.0
    var processingBonus: Double = 0.0
    
    init() {
        self.currency = 0
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
    }
}
