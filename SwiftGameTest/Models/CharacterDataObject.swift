//
//  CharacterDataObject.swift
//  SwiftGameTest
//
//  Created by student on 2023/12/06.
//

import Foundation
import RealmSwift

class CharacterDataObject: Object {
    ///現在の成長段階
    @Persisted var currentGrowthState: Int
    ///現在の体力値
    @Persisted var currentHitPoint: Int
    ///最大の体力値
    @Persisted var maxHitPoint: Int
    ///現在の生活環境
    @Persisted var livingEnvironment: Int
    ///現在の好感度
    @Persisted var favorabilityRating: Int
    ///最後に餌をあげた日時
    @Persisted var lastFeedDate: Date?
    ///餌をあげた回数
    @Persisted var last12HourFeedCount: Int
    ///死亡確定日
    @Persisted var dateOfDeath: Date
    
    override init() {
        super.init()
    }
    
    init(model: CharacterModel) {
        self.currentGrowthState = model.currentGrowthState.rawValue
        self.currentHitPoint = model.currentHitPoint
        self.maxHitPoint = model.maxHitPoint
        self.livingEnvironment = model.livingEnvironment
        self.favorabilityRating = model.favorabilityRating
        self.lastFeedDate = model.lastFeedDate
        self.last12HourFeedCount = model.last12HourFeedCount
        self.dateOfDeath = model.dateOfDeath
    }
}
