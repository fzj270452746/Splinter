//
//  GameArchive.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import Foundation

struct GameArchive: Codable {
    let identifier: String
    let obtainedScore: Int
    let gameMode: String
    let chronologicalStamp: Date
    
    init(obtainedScore: Int, gameMode: String) {
        self.identifier = UUID().uuidString
        self.obtainedScore = obtainedScore
        self.gameMode = gameMode
        self.chronologicalStamp = Date()
    }
}

class GameArchiveRepository {
    
    static let shared = GameArchiveRepository()
    let archiveKey = "MahjongSplinter_GameArchives"
    
    func persistArchive(_ archive: GameArchive) {
        var archives = retrieveAllArchives()
        archives.insert(archive, at: 0)
        
        // 最多保存50条记录
        if archives.count > 50 {
            archives = Array(archives.prefix(50))
        }
        
        if let encoded = try? JSONEncoder().encode(archives) {
            UserDefaults.standard.set(encoded, forKey: archiveKey)
        }
    }
    
    func retrieveAllArchives() -> [GameArchive] {
        guard let data = UserDefaults.standard.data(forKey: archiveKey),
              let archives = try? JSONDecoder().decode([GameArchive].self, from: data) else {
            return []
        }
        return archives
    }
    
    func obliterateArchive(identifier: String) {
        var archives = retrieveAllArchives()
        archives.removeAll { $0.identifier == identifier }
        
        if let encoded = try? JSONEncoder().encode(archives) {
            UserDefaults.standard.set(encoded, forKey: archiveKey)
        }
    }
    
    func eradicateAllArchives() {
        UserDefaults.standard.removeObject(forKey: archiveKey)
    }
}

