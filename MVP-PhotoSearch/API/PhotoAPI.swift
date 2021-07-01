//
//  PhotoAPI.swift
//  MVP-PhotoSearch
//
//  Created by Shinichiro Kudo on 2021/06/23.
//

import Foundation

enum APIResponseError: Error, LocalizedError {
    
    case validationError, urlError, taskError
    
    var errorDescription: String? {
        switch self {
        case .validationError:
            return "入力エラーが発生しています"
        case .urlError:
            return "URLが取得出来ませんでした"
        case .taskError:
            return "通信後にデータの取得が出来ませんでした"
        }
    }
    
}

struct PhotoSearchParameters {
    
    private let clientID = "ここにClientIDを入れる"
    
    let searchWord: String?
    // 以下はリクエストURLに入るパラメータ
    private var _searchWord: String { searchWord ?? "" }
    let page: Int = 0
    let perPage: Int = 30
    
    var validation: Bool {
        !_searchWord.isEmpty && perPage <= 50 && perPage > 0
    }
    
    var queryParameter: String {
        "page=\(page)&per_page=\(perPage)&query=\(_searchWord)&client_id=\(clientID)"
    }
    
}

final class PhotoAPI {
    static let shared = PhotoAPI()
    private init() {}
    
    private let baseURL = "https://api.unsplash.com"
    private let searchEndPoint = "/search/photos?"
    
    func get(parameters: PhotoSearchParameters, completion: ((Result<[PhotoModel], APIResponseError>) -> Void)? = nil) {
        
        guard parameters.validation else {
            completion?(.failure(.validationError))
            return
        }
        
        guard let url = URL(string: "\(baseURL)"+"\(searchEndPoint)"+"\(parameters.queryParameter)") else {
            completion?(.failure(.urlError))
            return
        }
        
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data,
                  let photoAPIResponse = try? JSONDecoder().decode(PhotoAPIResponse.self, from: data),
                  let models = photoAPIResponse.results
            else {
                completion?(.failure(.taskError))
                return
            }
            completion?(.success(models)) // get関数のcompletion:Resultとしてmodelsを返している
        })
        
        task.resume()
    }
    
}
