import Firebase
import Material
import UIKit

class EditProfileViewController: UIViewController {
    @IBOutlet weak var userName: TextField!
    @IBOutlet weak var phoneNumber: TextField!
    @IBOutlet weak var city: TextField!
    @IBOutlet weak var state: TextField!
    @IBOutlet weak var gender: UISegmentedControl!
    
    let statePickerView: UIPickerView = UIPickerView()
    let stateOptions: [String] = UIPickerViewOptions.states
    var saveBtn: FABButton!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(ConnectionManager.isConnectedToInternet()){
            prepareFABButton()
            getUser()
        }else{
            ModalService.showError(title: "Sorry", message: "No Internet")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func prepareFABButton() -> Void {
        saveBtn = FABButton(image: Icon.check, tintColor: .white)
        saveBtn.pulseColor = .white
        saveBtn.backgroundColor = Color.orange.base
        saveBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(save)))
        view.layout(saveBtn)
            .width(65)
            .height(65)
            .bottomRight(bottom: 35, right: 35)
    }
    
    func save() -> Void {
        if(!formValid()){
            ModalService.showError(title: "Error", message: "Form not valid")
        }else{
            let json = JSONSerializer.toJson(user)
            print(json)
            
            user.userName = userName.text!
            user.userNameLower = userName.text!.lowercased()
            user.phoneNumber = phoneNumber.text!
            user.city = city.text!
            user.stateId = statePickerView.selectedRow(inComponent: 0)
            user.gender = gender.selectedSegmentIndex == 0 ? "F" : "M"

            MyFSRef.updateUser(user: user)
                .then{ () -> Void in
                    //Display success message.
                    ModalService.showSuccess(title: "Success", message: "Profile updated.")
                }.always{}
        }
    }
    
    func formValid() -> Bool {
        if(userName.text == ""){
            return false
        }
        if(phoneNumber.text?.characters.count != 10){
            return false
        }
        if(city.text == ""){
            return false
        }
        if(state.text == ""){
            return false
        }
        return true
    }
    
    func getUser() -> Void {
        MyFSRef.getUserById(id: SessionManager.getUserId())
            .then{ (user) -> Void in
                self.user = user
                self.initUI()
            }.always{}
    }
    
    func initUI() -> Void {
        hideKeyboardWhenTappedAround()
        
        //Configure states
        statePickerView.delegate = self
        statePickerView.dataSource = self
        state.inputView = statePickerView
        
        //Configure UISegmentControl
        gender.tintColor = Constants.primaryColor
        
        //Set username
        if let _ = user.userName {
            userName.text = user.userName
        }
        
        //Set phonenumber
        if let _ = user.phoneNumber {
            phoneNumber.text = user.phoneNumber
        }
        
        //Set city
        if let _ = user.city {
            city.text = user.city
        }
        
        //Set state
        if let _ = user.stateId {
            statePickerView.selectRow(user.stateId, inComponent: 0, animated: false)
            state.text = stateOptions[statePickerView.selectedRow(inComponent: 0)]
        }
        
        //Set gender
        if let _ = user.gender {
            if(user.gender == "F"){
                gender.selectedSegmentIndex = 0
            }else{
                gender.selectedSegmentIndex = 1
            }
        }
    }
}

extension EditProfileViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView {
            case statePickerView:
                return 1
            default:
                return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
            case statePickerView:
                return stateOptions.count
            default:
                return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
            case statePickerView:
                return stateOptions[row]
            default:
                return "Null"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
            case statePickerView:
                state.text = stateOptions[row]
                break
            default:
                break
        }
    }
}
