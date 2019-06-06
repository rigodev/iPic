//
//  ImageListViewController.swift
//  iPic
//
//  Created by rigo on 06/06/2019.
//  Copyright © 2019 dev. All rights reserved.
//

import UIKit

class ImageListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var foundedPhotos = [Photo]() {
        didSet {
            tableView?.reloadData()
        }
    }
    
    private let viewModel: ImageListViewModelProtocol!
    
    required init?(coder aDecoder: NSCoder) {
        
        viewModel = ImageListViewModel()
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupControls()
    }
    
    private func setupControls() {
        tableView?.rowHeight = 80
    }
}

// MARK: - UITableViewDataSource
extension ImageListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundedPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCellId", for: indexPath) as! ImageListViewControllerCell
        
        let photo = foundedPhotos[indexPath.row]
        
        cell.photo = photo
        cell.delegate = self
        cell.titleLabel.text = photo.title
        cell.activityIndicator.startAnimating()
        
        viewModel.fetchThumbnail(forPhoto: photo) { [weak cell] result in
            cell?.activityIndicator.stopAnimating()
            
            switch result {
                
            case .success(let image):
                cell?.photoImageView.image = image
                
            case .failure(let error):
                cell?.photoImageView.image = UIImage(named: "no-photo")
                
                print("Error: \(error)")
            }
        }
        
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension ImageListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
        
        guard let searchString = searchBar.text else {
            return
        }
        
        searchingPhotos(forString: searchString)
    }
    
    func searchingPhotos(forString searchString: String) {
        
        foundedPhotos.removeAll()
        
        activityIndicator.startAnimating()
        
        viewModel.fetchPhotos(forString: searchString) { [weak self] result in
            
            self?.searchBar.isHidden = false
            self?.activityIndicator.stopAnimating()
            
            switch result {
                
            case .failure(let error):
                
                let alert = UIAlertController(title: "Flickr Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
                
                self?.present(alert, animated: true, completion: nil)
                
            case .success(let photos):
                self?.foundedPhotos = photos
            }
        }
    }
}

// MARK: - ImageListViewControllerCellDelegate
extension ImageListViewController: ImageListViewControllerCellDelegate {
 
    func cellPhotoClicked(_ photo: Photo) {
        performSegue(withIdentifier: "ImageList2ImageDetail", sender: photo)
    }
}

// MARK: - Navigation
extension ImageListViewController {
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let id = segue.identifier, id == "ImageList2ImageDetail", let photo = sender as? Photo,
            let destination = segue.destination as? ImageDetailViewController {
            destination.photo = photo
        }
    }
}
