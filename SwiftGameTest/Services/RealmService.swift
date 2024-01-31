//
//  RealmService.swift
//  SwiftGameTest
//
//  Created by student on 2023/12/18.
//

import Foundation
import RealmSwift

class RealmService {
    var realm: Realm?
    ///Realmの初期設定を行う
    func setup() {
    realm = try! Realm()
    print("hoge")
    }
    
    func fetch() -> CharacterModel? {
        let objects = realm?.objects(CharacterDataObject.self)
        guard let object = objects?.first else {
            return nil
        }
        return CharacterModel(object: object)
    }
    
    func save(model: CharacterModel) {
        let object = CharacterDataObject(model: model)
        try! realm?.write({
            if let objects = realm?.objects(CharacterDataObject.self) {
                realm?.delete(objects)
            }
            realm?.add(object)
        })
    }
}
