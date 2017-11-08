import UIKit
import SpriteKit
import CoreBluetooth

class ViewController: UIViewController, TransmitterManagerDelegate, GameSceneActionDelegate {
    
    var throttleRaw = 1000
    var btStatus = UILabel(frame: CGRect(x: 700, y: 0, width: 200, height: 50))
    
    var throttleLabel = UILabel(frame: CGRect(x: 20, y: 100, width: 500, height: 10))
    var throttleSlider = UISlider(frame: CGRect(x: 150, y: 100, width: 500, height: 10))
    
    let sendLabel = UILabel(frame:CGRect(x: 20, y: 150, width: 100, height: 20))
    let sendSwitch = UISwitch(frame:CGRect(x: 150, y: 150, width: 0, height: 0))
    
    let aux01Label = UILabel(frame:CGRect(x: 20, y: 190, width: 100, height: 20))
    let aux01Switch = UISwitch(frame:CGRect(x: 150, y: 190, width: 0, height: 0))
    
    let aux02Label = UILabel(frame:CGRect(x: 20, y: 230, width: 100, height: 20))
    let aux02Switch = UISwitch(frame:CGRect(x: 150, y: 230, width: 0, height: 0))
    
    //let throttlePrg = UIProgressView(frame: CGRect(x: 20, y: 270, width: 500, height: 10))
    
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
        throttleSlider.minimumValue = 1000
        throttleSlider.maximumValue = 2000
        throttleSlider.value = 1000
        // throttleSlider.addTarget(self, action: #selector(throttleChange), for: .valueChanged)
        self.view.addSubview(throttleSlider)
        
        throttleLabel.text = "Throttle: "
        self.view.addSubview(throttleLabel)
        
        //throttlePrg.progress = 0.5
        //self.view.addSubview(throttlePrg)
        
        //sendLabel.text = "Start: "
        //self.view.addSubview(sendLabel)
        
        aux01Label.text = "AUX01: "
        self.view.addSubview(aux01Label)
        
        aux02Label.text = "AUX02: "
        self.view.addSubview(aux02Label)
        
        //sendSwitch.addTarget(self, action: #selector(sendData), for: .valueChanged)
        //sendSwitch.setOn(false, animated: false)
        //self.view.addSubview(sendSwitch)
        
        aux01Switch.addTarget(self, action: #selector(sendData), for: .valueChanged)
        aux01Switch.setOn(false, animated: false)
        self.view.addSubview(aux01Switch)
        
        aux02Switch.addTarget(self, action: #selector(sendData), for: .valueChanged)
        aux02Switch.setOn(false, animated: false)
        self.view.addSubview(aux02Switch)
        
        scene.backgroundColor = .black
        //scene.throttleVal = throttleRaw
        
        if let skView = self.view as? SKView {
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            skView.presentScene(scene)
        }
        
    }
    
    //    @objc func throttleChange() {
    //        throttleRaw = Int(throttleSlider.value)
    //        scene.throttleLabel.text = "Throttle:\(throttleRaw)"
    //        scene.throttleVal = throttleRaw
    //    }
    //
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
        //        let pitchRaw = Int(pitchSlider.value)
        //        let rollRaw = Int(rollSlider.value)
        
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
        
        print("sendData: \(throttle)")
        
        tx.writeValue(dataRaw: "\(throttle),\(yaw),\(scene.pitchVal),\(scene.rollVal),2000,0\n")
    }
    
    var throttle = GameScene.throttleMin
    var yaw = GameScene.throttleMin
    func didUpdateLeftStick(throttle: Int, yaw: Int) {
        self.throttle = throttle
        self.yaw = yaw
    }
    
    func didUpdateRightStick(pitch: Int, roll: Int) {
        
    }
    
}
