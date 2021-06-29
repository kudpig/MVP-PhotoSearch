//
//  SearchPhotoViewController.swift
//  MVP-PhotoSearch
//
//  Created by Shinichiro Kudo on 2021/06/22.
//

import UIKit

class SearchPhotoViewController: UIViewController {
    
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
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
}
