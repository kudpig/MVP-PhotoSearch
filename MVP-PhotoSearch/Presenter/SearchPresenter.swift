//
//  SearchPresenter.swift
//  MVP-PhotoSearch
//
//  Created by Shinichiro Kudo on 2021/06/23.
//

import Foundation

// 入力
protocol SearchPresenterInput: AnyObject {
    var numberOfItems: Int { get } // VCテーブルビューの構築時(リロード)に呼ばれる
    func item(index: Int) -> PhotoModel // VCテーブルビューの構築時(リロード)に呼ばれる
    func search(parameters: PhotoSearchParameters)
    
}
// 出力
protocol SearchPresenterOutput: AnyObject {
    func update(photoModels: [PhotoModel])
    func displayUpdate(loading: Bool)
    func get(error: Error)
}


final class SearchPresenter {
    
    // プレゼンターはoutputを保持
    private weak var output: SearchPresenterOutput?
    private let api: PhotoAPI = PhotoAPI.shared
    private var photoModels: [PhotoModel] = [] // APIを叩いた結果のsuccessデータの保持用

    init(output: SearchPresenterOutput) {
        self.output = output
    }
}

extension SearchPresenter: SearchPresenterInput {
    
    // VCのテーブルビューがリロードされたときに、Presenterがその時保持しているModelsのカウントを返す
    // リロードされるタイミングはsearchメソッド実行後(api.updateされたとき)
    var numberOfItems: Int { photoModels.count }

    // VCのテーブルビューがリロードされたときに、Presenterがその時保持している[PhotoModel]の中からindexのものを返す
    func item(index: Int) -> PhotoModel { photoModels[index] }
    
    func search(parameters: PhotoSearchParameters) {
        
        self.output?.displayUpdate(loading: true)
        // ここからAPI叩いていく
        self.api.get(parameters: parameters, completion: { [weak self] (result) in
            // resultの内容で処理を分岐させる
            switch result {
            case .success(let photoModels): // resultデータに`photoModels`という定数名をつけた
                self?.photoModels = photoModels
                self?.output?.displayUpdate(loading: false)
                self?.output?.update(photoModels: photoModels)
            case .failure(let error):
                self?.output?.get(error: error)
            }
        }) // ここまでapi.getメソッド
    }
    
}
