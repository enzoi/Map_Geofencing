//
//  PhotoAlbumViewController.swift
//  Map_Geofencing
//
//  Created by Yeontae Kim on 3/8/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit

class PhotoAlbumViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let headerId = "headerId"
    let cellId = "cellId"
    
    var photoStore: PhotoStore!
    var plant: Plant!
    
    var selectedImageURL: URL?
    var imageURLs = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let plantName = plant.scientificName else { return }
        
        self.title = plantName
        
        collectionView?.backgroundColor = .lightGray
        collectionView?.register(PhotoViewHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(PhotoViewCell.self, forCellWithReuseIdentifier: cellId)
        
        let url = photoStore.getURL(plantName: plantName)
        
        photoStore.fetchFlickrPhotos(fromParameters: url, completion: { (imagesResult) in
            
            switch imagesResult {
            case let .success(urls):
                self.imageURLs = urls
                
            case .failure(_):
                self.imageURLs.removeAll()
            }
            self.collectionView?.reloadSections(IndexSet(integer: 0))
        })
    }

    
    // MARK: - UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImageURL = imageURLs[indexPath.item]
        self.collectionView?.reloadData()
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    var header: PhotoViewHeaderCell?
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath)
            as! PhotoViewHeaderCell
        
        self.header = header
        
        // Get selected image using URL
        if let selectedImageURL = selectedImageURL {

            photoStore.fetchFromURL(for: selectedImageURL, completion: { (result) -> Void in
                guard case let .success(image) = result else { return }
                header.photoImageView.image = image
            })
        
        } else {
            
            if let selectedImageURL = imageURLs.first {
                photoStore.fetchFromURL(for: selectedImageURL, completion: { (result) -> Void in
                    guard case let .success(image) = result else { return }
                    header.photoImageView.image = image
                })
            }
        }
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoViewCell
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        let imageURL = imageURLs[indexPath.item]
        
        photoStore.fetchFromURL(for: imageURL, completion: { (result) -> Void in
            
            guard let imageIndex = self.imageURLs.index(of: imageURL),
                case let .success(image) = result else {
                    return
            }
            
            self.photoStore.imageStore.setImage(image, forKey: imageURL.absoluteString)
            
            let imageIndexPath = IndexPath(item: imageIndex, section: 0)
            
            // When the request finishes, only update the cell if it's still visible
            if let cell = self.collectionView?.cellForItem(at: imageIndexPath) as? PhotoViewCell {
                cell.update(with: image)
            }
        })
    }
}

