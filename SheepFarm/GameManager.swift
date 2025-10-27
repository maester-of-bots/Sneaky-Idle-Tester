import Foundation
import SwiftUI
import Combine

class GameManager: ObservableObject {
    @Published var gameState: GameState
    @Published var showStartScreen: Bool = true
    
    private var gameTimer: Timer?
    private var weatherTimer: Timer?
    private var saveTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private let costMultiplier = 1.75
    
    init() {
        self.gameState = GameState()
        // Forward gameState changes to trigger UI updates
        gameState.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        loadGame()
    }
    
    // MARK: - Start Game
    func startGame(farmerName: String, region: Region) {
        gameState.farmerName = farmerName
        gameState.region = region.id
        gameState.currency = region.startingCurrency
        gameState.weatherBonus = region.weatherBonus
        gameState.productionBonus = region.productionBonus
        showStartScreen = false
        startGameLoops()
        saveGame()
    }
    
    // MARK: - Game Loops
    func startGameLoops() {
        // Main game tick (production)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.gameTick()
        }
        
        // Weather changes every 5 minutes
        weatherTimer = Timer.scheduledTimer(withTimeInterval: 300.0, repeats: true) { [weak self] _ in
            self?.changeWeather()
        }
        
        // Auto-save every 30 seconds
        saveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.saveGame()
        }
    }
    
    func stopGameLoops() {
        gameTimer?.invalidate()
        weatherTimer?.invalidate()
        saveTimer?.invalidate()
    }
    
    // MARK: - Game Tick (Production)
    func gameTick() {
        var totalProduction = 0.0
        
        // Calculate production from all sheep
        for tier in SheepTier.allTiers {
            let count = gameState.sheepCounts[tier.id] ?? 0
            if count > 0 {
                totalProduction += tier.baseWool * Double(count)
            }
        }
        
        // Apply bonuses
        let productionMultiplier = gameState.weatherBonus * gameState.productionBonus * gameState.weather.multiplier
        totalProduction *= productionMultiplier
        
        // Apply upgrade bonuses
        let productionUpgrades = gameState.upgradeLevels["shears"] ?? 0
        let staffUpgrades = gameState.upgradeLevels["staff"] ?? 0
        let housingUpgrades = gameState.upgradeLevels["housing"] ?? 0
        
        totalProduction *= (1.0 + Double(productionUpgrades) * 0.15)
        totalProduction *= (1.0 + Double(staffUpgrades) * 0.25)
        totalProduction *= (1.0 + Double(housingUpgrades) * 0.10)
        
        if totalProduction > 0 {
            gameState.wool += totalProduction
            print("🔄 Tick: +\(totalProduction.formatNumber()) wool (Total: \(gameState.wool.formatNumber()))")
        }
        
        // Auto-actions
        if gameState.autoSellWool && gameState.wool >= 10 {
            sellWool()
        }
        
        if gameState.autoProcess && gameState.processingUnlocked && gameState.wool >= 100 {
            processWool()
        }
        
        if gameState.autoSellProducts && gameState.products >= 10 {
            sellProducts()
        }
    }
    
    // MARK: - Click Sheep
    func clickSheep() {
        let baseClick = 1.0
        let clickUpgrades = gameState.upgradeLevels["clickPower"] ?? 0
        let clickPower = baseClick + Double(clickUpgrades)
        
        gameState.wool += clickPower
        gameState.totalClicks += 1
        print("🐑 Click! +\(clickPower) wool (Total: \(gameState.wool.formatNumber()))")
    }
    
    // MARK: - Buy Sheep
    func buySheep(tier: SheepTier) {
        guard canAffordSheep(tier) else { 
            print("Cannot afford \(tier.name) - Need: \(gameState.sheepCosts[tier.id] ?? tier.baseCost), Have: \(gameState.currency)")
            return 
        }
        guard isSheepUnlocked(tier) else { 
            print("\(tier.name) is locked")
            return 
        }
        
        let cost = gameState.sheepCosts[tier.id] ?? tier.baseCost
        gameState.currency -= cost
        gameState.sheepCounts[tier.id, default: 0] += 1
        
        // Update cost for next purchase
        let newCount = gameState.sheepCounts[tier.id] ?? 1
        gameState.sheepCosts[tier.id] = tier.baseCost * pow(costMultiplier, Double(newCount))
        
        print("✅ Bought \(tier.name)! Count: \(newCount), Remaining kr: \(gameState.currency)")
        
        saveGame()
    }
    
    func canAffordSheep(_ tier: SheepTier) -> Bool {
        let cost = gameState.sheepCosts[tier.id] ?? tier.baseCost
        return gameState.currency >= cost
    }
    
    func isSheepUnlocked(_ tier: SheepTier) -> Bool {
        guard let reqTier = tier.requirementTier else { return true }
        let count = gameState.sheepCounts[reqTier] ?? 0
        return count >= tier.requirementCount
    }
    
    // MARK: - Wool Actions
    func sellWool() {
        guard gameState.wool >= 1.0 else { return }
        let sellValue = gameState.wool * 10.0
        gameState.currency += sellValue
        gameState.wool = 0
        print("💰 Sold wool for \(sellValue.formatCurrency())")
        saveGame()
    }
    
    func processWool() {
        guard gameState.processingUnlocked else { return }
        guard gameState.wool >= 100 else { return }
        
        let woolUsed = floor(gameState.wool / 100) * 100
        let baseProducts = Int(woolUsed / 100)
        
        // Apply processing bonus
        let processingLevel = gameState.upgradeLevels["processing"] ?? 0
        let bonus = 1.0 + (Double(processingLevel) * 0.20)
        let productsCreated = Int(Double(baseProducts) * bonus)
        
        gameState.wool -= woolUsed
        gameState.products += productsCreated
        print("🧵 Processed \(woolUsed) wool into \(productsCreated) products")
        saveGame()
    }
    
    func sellProducts() {
        guard gameState.products > 0 else { return }
        let sellValue = Double(gameState.products) * 500.0
        gameState.currency += sellValue
        gameState.products = 0
        print("👕 Sold products for \(sellValue.formatCurrency())")
        saveGame()
    }
    
    // MARK: - Upgrades
    func buyUpgrade(_ upgrade: Upgrade) {
        let currentLevel = gameState.upgradeLevels[upgrade.id] ?? 0
        guard currentLevel < upgrade.maxLevel else { return }
        
        let cost = upgrade.baseCost * pow(1.5, Double(currentLevel))
        guard gameState.currency >= cost else { return }
        
        gameState.currency -= cost
        gameState.upgradeLevels[upgrade.id] = currentLevel + 1
        
        // Apply upgrade effect
        if upgrade.id == "processing" {
            gameState.processingBonus += upgrade.effectValue
            if currentLevel == 0 {
                gameState.processingUnlocked = true
            }
        }
        
        print("🔧 Upgraded \(upgrade.name) to level \(currentLevel + 1)")
        saveGame()
    }
    
    func getUpgradeCost(_ upgrade: Upgrade) -> Double {
        let currentLevel = gameState.upgradeLevels[upgrade.id] ?? 0
        return upgrade.baseCost * pow(1.5, Double(currentLevel))
    }
    
    func canAffordUpgrade(_ upgrade: Upgrade) -> Bool {
        let cost = getUpgradeCost(upgrade)
        return gameState.currency >= cost
    }
    
    // MARK: - Weather
    func changeWeather() {
        let weathers: [WeatherType] = [.pleasant, .sunny, .blizzard, .storm, .fog]
        let random = weathers.randomElement() ?? .pleasant
        gameState.weather = random
    }
    
    // MARK: - Stats
    func getTotalSheep() -> Int {
        gameState.sheepCounts.values.reduce(0, +)
    }
    
    func getWoolPerSecond() -> Double {
        var total = 0.0
        for tier in SheepTier.allTiers {
            let count = gameState.sheepCounts[tier.id] ?? 0
            if count > 0 {
                total += tier.baseWool * Double(count)
            }
        }
        
        let multiplier = gameState.weatherBonus * gameState.productionBonus * gameState.weather.multiplier
        total *= multiplier
        
        let productionUpgrades = gameState.upgradeLevels["shears"] ?? 0
        let staffUpgrades = gameState.upgradeLevels["staff"] ?? 0
        let housingUpgrades = gameState.upgradeLevels["housing"] ?? 0
        
        total *= (1.0 + Double(productionUpgrades) * 0.15)
        total *= (1.0 + Double(staffUpgrades) * 0.25)
        total *= (1.0 + Double(housingUpgrades) * 0.10)
        
        return total
    }
    
    func getTotalMultiplier() -> Double {
        var mult = gameState.weatherBonus * gameState.productionBonus * gameState.weather.multiplier
        
        let productionUpgrades = gameState.upgradeLevels["shears"] ?? 0
        let staffUpgrades = gameState.upgradeLevels["staff"] ?? 0
        let housingUpgrades = gameState.upgradeLevels["housing"] ?? 0
        
        mult *= (1.0 + Double(productionUpgrades) * 0.15)
        mult *= (1.0 + Double(staffUpgrades) * 0.25)
        mult *= (1.0 + Double(housingUpgrades) * 0.10)
        
        return mult
    }
    
    // MARK: - Save/Load
    func saveGame() {
        if let encoded = try? JSONEncoder().encode(gameState) {
            UserDefaults.standard.set(encoded, forKey: "icelandicSheepGame")
        }
    }
    
    func loadGame() {
        if let data = UserDefaults.standard.data(forKey: "icelandicSheepGame"),
           let decoded = try? JSONDecoder().decode(GameState.self, from: data) {
            self.gameState = decoded
            // Re-setup the binding for the loaded state
            gameState.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
            self.showStartScreen = false
            startGameLoops()
        }
    }
    
    func resetGame() {
        UserDefaults.standard.removeObject(forKey: "icelandicSheepGame")
        gameState = GameState()
        // Re-setup the binding for the new state
        cancellables.removeAll()
        gameState.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        showStartScreen = true
        stopGameLoops()
    }
    
    func exportSave() -> String {
        if let encoded = try? JSONEncoder().encode(gameState),
           let jsonString = String(data: encoded, encoding: .utf8) {
            return jsonString
        }
        return ""
    }
    
    func importSave(_ jsonString: String) {
        if let data = jsonString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(GameState.self, from: data) {
            self.gameState = decoded
            // Re-setup the binding for the imported state
            cancellables.removeAll()
            gameState.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
            saveGame()
        }
    }
}

// MARK: - Formatting Helpers
extension Double {
    func formatNumber() -> String {
        if self >= 1_000_000_000 {
            return String(format: "%.2fB", self / 1_000_000_000)
        } else if self >= 1_000_000 {
            return String(format: "%.2fM", self / 1_000_000)
        } else if self >= 1_000 {
            return String(format: "%.2fK", self / 1_000)
        } else if self >= 1 {
            return String(format: "%.2f", self)
        } else {
            return String(format: "%.4f", self)
        }
    }
    
    func formatCurrency() -> String {
        return self.formatNumber() + " kr"
    }
}
