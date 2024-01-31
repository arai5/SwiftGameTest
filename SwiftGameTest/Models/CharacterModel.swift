//
//  CharacterModel.swift
//  SwiftGameTest
//
//  Created by student on 2023/11/15.
//

import Foundation

struct CharacterModel {
    
    ///成長段階
    enum GrowthState: Int {
        ///幼少期
        case childhood
        ///成長期
        case growthPeriod
        ///成熟期
        case maturity
    }
    
    ///現在の成長段階
    var currentGrowthState: GrowthState
    ///現在の体力値
    var currentHitPoint: Int
    ///最大の体力値
    var maxHitPoint: Int
    ///現在の生活環境
    var livingEnvironment: Int
    ///現在の好感度
    var favorabilityRating: Int
    ///最後に餌をあげた日時
    var lastFeedDate: Date?
    ///餌をあげた回数
    var last12HourFeedCount: Int
    ///死亡確定日
    var dateOfDeath: Date
    ///成長係数
    var growthFactor: Int {
        max(1, favorabilityRating * 10 / 10)
    }
    
    ///既に死んでいるか
    var isDead: Bool {
        let timeInterval = Date().timeIntervalSince(dateOfDeath)
        // 0より大きい値の場合は、推定日よりも後なので死亡判定とする
        return (0 <= timeInterval)
    }
    init () {
        self.currentGrowthState = .childhood
        self.currentHitPoint = 10
        self.maxHitPoint = 10
        self.livingEnvironment = 10
        self.favorabilityRating = 10
        self.lastFeedDate = nil
        self.last12HourFeedCount = 0
        let randum = Int.random(in: 14..<28)
        self.dateOfDeath = Calendar.current.date(byAdding: .day, value: randum, to: Date())!
    }
    
    init(object: CharacterDataObject) {
        self.currentGrowthState = .init(rawValue: object.currentGrowthState) ?? .maturity
        self.currentHitPoint = object.currentHitPoint
        self.maxHitPoint = object.maxHitPoint
        self.livingEnvironment = object.livingEnvironment
        self.favorabilityRating = object.favorabilityRating
        self.lastFeedDate = object.lastFeedDate
        self.last12HourFeedCount = object.last12HourFeedCount
        self.dateOfDeath = object.dateOfDeath
    }
    
    ///餌をあげる
    mutating func feeding() {
        var isPassed: Bool = true
            //　最後の餌やりの時間から12時間以上経過しているか判別する
        if let lastFeedDate = lastFeedDate
        {
            //　最後の餌やりの時間が記載されている場合は、経過時間を算出
            let timeInterval = Date().timeIntervalSince(lastFeedDate)
            let time = Int(timeInterval)
            let hour = time / 3600 % 24
            //　12時間を超えていない場合は、falseになる
            isPassed = (12 < hour)
        }
        // 回復値を生成する
        let recoveryValue: Int
        if !isPassed {
            self.last12HourFeedCount += 1
            //　複数回の回復は、１しか回復させない
            recoveryValue = 1
        }
        else
        {
            //12時間経過している場合は、０に戻す
            self.last12HourFeedCount = 0
            //12時間ぶりの回復の場合はランダムで回復値を変化させる
            recoveryValue = Int.random(in: 1..<10)
        }
        //　餌をあげた日時を更新する
        lastFeedDate = Date()
        //　餌をあげたので体力を回復させる
        //　min関数を用いて、上限の体力値より高い体力を設定しないようにする
        currentHitPoint = min(maxHitPoint, (currentHitPoint + recoveryValue))
}
    
    ///　トイレ掃除
    mutating func toiletCleaning() {
        // トイレの場合は生活環境を最大にする。
        livingEnvironment = 10
    }
    
    ///　好感度アップ
    ///　ー　Parameter value; 遊ぶ種類によって異なる好感度の値
    mutating func favorabilityUp(value: Int) {
        favorabilityRating = min(10, favorabilityRating + value)
    }
    
    /// 進化に挑戦する
    mutating func challengeEvolution() {
        //残りの推定日までをの残りの日数を算出
        guard let remainingDays = Calendar.current.dateComponents([.day], from: Date(), to: dateOfDeath).day else {
            return
        }
        switch currentGrowthState {
        case .childhood where 7 < remainingDays:
            guard remainingDays < 23 else { return }
            // 幼少期から成長期への切り替え　死亡推定日まで７日以上であること
            if 5 < livingEnvironment, 3 < favorabilityRating, 8 < currentHitPoint {
                // 環境値が５以上、好感度が３以上、体力が８以上の時に成長過程を進める
                currentGrowthState = .growthPeriod
                //　乱数値に係数をかけたものを次の最大の体力値とする
                currentHitPoint = Int.random(in: currentHitPoint...maxHitPoint) * growthFactor
            }
        default:
            //残りの日数を成長係数を引いたときに、３以下になった場合は成熟期への移行と判断する
            let isMaturity = (remainingDays - growthFactor) < 3
            guard isMaturity else { return }
            currentGrowthState = .maturity
            maxHitPoint = min(currentHitPoint, maxHitPoint - Int.random(in: 2..<6))
        }
    }
}
