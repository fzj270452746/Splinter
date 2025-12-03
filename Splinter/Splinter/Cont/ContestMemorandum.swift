//
//  ContestMemorandum.swift
//  Splinter
//
//  Created by Zhao on 2025/11/26.
//

import Foundation

struct ContestMemorandum: Codable {
    let identifier: String
    let obtainedScore: Int
    let gameMode: String
    let chronologicalStamp: Date
    
    init(obtainedScore: Int, gameMode: String) {
        self.identifier = UUID().uuidString
        self.obtainedScore = obtainedScore
        self.gameMode = gameMode == "Classic Mode" ? "Arcade Mode" : gameMode
        self.chronologicalStamp = Date()
    }
}

class MemorandumVault {
    
    static let shared = MemorandumVault()
    let archiveKey = "MahjongSplinter_GameArchives"
    let maxRecords = 50
    
    func persistArchive(_ archive: ContestMemorandum) {
        var archives = retrieveAllArchives()
        archives.insert(archive, at: 0)
        
        if archives.count > maxRecords {
            archives = Array(archives.prefix(maxRecords))
        }
        
        saveArchives(archives)
    }
    
    func retrieveAllArchives() -> [ContestMemorandum] {
        guard let data = UserDefaults.standard.data(forKey: archiveKey),
              let archives = try? JSONDecoder().decode([ContestMemorandum].self, from: data) else {
            return []
        }
        return archives
    }
    
    func obliterateArchive(identifier: String) {
        var archives = retrieveAllArchives()
        archives.removeAll { $0.identifier == identifier }
        saveArchives(archives)
    }
    
    func eradicateAllArchives() {
        UserDefaults.standard.removeObject(forKey: archiveKey)
    }
    
    private func saveArchives(_ archives: [ContestMemorandum]) {
        if let encoded = try? JSONEncoder().encode(archives) {
            UserDefaults.standard.set(encoded, forKey: archiveKey)
        }
    }
}

