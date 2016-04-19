//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Joseph Hooper on 4/14/16.
//  Copyright © 2016 josephdhooper. All rights reserved.
//  Code from https://github.com/jarrodparkes/virtual-tourist.git and other Udacity-focused repositories was repurposed for this project.

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pin : Pin!
    
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin!.getCoordinate()
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegionMake(pin!.getCoordinate(), span)
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
        
        updateBottomButton()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            showError("Failed to fetch results controller.")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if (pin.photos.isEmpty) {
            loadPhoto()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        let itemWidth = floor((collectionView.frame.size.width - 1)/3)
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
//        collectionView.reloadData()
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()

        
    }
    

    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    func configureCell(cell: PhotoCell, atIndexPath indexPath: NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        if photo.photoImage != nil {
            cell.imageView.hidden = false
            cell.imageView.image = photo.photoImage
        }
        else {
            cell.activityIndicator.startAnimating()
            cell.imageView.hidden = true
            FlickrClient.sharedInstance.getImage(photo.imageUrl) {
                (imageData, error) in
                if let downloadError = error {
                    print("download image error: \(downloadError)")
                }
                else {
                    if let image = UIImage(data: imageData!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.imageView.hidden = false
                            cell.imageView.image = image
                            cell.activityIndicator.stopAnimating()
                            
                            photo.photoImage = image
                        }
                    }
                }
            }
        }
        
        if let _ = selectedIndexes.indexOf(indexPath) {
            cell.imageView.alpha = 0.5
        } else {
            cell.imageView.alpha = 1.0
        }
    }
    
    @IBAction func bottomButtonTouch(sender: AnyObject) {
        
        if selectedIndexes.count > 0 {
            deleteSelectedItems()
        }
        else {
            deleteAllPhotos()
            loadPhoto()
        }
    }
    
    func loadPhoto() {
        bottomButton.enabled = false
        FlickrClient.sharedInstance.getPhotos(pin!.latitude, longitude: pin!.longitude) {
            (result, error) in
            if (error != nil) {
                self.showError("error downloading photos: \(error)")
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    let photos = Photo.photosFromResult(result, context: self.sharedContext)
                    for photo in photos {
                        photo.pin = self.pin
                    }
                    CoreDataStackManager.sharedInstance().saveContext()
                    
                    
                }
                
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.bottomButton.enabled = true
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
        
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        configureCell(cell, atIndexPath: indexPath)
        
        updateBottomButton()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            // Here we are noting that a new Photo instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            // Here we are noting that a Photo instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            // We don't expect Photo instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            print("Move an item. We don't expect to see this in this app.")
            break
//        default:
//            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView.performBatchUpdates(
                {
                    () -> Void in
                    for indexPath in self.insertedIndexPaths {
                        self.collectionView.insertItemsAtIndexPaths([indexPath])
                    }
                    for indexPath in self.deletedIndexPaths {
                        self.collectionView.deleteItemsAtIndexPaths([indexPath])
                    }
                    for indexPath in self.updatedIndexPaths {
                        self.collectionView.reloadItemsAtIndexPaths([indexPath])
                    }
                }
                ,completion: nil)
        }
    }
    
    func updateBottomButton() {
        if selectedIndexes.count > 0 {
            bottomButton.title = "Remove Selected Photos"
        } else {
            bottomButton.title = "New Collection"
        }
    }
    
    func deleteSelectedItems() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            sharedContext.deleteObject(photo)
        }
        CoreDataStackManager.sharedInstance().saveContext()
        
        selectedIndexes = [NSIndexPath]()
    }
    
    func deleteAllPhotos() {
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func showError(error: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "", message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
