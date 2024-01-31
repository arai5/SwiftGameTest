//
//  ViewController.swift
//  SwiftGameTest
//
//  Created by student on 2023/11/15.
//

import UIKit

class ViewController: UIViewController {
    
    let realmService = RealmService()
    
    var characterTask: Task<Void, Never>?
    
    var updateCharacterModelTask: Task<Void, Never>?
    
    var dateUpdateTask: Task<Void, Never>?
    
    @IBOutlet weak var bottomBaseView: UIView!
    
    @IBOutlet weak var lifePointValueLabel: UILabel!
    
    @IBOutlet weak var comfyPointValueLabel: UILabel!
    
    @IBOutlet weak var favPointValueLabel: UILabel!
    
    @IBOutlet weak var eatButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var cleaningButton: UIButton!
    
    @IBOutlet weak var topBaseView: UIView!
    
    @IBOutlet var characterImageViews: [UIImageView]!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    
    
    @IBAction func didTapEatButton(_ sender: UIButton) {
        guard var model = realmService.fetch() else { return }
        model.feeding()
        updateCharacterModel(model)
                
    }
    
    @IBAction func didTapPlayButton(_ sender: UIButton) {
        guard var model = realmService.fetch() else { return }
        model.favorabilityUp(value: Int.random(in: 1...10))
        realmService.save(model: model)
        updateCharacterModel(model)
    }
    
    
    @IBAction func didTapCleanButton(_ sender: UIButton) {
        guard var model = realmService.fetch() else { return }
        model.toiletCleaning()
        realmService.save(model: model)
        updateCharacterModel(model)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realmService.setup()
        topViewSetup()
        bottomViewSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        launchSetupCharacterData()
        updateCharacterPosition()
        updateDateLabel()
        setupUpdateCharacterModelTask()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isNeedDeathProcess() {
            deathProcessTask()
        }
    }

    func topViewSetup() {
        // 枠線の色を指定します
        topBaseView.layer.borderColor = UIColor.label.cgColor
        // 枠線の太さを指定します
        topBaseView.layer.borderWidth = 1.0
        // 角丸の指定を行います
        topBaseView.layer.cornerRadius = 25.0
        // 上側だけに角丸を付与する指定
        topBaseView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    /// Viewのセットアップを行うメソッド
    func bottomViewSetup() {
        // 枠線の色を指定します
        bottomBaseView.layer.borderColor = UIColor.label.cgColor
        // 枠線の太さを指定します
        bottomBaseView.layer.borderWidth = 1.0
        // 角丸の指定を行います
        bottomBaseView.layer.cornerRadius = 25.0
        // 上側だけに角丸を付与する指定
        bottomBaseView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    ///起動中のキャラクターモデルの更新タスクを生成する
    func setupUpdateCharacterModelTask() {
        updateCharacterModelTask = Task  { @MainActor in
            let latestDate = Date()
            try? await Task.sleep(nanoseconds: 5 * 1000000000)
            let model = realmService.fetch() ?? makeNewCharacter()
            updateCharacterModelWithElapsedTime(model: model, lastUpdateDate:latestDate)
            guard !isNeedDeathProcess() else { return }
            setupUpdateCharacterModelTask()
        }
    }
    
    // 新しいキャラクターモデルを作成するメソッド
    /// - Returns: CharacterModel
    func makeNewCharacter() -> CharacterModel {
        let characterModel = CharacterModel()
        realmService.save(model: characterModel)
        return characterModel
    }
    
    // MARK: Read
    ///死亡処理を行うか
    /// - Returns: 判定結果
    func isNeedDeathProcess() -> Bool {
        guard let model = realmService.fetch() else {
            return false
        }
        if model.currentHitPoint == 0 {
            return true
        }
        if model.dateOfDeath < Date() {
            return true
        }
        return false
    }
    
    func updateCharacterPosition() {
        characterTask = Task { @MainActor in
            characterImageViews.forEach { view in
                // すべてのimageViewの画像をnilに設定
                view.image = nil
            }
            if let imageView = characterImageViews.randomElement() {
                imageView.image = UIImage(named: "CharacterDemoImage")
            }
            try? await Task.sleep(nanoseconds: 5 * 1000000000)
            // 再帰的に更新を行う
            updateCharacterPosition()
        }
    }

    
    func updateDateLabel() {
        dateUpdateTask = Task { @MainActor in
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .init(identifier: "ja_JP")
            dateFormatter.dateFormat = "MM/dd"
            dateLabel.text = dateFormatter.string(from: now)
            dateFormatter.dateFormat = "EEEE"
            dayOfWeekLabel.text = "(\(dateFormatter.string(from: now)))"
            try? await Task.sleep(nanoseconds: 60 * 60 * 000000000)
            updateDateLabel()
        }
    }
    
    /// 引数で渡したキャラクターモデルを保存し、ラベルに反映する
    ///  - Parameter model: CharacterModel
    func updateCharacterModel(_ model: CharacterModel) {
        realmService.save(model: model)
        updateCharacterStatusLabel(model: model)
        if isNeedDeathProcess() {
            // 死亡処理
            deathProcessTask()
        }
    }

    
    ///最終の更新を元にキャラクターのステータス値を更新する
    /// - Parameters:
    /// - model: characterModel
    /// - lastUpdateDate: Data
    
    /// - Returns: 更新したキャラクターモデル
    func updateCharacterModelWithElapsedTime(model: CharacterModel, lastUpdateDate: Date) {
        // キャラクターモデルの取得または新規作成
        var characterModel: CharacterModel = model
        // 現在の時間との差を取得
        let time = Date().timeIntervalSince(lastUpdateDate)
        let hour = Double(time / 3600)

        // ランダムな減少値を生成
            let decrementValue = Int.random(in: 1...10)

            // 各パラメータをランダムな減少値で減算
            characterModel.currentHitPoint -= decrementValue
            characterModel.livingEnvironment -= decrementValue
            characterModel.favorabilityRating -= decrementValue

            // 各パラメータが0未満にならないようにする
            characterModel.currentHitPoint = max(characterModel.currentHitPoint, 0)
            characterModel.livingEnvironment = max(characterModel.livingEnvironment, 0)
            characterModel.favorabilityRating = max(characterModel.favorabilityRating, 0)
        
            //進化への挑戦
        characterModel.challengeEvolution()
        // キャラクターモデルの状態を更新
            updateCharacterModel(characterModel)
    }

    // ラベルなどのUIを更新するメソッド
    func updateCharacterStatusModel(_ characterModel: CharacterModel) {
        lifePointValueLabel.text = "\(characterModel.currentHitPoint) / \(characterModel.maxHitPoint)"
        comfyPointValueLabel.text = "\(characterModel.livingEnvironment) / 10"
        favPointValueLabel.text = "\(characterModel.favorabilityRating) / 10"
    }

    // 最終起動日時を取得するメソッド
    func fetchLastLaunchDate() -> Date? {
        guard let lastDate = UserDefaults.standard.object(forKey: "last_date") as? Date else {
            return nil
        }
        return lastDate
    }

    func updateCharacterStatusLabel(model: CharacterModel) {
        lifePointValueLabel.text = "\(model.currentHitPoint) / \(model.maxHitPoint)"
        comfyPointValueLabel.text = "\(model.livingEnvironment) / 10"
        favPointValueLabel.text = "\(model.favorabilityRating) / 10"
    }
    
    // 最終起動日時を更新するメソッド
    func updateLastLaunchDate() {
        UserDefaults.standard.set(Date(), forKey: "last_date")
    }
    
    func launchSetupCharacterData() {
        let lastLaunchData = fetchLastLaunchDate() ?? Date()
        var model = realmService.fetch() ?? makeNewCharacter()
        realmService.save(model: model)
        guard model.currentHitPoint != 0 else {
            //エラー処理
            return
        }
        updateCharacterStatusLabel(model: model)
    }
    
    
    func deathProcessTask() {
        if let isCancelled = updateCharacterModelTask?.isCancelled {
                print(isCancelled)
            } else {
                print("Task is not cancelled")
            }
        
        updateCharacterModelTask?.cancel()
        
        if let isCancelledAfterCancellation = updateCharacterModelTask?.isCancelled {
               print(isCancelledAfterCancellation)
           } else {
               print("Task is not cancelled after cancellation")
           }
        
        let alert = UIAlertController(
            title: "死んでしまいました",
            message: "OKボタンでタップを再開すると新しいキャラクターで再開します",
            preferredStyle: .alert
        )
        alert.addAction(.init(title: "OK", style: .default, handler: { _ in
            let newCharacterModel = self.makeNewCharacter()
            self.realmService.save(model: newCharacterModel)
            self.updateCharacterStatusLabel(model: newCharacterModel)
            self.setupUpdateCharacterModelTask()
        }))
        present(alert, animated: true)
    }

}
