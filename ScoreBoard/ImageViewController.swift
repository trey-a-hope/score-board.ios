//
//  ImageViewController.swift
//
//  Created by Artem Krachulov.
//  Copyright (c) 2016 Artem Krachulov. All rights reserved.
//  Website: http://www.artemkrachulov.com/
//

import SwiftSpinner
import UIKit

final class ImageViewController: UIViewController {
    
    var image: UIImage!
    
    @IBOutlet weak var imageView: UIImageView!
    
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
        SwiftSpinner.show("Uploading image...")
        MyFirebaseRef.updateProfilePicture(userId: SessionManager.getUserId(), image: image)
            .then{ () -> Void in
                _ = self.navigationController?.popToViewController(self.navigationController!.viewControllers[0], animated: true)
            }.catch{ (error) in
                ModalService.showError(title: "Error", message: error.localizedDescription)
            }.always{
                SwiftSpinner.hide()
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
    }
}