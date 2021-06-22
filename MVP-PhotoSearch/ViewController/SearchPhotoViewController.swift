//
//  SearchPhotoViewController.swift
//  MVP-PhotoSearch
//
//  Created by Shinichiro Kudo on 2021/06/22.
//

import UIKit

class SearchPhotoViewController: UIViewController {

    @IBOutlet weak var photoCollectionView: UICollectionView! {
        didSet {
            photoCollectionView.register(UINib(nibName: PhotoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
            
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            photoCollectionView.collectionViewLayout = layout
            
            photoCollectionView.delegate = self
            photoCollectionView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

extension SearchPhotoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
        return UICollectionViewCell()
      }

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
    
}
