import FirebaseFirestore
import Material
import UIKit

class AdminViewController : UIViewController {
    @IBOutlet weak var homeTeam: TextField!
    @IBOutlet weak var awayTeam: TextField!
    
    let homeTeamPickerView: UIPickerView = UIPickerView()
    let awayTeamPickerView: UIPickerView = UIPickerView()
    var teamOptions: [NBATeam] = NBATeamService.instance.teams
    
    var saveBtn: FABButton!
    let defaultStore = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(ConnectionManager.isConnectedToInternet()){
            initUI()
            prepareFABButton()
        }else{
            ModalService.showError(title: "Sorry", message: "No Internet")
        }
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
    
    func save() -> Void {
        let game: Game = Game()
        
        let homeTeam: NBATeam = teamOptions[homeTeamPickerView.selectedRow(inComponent: 0)]
        let awayTeam: NBATeam = teamOptions[awayTeamPickerView.selectedRow(inComponent: 0)]
        
        game.potAmount = 100
        game.homeTeamCity = homeTeam.city
        game.homeTeamName = homeTeam.name
        game.awayTeamCity = awayTeam.city
        game.awayTeamName = awayTeam.name
        
        MyFSRef.createGame(game: game)
            .then{ (id) -> Void in
                ModalService.showInfo(title: "ID", message: id)
            }.catch{ (err) in
                ModalService.showError(title: "Sorry", message: err.localizedDescription)
            }.always{}
    }
}

extension AdminViewController : UIPickerViewDataSource, UIPickerViewDelegate {
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
                return teamOptions[row].name
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



