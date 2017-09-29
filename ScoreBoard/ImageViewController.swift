//
//  ImageViewController.swift
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import UIKit

final class ImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        spinner.isHidden = true
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showListAction(_ sender: UIButton) {
        
        if presentingViewController != nil {
            
            _ = navigationController?.popToRootViewController(animated: true)
            
        } else {
            
            _ = navigationController?.popToViewController(navigationController!.viewControllers[1], animated: true)
        }
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        spinner.isHidden = false
        spinner.startAnimating()
        MyFirebaseRef.updateProfilePicture(userId: SessionManager.getUserId(), image: image)
            .then{ () -> Void in
                _ = self.navigationController?.popToViewController(self.navigationController!.viewControllers[0], animated: true)
            }.catch{ (error) in
                ModalService.showError(title: "Error", message: error.localizedDescription)
            }.always{
                self.spinner.stopAnimating()
        }
    }
}
