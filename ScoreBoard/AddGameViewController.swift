import FirebaseFirestore
import Material
import UIKit

class AddGameViewController : UIViewController {
    @IBOutlet private weak var homeTeam     : TextField!
    @IBOutlet private weak var awayTeam     : TextField!
    @IBOutlet private weak var datePicker   : UIDatePicker!
    
    private let homeTeamPickerView                  : UIPickerView  = UIPickerView()
    private let awayTeamPickerView                  : UIPickerView  = UIPickerView()
    private var teamOptions                         : [NBATeam]     = NBATeamService.instance.teams
    
    private var saveBtn                             : FABButton!
    private let defaultStore                        : Firestore     = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        prepareFABButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func initUI() -> Void {
        hideKeyboardWhenTappedAround()
        
        homeTeamPickerView.delegate = self
        homeTeamPickerView.dataSource = self
        homeTeam.inputView = homeTeamPickerView
        
        awayTeamPickerView.delegate = self
        awayTeamPickerView.dataSource = self
        awayTeam.inputView = awayTeamPickerView
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
    
    @objc func save() -> Void {
        ModalService.showConfirm(title: "Submit Game", message: "Are you sure?", vc: self)
            .then{ () -> Void in
                let game        : Game      = Game()

                let homeTeam    : NBATeam   = self.teamOptions[self.homeTeamPickerView.selectedRow(inComponent: 0)]
                let awayTeam    : NBATeam   = self.teamOptions[self.awayTeamPickerView.selectedRow(inComponent: 0)]

                game.homeTeamId             = homeTeam.id
                game.awayTeamId             = awayTeam.id
                game.starts                 = self.datePicker.date

                MyFSRef.createGame(game: game)
                    .then{ (id) -> Void in
                        ModalService.showAlert(title: "Game Created", message: "ID: " + id, vc: self)
                        _ = self.navigationController?.popViewController(animated: true)
                    }.catch{ (err) in
                        ModalService.showAlert(title: "Error", message: err.localizedDescription, vc: self)
                    }.always{}
            }.always{}
    }
}

extension AddGameViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView {
            case homeTeamPickerView, awayTeamPickerView:
                return 1
            default:return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
            case homeTeamPickerView, awayTeamPickerView:
                return teamOptions.count
            default:return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
            case homeTeamPickerView, awayTeamPickerView:
                return teamOptions[row].city + " " + teamOptions[row].name
            default:return "Null"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
            case homeTeamPickerView:
                homeTeam.text = teamOptions[row].name
            case awayTeamPickerView:
                awayTeam.text = teamOptions[row].name
            default:break
        }
    }
}



