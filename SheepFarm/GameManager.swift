import Foundation
import SwiftUI
import Combine

class GameManager: ObservableObject {
    @Published var gameState: GameState
    
    private var gameTimer: Timer?
    private var weatherTimer: Timer?
    private var saveTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private let costMultiplier = 1.15
    
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
        startGameLoops()
        saveGame()
    }
    
    // MARK: - Game Loops
    func startGameLoops() {
        // Main game tick (production) every second
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
        }
        
        // Auto-sell wool if enabled
        if gameState.autoSellWool && gameState.wool >= 10 {
            sellWool()
        }
    }
    
    // MARK: - Buy Sheep
    func buySheep(tier: SheepTier, amount: Int = 1) {
        guard amount > 0 else { return }
        guard canAffordSheep(tier, amount: amount) else { return }
        guard isSheepUnlocked(tier) else { return }
        
        let totalCost = calculateSheepCost(tier, amount: amount)
        gameState.currency -= totalCost
        gameState.sheepCounts[tier.id, default: 0] += amount
        
        // Update cost for next purchase
        let newCount = gameState.sheepCounts[tier.id] ?? 1
        gameState.sheepCosts[tier.id] = tier.baseCost * pow(costMultiplier, Double(newCount))
        
        saveGame()
    }
    
    func calculateSheepCost(_ tier: SheepTier, amount: Int) -> Double {
        let currentCost = gameState.sheepCosts[tier.id] ?? tier.baseCost
        var totalCost = 0.0
        
        for i in 0..<amount {
            totalCost += currentCost * pow(costMultiplier, Double(i))
        }
        
        return totalCost
    }
    
    func canAffordSheep(_ tier: SheepTier, amount: Int = 1) -> Bool {
        let cost = calculateSheepCost(tier, amount: amount)
        return gameState.currency >= cost
    }
    
    func maxAffordable(_ tier: SheepTier) -> Int {
        let currentCost = gameState.sheepCosts[tier.id] ?? tier.baseCost
        var count = 0
        var totalCost = 0.0
        
        while true {
            let nextCost = currentCost * pow(costMultiplier, Double(count))
            if totalCost + nextCost > gameState.currency {
                break
            }
            totalCost += nextCost
            count += 1
            
            if count >= 100 { break } // Safety limit
        }
        
        return count
    }
    
    func isSheepUnlocked(_ tier: SheepTier) -> Bool {
        guard let reqTier = tier.requirementTier else { return true }
        let count = gameState.sheepCounts[reqTier] ?? 0
        return count >= tier.requirementCount
    }
    
    // MARK: - Sell Wool
    func sellWool() {
        guard gameState.wool > 0 else { return }
        
        let basePrice = 1.0
        let processingUpgrades = gameState.upgradeLevels["processing"] ?? 0
        let priceMultiplier = 1.0 + Double(processingUpgrades) * 0.2
        
        let earnings = gameState.wool * basePrice * priceMultiplier
        gameState.currency += earnings
        gameState.wool = 0
    }
    
    // MARK: - Upgrades
    func buyUpgrade(_ upgrade: Upgrade) {
        let currentLevel = gameState.upgradeLevels[upgrade.id] ?? 0
        guard currentLevel < upgrade.maxLevel else { return }
        
        let cost = calculateUpgradeCost(upgrade)
        guard gameState.currency >= cost else { return }
        
        gameState.currency -= cost
        gameState.upgradeLevels[upgrade.id] = currentLevel + 1
        
        if upgrade.id == "processing" && currentLevel == 0 {
            gameState.processingUnlocked = true
        }
        
        saveGame()
    }
    
    func calculateUpgradeCost(_ upgrade: Upgrade) -> Double {
        let currentLevel = gameState.upgradeLevels[upgrade.id] ?? 0
        return upgrade.baseCost * pow(1.5, Double(currentLevel))
    }
    
    func canAffordUpgrade(_ upgrade: Upgrade) -> Bool {
        let cost = calculateUpgradeCost(upgrade)
        return gameState.currency >= cost
    }
    
    // MARK: - Weather
    func changeWeather() {
        let weathers: [WeatherType] = [.sunny, .pleasant, .cloudy, .foggy, .rainy]
        gameState.weather = weathers.randomElement() ?? .pleasant
    }
    
    // MARK: - Production Calculation
    func calculateProduction() -> Double {
        var totalProduction = 0.0
        
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
        
        return totalProduction
    }
    
    // MARK: - Save/Load
    func saveGame() {
        if let encoded = try? JSONEncoder().encode(gameState) {
            UserDefaults.standard.set(encoded, forKey: "gameState")
        }
    }
    
    func loadGame() {
        if let data = UserDefaults.standard.data(forKey: "gameState"),
           let decoded = try? JSONDecoder().decode(GameState.self, from: data) {
            self.gameState = decoded
            // Re-establish binding
            gameState.objectWillChange.sink { [weak self] in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
            startGameLoops()
        }
    }
    
    func resetGame() {
        stopGameLoops()
        gameState = GameState()
        gameState.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        UserDefaults.standard.removeObject(forKey: "gameState")
    }
}
