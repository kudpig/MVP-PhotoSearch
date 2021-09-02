## MVP-PhotoSearch

UnsplushAPIを利用した写真検索機能の実装

## Why

- MVPアーキテクチャによる実装の練習
- 外部APIを叩く練習
- CollectionViewの基本的な内容おさらい

## Preview

<img src="https://i.gyazo.com/03d522ad4687709d73d199c265b993eb.gif" width="400">

## 使用技術など

- Xcode
- UIKit
- MVP (アーキテクチャ)
- Github (バージョン管理)
- CocoaPods (ライブラリ管理)
  - Kingfisher
  - AlamofireImage
- UnsplushAPI (外部API)

`Kingfisher`と`AlamofireImage`がインストールされてますが、AlamofireImageを採用しています。
レスポンスがResult型で返ってくる方がしっくりきます。

## 実際のコード

※ClientIDは伏せています

### AppDelegate

```AppDelegate.swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        Router.showRoot(window: window)  
        return true
    }
}
```

### Router

```Router.swift
import UIKit

final class Router {

    static func showRoot(window: UIWindow?) {
        let storyboard = UIStoryboard(name: "SearchPhoto", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! SearchPhotoViewController
        let nav = UINavigationController(rootViewController: vc)
        let presenter = SearchPresenter(output: vc)
        vc.inject(presenter: presenter)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    } 

    private static func show(fromVC: UIViewController, nextVC: UIViewController) {
        if let nav = fromVC.navigationController {
            nav.pushViewController(nextVC, animated: true)
        } else {
            fromVC.present(nextVC, animated: true, completion: nil)
        }
    }   
}
```

### API

```swift
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
            completion?(.success(models))
        })
        
        task.resume()
    }
}
```

### Model

```swift
import Foundation

struct PhotoAPIResponse: Codable {
    let results: [PhotoModel]?
}

struct PhotoModel: Codable {
    let id: String
    let urls: URLS
}

struct URLS: Codable {
    let regular: String
}
```

### Presenter

```swift
import Foundation

// 入力
protocol SearchPresenterInput: AnyObject {
    var numberOfItems: Int { get }
    func item(index: Int) -> PhotoModel
    func search(parameters: PhotoSearchParameters)
    
}
// 出力
protocol SearchPresenterOutput: AnyObject {
    func update(photoModels: [PhotoModel])
    func displayUpdate(loading: Bool)
    func get(error: Error)
}


final class SearchPresenter {
    
    private weak var output: SearchPresenterOutput?
    private let api: PhotoAPI = PhotoAPI.shared
    private var photoModels: [PhotoModel] = []

    init(output: SearchPresenterOutput) {
        self.output = output
    }
}

extension SearchPresenter: SearchPresenterInput {
    
    var numberOfItems: Int { photoModels.count }

    func item(index: Int) -> PhotoModel { photoModels[index] }
    
    func search(parameters: PhotoSearchParameters) {      
        self.output?.displayUpdate(loading: true)
        self.api.get(parameters: parameters, completion: { [weak self] (result) in
            switch result {
            case .success(let photoModels):
                self?.photoModels = photoModels
                self?.output?.displayUpdate(loading: false)
                self?.output?.update(photoModels: photoModels)
            case .failure(let error):
                self?.output?.get(error: error)
            }
        })
    }
}
```

### ViewController

```swift
import UIKit

final class SearchPhotoViewController: UIViewController {
    
    @IBOutlet private weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    @IBOutlet private weak var searchButton: UIButton! {
        didSet {
            searchButton.addTarget(self, action: #selector(tapSearchButton(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet private weak var photoCollectionView: UICollectionView! {
        didSet {
            photoCollectionView.register(UINib(nibName: PhotoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            photoCollectionView.collectionViewLayout = layout
            photoCollectionView.delegate = self
            photoCollectionView.dataSource = self
        }
    }
    
    @objc private func tapSearchButton(_ button: UIButton) {
        searchTextField.endEditing(true)
        let parameters = PhotoSearchParameters.init(searchWord: searchTextField.text)
        self.presenter.search(parameters: parameters)
    }
    
    private var presenter: SearchPresenterInput!
    func inject(presenter: SearchPresenterInput) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoCollectionView.isHidden = true
    }

}

extension SearchPhotoViewController: SearchPresenterOutput {
    
    func displayUpdate(loading: Bool) {
        DispatchQueue.main.async {
            self.photoCollectionView.isHidden = loading
        }
    }
    
    func update(photoModels: [PhotoModel]) {
        DispatchQueue.main.async {
            self.photoCollectionView.reloadData()
        }
    }
    
    func get(error: Error) {
        DispatchQueue.main.async {
            print(error.localizedDescription)
        }
    }  
}

extension SearchPhotoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.numberOfItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
        return UICollectionViewCell()
        }
        let model = presenter.item(index: indexPath.row)
        cell.configure(model: model)
        return cell
    }
    
}

extension SearchPhotoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace : CGFloat = 20
        let cellSize : CGFloat = self.view.bounds.width / 2 - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }
    
}

extension SearchPhotoViewController: UICollectionViewDelegate {
    // cell.didSelect
}

extension SearchPhotoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
```

### Cell

```swift
import UIKit
import AlamofireImage

final class PhotoCollectionViewCell: UICollectionViewCell {

    static var identifier: String { String(describing: PhotoCollectionViewCell.self) }
    
    @IBOutlet private weak var imageView: UIImageView!
    
    func configure(model: PhotoModel) {
        
        let urlString = model.urls.regular
        
        if let url = URL(string: urlString) {
            imageView.af.setImage(withURL: url, completion: { [weak self] response in
                switch response.result {
                case .success(_):
                    break
                case .failure(_):
                    self?.imageView.image = Image(named: "placeholderImage")
                break
                }
            })
        }
    }
}
```
