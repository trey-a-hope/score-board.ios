import Firebase
import FirebaseDatabase
import FontAwesome_swift
import Foundation
import Material
import PopupDialog
import Kingfisher
import SwiftSpinner
import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var chipsLabel: UILabel!
    
    lazy var user: User = User()
    let FONT_AWESOME_ATTRIBUTES: [String : Any] = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20)] as [String: Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(ConnectionManager.isConnectedToInternet()){
            getUser()
        }else{
            ModalService.displayNoInternetAlert(vc: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUserName()
    }
    
    func getUser() -> Void {
        SwiftSpinner.show("Loading...")
        MyFirebaseRef.getUserByID(id: SessionManager.getUserId())
            .then{ (user) -> Void in
                self.user = user
                self.setUI()
            }.catch{ (error) in
                
            }.always{
                SwiftSpinner.hide()
            }
    }
    
    func editProfile() -> Void {
        ModalService.displayNoInternetAlert(vc: self)
    }
    
    func messages() -> Void {
        ModalService.displayNoInternetAlert(vc: self)
    }
    
    func setUI() -> Void {
        /* Edit Profile Button */
        let editProfileButton = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(ProfileViewController.editProfile)
        )
        editProfileButton.setTitleTextAttributes(FONT_AWESOME_ATTRIBUTES, for: .normal)
        editProfileButton.title = String.fontAwesomeIcon(name: .pencil)
        editProfileButton.tintColor = .white
        /* Messages Button */
        let messagesButton = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(ProfileViewController.messages)
        )
        messagesButton.setTitleTextAttributes(FONT_AWESOME_ATTRIBUTES, for: .normal)
        messagesButton.title = String.fontAwesomeIcon(name: .envelope)
        messagesButton.tintColor = .white
        /* Apply buttons to navbar. */
        self.navigationController?.navigationItem.setRightBarButtonItems([editProfileButton, messagesButton], animated: true)
        
        setUserName()
        setProfileImage()
        setChips()
    }

    func setUserName() -> Void {
        self.navigationController?.visibleViewController?.title = user.userName
    }
    
    func setProfileImage() -> Void {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true;
        profileImage.layer.borderWidth = 2.0
        profileImage.layer.borderColor = UIColor.white.cgColor
        //profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageClick)))
        profileImage.isUserInteractionEnabled = true
        if let imageDownloadUrl = user.imageDownloadUrl {
            profileImage.kf.setImage(with: URL(string: imageDownloadUrl))
        }else{
            //TODO: Display empty grey box.
        }
    }
    
    func setChips() -> Void {
        if let chips = user.chips {
            chipsLabel.text = chips.withCommas() + " chips"
        }else{
            chipsLabel.text = "0 chips"
        }
    }
}

