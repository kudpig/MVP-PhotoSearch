//
//  PhotoCollectionViewCell.swift
//  MVP-PhotoSearch
//
//  Created by Shinichiro Kudo on 2021/06/22.
//

import UIKit
import AlamofireImage

class PhotoCollectionViewCell: UICollectionViewCell {

    static var identifier: String { String(describing: PhotoCollectionViewCell.self) }
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
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
