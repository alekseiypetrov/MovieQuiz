import Foundation


class StatisticService: StatisticServiceProtocol {
    private enum Keys: String {
        case correct
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case gamesCount
        case correctAnswers
        case totalAnswers
    }
    
    private let storage: UserDefaults = .standard
    
    private var totalAnswers: Int {
        get {
            return storage.integer(forKey: Keys.totalAnswers.rawValue)
        }
        set {
            storage.setValue(newValue, forKey: Keys.totalAnswers.rawValue)
        }
    }
    
    private var correctAnswers: Int {
        get {
            return storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.setValue(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.setValue(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            let currentAccuracy = self.gamesCount > 0 ? 100.0 * (Double(self.correctAnswers) / Double(self.totalAnswers)) : 0.0
            return currentAccuracy
        }
    }
    
    func store(currentGame: GameResult) {
        self.correctAnswers += currentGame.correct
        self.totalAnswers += currentGame.total
        self.gamesCount += 1
    }
}

final class StatisticServiceImplementation: StatisticService {
    override func store(currentGame: GameResult) {
        super.store(currentGame: currentGame)
        if currentGame.isBetterThan(self.bestGame) {
            self.bestGame = currentGame
        }
    }
}
