import UIKit
import SpriteKit
import CoreBluetooth

class ViewController: UIViewController, TransmitterManagerDelegate, GameSceneActionDelegate {
    
    var btStatus = UILabel(frame: CGRect(x: 700, y: 0, width: 200, height: 50))

    let sendLabel = UILabel(frame:CGRect(x: 20, y: 150, width: 100, height: 20))
    let sendSwitch = UISwitch(frame:CGRect(x: 150, y: 150, width: 0, height: 0))
    
    let aux01Label = UILabel(frame:CGRect(x: 20, y: 190, width: 100, height: 20))
    let aux01Switch = UISwitch(frame:CGRect(x: 150, y: 190, width: 0, height: 0))
    
    let aux02Label = UILabel(frame:CGRect(x: 20, y: 230, width: 100, height: 20))
    let aux02Switch = UISwitch(frame:CGRect(x: 150, y: 230, width: 0, height: 0))
    
    var scene = GameScene()
    var tx = TransmitterManager()
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tx.delegate = self
        
        btStatus.text = "wait a minute!"
        self.view.addSubview(btStatus)
        
        scene = GameScene(size: self.view.bounds.size)
        scene.actionDelegate = self
        
        aux01Label.text = "AUX01: "
        self.view.addSubview(aux01Label)
        
        aux02Label.text = "AUX02: "
        self.view.addSubview(aux02Label)
        
        aux01Switch.addTarget(self, action: #selector(sendData), for: .valueChanged)
        aux01Switch.setOn(false, animated: false)
        self.view.addSubview(aux01Switch)
        
        aux02Switch.addTarget(self, action: #selector(sendData), for: .valueChanged)
        aux02Switch.setOn(false, animated: false)
        self.view.addSubview(aux02Switch)
        
        scene.backgroundColor = .black
        
        if let skView = self.view as? SKView {
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            skView.presentScene(scene)
        }
        
    }

    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask  {
        return UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func didUpdateState(state: CBCentralManagerState) {
        var consoleMsg = ""
        switch (state) {
        case.poweredOff:
            consoleMsg = "PWoff"
            btStatus.text = "Disconnect!"
            btStatus.textColor = UIColor.red
        //stopSendingData()
        case.poweredOn:
            consoleMsg = "PWon"
            btStatus.text = "Connected :)"
            btStatus.textColor = UIColor.green
            startSendingData()
        case.resetting:
            consoleMsg = "Reset"
        case.unauthorized:
            consoleMsg = "Unautho"
        case.unknown:
            consoleMsg = "Unknow"
        case.unsupported:
            consoleMsg = "Unsupported"
        }
        print("\(consoleMsg)")
    }
    
    func didReceiveReady() {
        
    }
    
    func startSendingData() {
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(sendData), userInfo: nil, repeats: true)
    }
    
    func stopSendingData() {
        timer.invalidate()
    }
    
    @objc func sendData() {
        
        let pitchRaw = scene.pitchVal
        let rollRaw = scene.rollVal
        
        var aux01Raw = 1000
        if(aux01Switch.isOn){
            aux01Raw = 2000
        }else {
            aux01Raw = 1000
        }
        
        var aux02Raw = 1000
        if(aux02Switch.isOn){
            aux02Raw = 2000
        }else {
            aux02Raw = 1000
        }
        
        tx.writeValue(dataRaw: "\(throttle),\(yaw),\(pitch),\(roll),\(aux01Raw),\(aux02Raw)\n")
    }
    
    var throttle = GameScene.throttleMin
    var yaw = GameScene.stickMiddle
    var pitch = GameScene.stickMiddle
    var roll = GameScene.stickMiddle
    
    func didUpdateLeftStick(throttle: Int, yaw: Int) {
        self.throttle = throttle
        self.yaw = yaw
    }
    
    func didUpdateRightStick(pitch: Int, roll: Int) {
        self.pitch = pitch
        self.roll = roll
    }
    
}
