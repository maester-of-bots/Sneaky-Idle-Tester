//
//  GameManager.swift
//  Fjallabær Sheep Farm
//

import Foundation
import Combine

class GameManager: ObservableObject {
    @Published var gameState = GameState()
    
    private var productionTimer: Timer?
    private var weatherTimer: Timer?
    private var saveTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Forward gameState changes to trigger view updates
        gameState.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        loadGame()
    }
    
    // MARK: - Game Start
    func startGame(farmerName: String, region: Region) {
        gameState.farmerName = farmerName
        gameState.selectedRegion = region
        gameState.currency = region.startingCurrency
        gameState.wool = 0
        gameState.currentWeather = .pleasant
        gameState.lastWeatherChange = Date()
        
        // Initialize sheep counts and costs
        for tier in SheepTier.allTiers {
            gameState.sheepCounts[tier.id] = 0
            gameState.sheepCosts[tier.id] = tier.baseCost
        }
        
        // Initialize upgrades
        for upgradeType in UpgradeType.allCases {
            gameState.upgradeLevels[upgradeType.rawValue] = 0
        }
        
        startTimers()
        saveGame()
    }
    
    // MARK: - Timers
    func startTimers() {
        stopTimers()
        
        // Production tick every 1 second
        productionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.gameTick()
        }
        
        // Weather change every 5 minutes
        weatherTimer = Timer.scheduledTimer(withTimeInterval: 300.0, repeats: true) { [weak self] _ in
            self?.changeWeather()
        }
        
        // Auto-save every 30 seconds
        saveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.saveGame()
        }
    }
    
    func stopTimers() {
        productionTimer?.invalidate()
        weatherTimer?.invalidate()
        saveTimer?.invalidate()
    }
    
    // MARK: - Game Tick (Production Loop)
    func gameTick() {
        guard let region = gameState.selectedRegion else { return }
        
        let production = calculateProduction()
        gameState.wool += production
    }
    
    // MARK: - Production Calculation
    func calculateProduction() -> Double {
        guard let region = gameState.selectedRegion else { return 0 }
        
        // Base production from all sheep
        var baseProduction: Double = 0
        for tier in SheepTier.allTiers {
            let count = gameState.sheepCounts[tier.id] ?? 0
            baseProduction += Double(count) * tier.baseWool
        }
        
        // Apply region bonuses
        var totalProduction = baseProduction * region.weatherBonus * region.productionBonus
        
        // Apply weather multiplier
        totalProduction *= gameState.currentWeather.multiplier
        
        // Apply upgrade bonuses
        let shearsLevel = gameState.upgradeLevels[UpgradeType.shears.rawValue] ?? 0
        let staffLevel = gameState.upgradeLevels[UpgradeType.staff.rawValue] ?? 0
        let housingLevel = gameState.upgradeLevels[UpgradeType.housing.rawValue] ?? 0
        
        let shearsBonus = 1.0 + (Double(shearsLevel) * UpgradeType.shears.bonusPerLevel)
        let staffBonus = 1.0 + (Double(staffLevel) * UpgradeType.staff.bonusPerLevel)
        let housingBonus = 1.0 + (Double(housingLevel) * UpgradeType.housing.bonusPerLevel)
        
        totalProduction *= shearsBonus * staffBonus * housingBonus
        
        return totalProduction
    }
    
    // MARK: - Weather System
    func changeWeather() {
        let allWeathers = WeatherType.allCases
        gameState.currentWeather = allWeathers.randomElement() ?? .pleasant
        gameState.lastWeatherChange = Date()
    }
    
    // MARK: - Sheep Purchasing
    func buySheep(tier: SheepTier, amount: Int) {
        let totalCost = calculateSheepCost(tier: tier, amount: amount)
        
        guard gameState.currency >= totalCost else { return }
        
        gameState.currency -= totalCost
        gameState.sheepCounts[tier.id, default: 0] += amount
        
        // Update cost for next purchase (1.15x scaling per purchase)
        let currentCost = gameState.sheepCosts[tier.id] ?? tier.baseCost
        gameState.sheepCosts[tier.id] = currentCost * pow(1.15, Double(amount))
    }
    
    func calculateSheepCost(tier: SheepTier, amount: Int) -> Double {
        let currentCost = gameState.sheepCosts[tier.id] ?? tier.baseCost
        var totalCost: Double = 0
        
        for i in 0..<amount {
            totalCost += currentCost * pow(1.15, Double(i))
        }
        
        return totalCost
    }
    
    func maxAffordable(tier: SheepTier) -> Int {
        let currentCost = gameState.sheepCosts[tier.id] ?? tier.baseCost
        var count = 0
        var totalCost: Double = 0
        
        // Calculate max affordable (cap at 100 to prevent infinite loops)
        while count < 100 {
            let nextCost = currentCost * pow(1.15, Double(count))
            if totalCost + nextCost > gameState.currency {
                break
            }
            totalCost += nextCost
            count += 1
        }
        
        return count
    }
    
    func isSheepUnlocked(tier: SheepTier) -> Bool {
        // First tier always unlocked
        guard let reqTier = tier.requirementTier else { return true }
        
        let reqCount = gameState.sheepCounts[reqTier] ?? 0
        return reqCount >= tier.requirementCount
    }
    
    func canAffordSheep(tier: SheepTier, amount: Int) -> Bool {
        let cost = calculateSheepCost(tier: tier, amount: amount)
        return gameState.currency >= cost
    }
    
    // MARK: - Upgrades
    func buyUpgrade(upgradeType: UpgradeType) {
        let currentLevel = gameState.upgradeLevels[upgradeType.rawValue] ?? 0
        
        // Check if at max level
        guard currentLevel < upgradeType.maxLevel else { return }
        
        let cost = calculateUpgradeCost(upgradeType: upgradeType)
        
        guard gameState.currency >= cost else { return }
        
        gameState.currency -= cost
        gameState.upgradeLevels[upgradeType.rawValue] = currentLevel + 1
    }
    
    func calculateUpgradeCost(upgradeType: UpgradeType) -> Double {
        let currentLevel = gameState.upgradeLevels[upgradeType.rawValue] ?? 0
        return upgradeType.baseCost * pow(1.5, Double(currentLevel))
    }
    
    func canAffordUpgrade(upgradeType: UpgradeType) -> Bool {
        let currentLevel = gameState.upgradeLevels[upgradeType.rawValue] ?? 0
        if currentLevel >= upgradeType.maxLevel { return false }
        
        let cost = calculateUpgradeCost(upgradeType: upgradeType)
        return gameState.currency >= cost
    }
    
    // MARK: - Wool Selling
    func sellWool() {
        guard gameState.wool > 0 else { return }
        
        // Base price: 1 kr per wool
        var woolValue = gameState.wool
        
        // Apply processing upgrade bonus (+20% per level)
        let processingLevel = gameState.upgradeLevels[UpgradeType.processing.rawValue] ?? 0
        let processingBonus = 1.0 + (Double(processingLevel) * UpgradeType.processing.bonusPerLevel)
        woolValue *= processingBonus
        
        gameState.currency += woolValue
        gameState.wool = 0
    }
    
    // MARK: - Manual Click
    func clickWool() {
        let clickLevel = gameState.upgradeLevels[UpgradeType.clickPower.rawValue] ?? 0
        let woolPerClick = 1.0 + Double(clickLevel)
        gameState.wool += woolPerClick
    }
    
    // MARK: - Save/Load
    func saveGame() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(gameState)
            UserDefaults.standard.set(data, forKey: "gameState")
        } catch {
            print("Failed to save game: \(error)")
        }
    }
    
    func loadGame() {
        guard let data = UserDefaults.standard.data(forKey: "gameState") else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            gameState = try decoder.decode(GameState.self, from: data)
            
            // Restart timers if game loaded
            if gameState.selectedRegion != nil {
                startTimers()
            }
        } catch {
            print("Failed to load game: \(error)")
        }
    }
    
    func hasSavedGame() -> Bool {
        return UserDefaults.standard.data(forKey: "gameState") != nil
    }
    
    func deleteSaveGame() {
        UserDefaults.standard.removeObject(forKey: "gameState")
        gameState = GameState()
    }
}
