 

import UIKit

class FirstViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var roomIDLabel: UILabel!
    @IBOutlet weak var roomTextField: UITextField!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var connectBtn: UIButton!
    
    var roomID = ""
    var roomName = ""

    
    
    @IBOutlet weak var joinRoomView: UIStackView!
    @IBOutlet weak var roomCreateView: UIStackView!
    
    var joinRoom = false
    @IBOutlet weak var selector: UISegmentedControl!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        roomTextField.delegate = self
        usernameTextField.delegate = self
        
        
        
        //Looks for single or multiple taps.
         let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
        
        
        
        if(!roomID.isEmpty){
//            roomIDLabel.isHidden = true
            roomIDLabel.text = "Connecting to Room \(roomName)"
            roomIDLabel.textAlignment = .center
            roomTextField.isHidden = true
            self.roomCreateView.isHidden = true
            
            roomTextField.text = roomID
            joinRoom = true
        }
        
        
        
 
        
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
  
    @IBAction func switchValChanged(_ sender: UISegmentedControl) {
        
        
        
        switch sender.selectedSegmentIndex {
        case 1:
            
            //Yes
            joinRoom = true
            
            roomIDLabel.text = "Enter Room ID"
//            roomTextField.keyboardType = .
        case 0:
            //No
            joinRoom = false
            roomIDLabel.text = "Enter Room Name"

        
        default:
            print()
            
        }
      
        
    }
    
    
    func setUIForNewRoomConnect(){
        roomID = ""
        roomName = ""
        
        roomIDLabel.text = "Enter Room Name"
        
        roomIDLabel.textAlignment = .left
        roomTextField.isHidden = false
        roomTextField.text = roomID
        usernameTextField.text = ""
        self.roomCreateView.isHidden = false
        self.selector.selectedSegmentIndex = 0
        joinRoom = false
        
    }
    
 
    @IBAction func connectBtnPressed(_ sender: Any) {
        
        
        
        if currentReachabilityStatus == .notReachable {
            // Network Unavailable
            
            let alert = UIAlertView()
            alert.title = "Alert!"
            alert.message = "Please check network and try again."
            alert.addButton(withTitle: "Ok")
            alert.show()
            
            
        } else {
            // Network Available
            if roomTextField.text?.count ?? 0 > 0 {
                
                print("****Function: \(#function), line: \(#line)****\n-- ")
                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as? ViewController
                vc?.roomID =  (roomID.isEmpty ? (Int(roomTextField.text ?? "1234") ?? 1234) : (Int(roomID ))) ?? 1234
                vc?.username = usernameTextField.text ?? ""
                if !joinRoom {
                    vc?.roomNameStr  = roomTextField.text ?? "Codelabs Room"
 
                }else{
                    vc?.roomNameStr = roomName

                }
                
//                if !roomID.isEmpty{
//                    vc?.roomNameStr = roomName
//
//                }
                print("vc?.roomNameStr  \(vc?.roomNameStr)")

                print("joinRoom \(joinRoom)")
                print("roomName \(roomName)")
                vc?.type = joinRoom ? .Join : .Create
                self.dismissKeyboard()
                self.navigationController?.pushViewController(vc!, animated: true)
                setUIForNewRoomConnect()
               
                
            } else {
                let alert = UIAlertView()
                alert.title = "Alert!"
                alert.message = "Room ID is mandatory."
                alert.addButton(withTitle: "Ok")
                alert.show()
            }
            
        }
        
        
        
   
        
        
    }
    
 
}



extension FirstViewController{
    
    
    
    
    
    
}
