//
//  ImageDetailViewController.swift
//  iPic
//
//  Created by rigo on 06/06/2019.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photo: Photo?
    let viewModel: ImageDetailViewModelProtocol!

    required init?(coder aDecoder: NSCoder) {

        viewModel = ImageDetailViewModel()

        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupControls()
    }
    
    func setupControls() {
        
        activityIndicator.startAnimating()
        
        guard let photo = photo else {
            activityIndicator.stopAnimating()
            return
        }
        
        viewModel.fetchDetail(forPhoto: photo) { [weak photoImageView, weak activityIndicator, weak dateTimeLabel, weak photo] result in
            
            activityIndicator?.stopAnimating()
            
            switch result {
                
            case .success(let image):
                
                if let loadImageTime = photo?.loadImageTime {
                    dateTimeLabel?.text = "Дата загрузки: \(loadImageTime)"
                }
                
                photoImageView?.image = image
                
            case .failure(let error):
                dateTimeLabel?.text = "Не удалось загрузить изображение"
                photoImageView?.image = UIImage(named: "no-photo-big")
                
                print("Error: \(error)")
            }
        }
    }
}
