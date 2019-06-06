//
//  ImageListViewControllerCell.swift
//  iPic
//
//  Created by rigo on 06/06/2019.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

protocol ImageListViewControllerCellDelegate {
    func cellPhotoClicked(_ photo: Photo)
}

class ImageListViewControllerCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var photo: Photo!
    var delegate: ImageListViewControllerCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        photoImageView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        delegate?.cellPhotoClicked(photo)
    }
    
    override func prepareForReuse() {
        photoImageView.image = nil
    }
}
