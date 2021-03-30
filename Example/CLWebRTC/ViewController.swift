 
 
 import UIKit
 import Starscream
 import WebRTC
 import CLWebRTC
 //import SnapKit
 class ViewController: UIViewController ,CodelabsRTCClientDelegate{
    
    
    
    
    var localView:UIView?
    @IBOutlet weak var audioBtn: UIButton!
    @IBOutlet weak var videFeedBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var cameraSwapBtn: UIButton!
    @IBOutlet weak var roomName: UILabel!
    @IBOutlet weak var roomNameLblView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var shareRoomButton: UIButton!
    
    
    
    
    var roomNameStr = ""
    
    
    //    @IBOutlet var remoteView:UIView!
    //    @IBOutlet var remoteView2:UIView!
    
    var remoteViewsList : [UIView] = []
    
    
    
    var rtcLocalView:RTCMTLVideoView?
    //    var rtcLocalView:RTCCameraPreviewView?
    var rtcRemoteView:RTCMTLVideoView?
    var rtcRemoteView2:RTCMTLVideoView?
    //    var rtcRemoteView3:RTCMTLVideoView?
    
    
    
    //    RTCMTLVideoView
    
    var localVideoTrack:RTCVideoTrack?
    var remoteVideoTrack:RTCVideoTrack?
    var remoteVideoTrack2:RTCVideoTrack?
    //    var remoteVideoTrack3:RTCVideoTrack?
    
    
    var rtcManager:RTCClient?
    var clientServer: RTCVideoServer?
    var rtcOperator: WebRTCOperator?
    
    
    
    //    int number = -1
    var tmRemoteView = RemoteViews()
    var audioMute = false
    //    var viewNumber = 0
    var previewWidth = 180
    var previewHeight = 220
    
    
    @IBOutlet weak var firstCollectionView: UICollectionView!
    @IBOutlet weak var secondCollectionView: UICollectionView!
    
    var isPublishing = true
    var isConnected = false
    
    var roomID: Int = 1234
    var username = "self"
    
    var callEnded = false
    
    
    
    private let sectionInsets = UIEdgeInsets(
        top: 5.0,
        left: 0.0,
        bottom: 5.0,
        right: 0.0)
    private let itemsPerRow: CGFloat = 3
    
    
    
    
    
    
    //    @IBOutlet weak var mainStackView: UIStackView!
    
    
    var stackView1 : UIStackView = UIStackView()
    weak var stackView2 : UIStackView?
    weak var stackView3 : UIStackView?
    weak var stackView4 : UIStackView?
    
    let viewBreakAtNumber = 4
    
    
    
    var contentMode : UIView.ContentMode = .scaleAspectFit
    
    
    var safeAreaHeight : CGFloat = 0.0
    var safeAraeWidth : CGFloat = 0.0
    var buttonViewTimer: Timer?
    
    var hideInSeconds = 5.0
    var offsetYValue : CGFloat = 200.0
    
    var type : CodelabsType = .Join
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        rtcLocalView = RTCMTLVideoView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: (self.view.frame.height)))
        //        rtcLocalView?.contentMode = contentMode
        //        localView?.contentMode = contentMode
        
        //        localView?.addSubview(rtcLocalView!)
        
        //        tmRemoteView.view.append(rtcLocalView!)
        tmRemoteView.initView(remoteView: rtcLocalView!)
        tmRemoteView.view.first?.name = username
        
        
        
        
        
        //
        //        for _ in 0...5 {
        //
        //        }
        
        
        
        
        var iceServers = [RTCIceServer]()
        iceServers.append(RTCIceServer(urlStrings:["stun:stun.l.google.com:19302"]))
        iceServers.append(RTCIceServer(urlStrings:["stun:stun.multi.net.pk:3478"]))
        
        
        
        let myId = username
        
        rtcManager = RTCClient(videoCall: true)
        rtcManager?.defaultIceServer = iceServers
 //        clientServer = RTCVideoServer(url: "wss://webrtc2.codelabs.inc:8989/janus", client: rtcManager!)
        clientServer = RTCVideoServer(url: "wss://signalkhi.codelabs.inc:8989/janus", client: rtcManager!)
        //        clientServer = RTCVideoServer(url: "wss://web.codelabs.inc:8989/janus", client: rtcManager!)
        
        clientServer?.display = myId
        
        rtcOperator = WebRTCOperator(delegate: self,clSocket: clientServer!)
        rtcManager?.delegate = rtcOperator
        
        clientServer?.type = type
        clientServer?.roomName = roomNameStr
        clientServer?.registerMeetRoom(Int64(roomID))
        
        
        clientServer?.videoServerDelegate = self
        
        
        
        
        
        
        
        
        
        
        self.firstCollectionView.delegate = self
        self.firstCollectionView.dataSource = self
        self.secondCollectionView.delegate = self
        self.secondCollectionView.dataSource = self
        
        self.firstCollectionView.reloadData()
        self.secondCollectionView.reloadData()
        
        
        videFeedBtn.tintColor = .white
        audioBtn.tintColor = .white
        cameraSwapBtn.tintColor = .white
        
        
        
        
        //        self.mainStackView.addArrangedSubview((tmRemoteView.view.first?.rtcRemoteView)!)
        //        mainStackView.axis = .vertical
        //        mainStackView.distribution = .fillEqually
        //        mainStackView.spacing = 5.0
        
        //        videFeedBtn.setImage(#imageLiteral(resourceName: "ic_feedOff"), for: .normal)
        //        audioBtn.setImage(#imageLiteral(resourceName: "mute"), for: .normal)
        //        cameraSwapBtn.setImage(#imageLiteral(resourceName: "ic_cameraSwap"), for: .normal)
        
        print("roomNameStr \(roomNameStr)")

        
        if (!roomNameStr.isEmpty){
            self.roomName.isHidden = false
            self.roomNameLblView.isHidden = false
            self.shareRoomButton.isHidden = false
            roomName.text = "Room Name: " + roomNameStr
        }
        
        
        //        _=setTimeout(delay: 15, block: switchCanera)
        
        
        
        let verticalSafeAreaInset: CGFloat
        if #available(iOS 11.0, *) {
            verticalSafeAreaInset = self.view.safeAreaInsets.bottom + self.view.safeAreaInsets.top + 90
        } else {
            verticalSafeAreaInset = 0.0
        }
        safeAreaHeight = self.view.frame.height - verticalSafeAreaInset
        
        
        
        
        // for swipe up to display buttons
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(displayButtonView))
        swipeGesture.direction = .up
        self.view.addGestureRecognizer(swipeGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(runTimedCode))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(displayButtonView))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        
        let wakeTap = UITapGestureRecognizer(target: self, action: #selector(wakeCode))
        wakeTap.numberOfTapsRequired = 1
        self.buttonsView.addGestureRecognizer(wakeTap)
        
        audioBtn.addTarget(self, action: #selector(wakeCode), for: .touchUpInside)
        videFeedBtn.addTarget(self, action: #selector(wakeCode), for: .touchUpInside)
        callBtn.addTarget(self, action: #selector(wakeCode), for: .touchUpInside)
        cameraSwapBtn.addTarget(self, action: #selector(wakeCode), for: .touchUpInside)

 
        
        
        
        buttonViewTimer = Timer.scheduledTimer(timeInterval: hideInSeconds, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
        
 
    }
    @objc func wakeCode() {
        
        // print("****Function: \(#function), line: \(#line)****\n-- ")
        
        buttonViewTimer?.invalidate()
        buttonViewTimer = Timer.scheduledTimer(timeInterval: hideInSeconds, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
        
        
        
    }
    
    @objc func runTimedCode() {
//        print("****Function: \(#function), line: \(#line)****\n-- self.buttonsView.isHidden \(self.buttonsView.isHidden)")
        
        if self.buttonsView.isHidden {
            return
        }
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
        //            self.functionToCall()
        UIView.animateKeyframes(withDuration: 0.85, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: 7), animations: {
            
            print("self.buttonsView.frame.origin.y \(self.buttonsView.frame.origin.y)")
            
//            self.buttonsView.frame.origin.y += self.offsetYValue
            //                self.buttonsView.transla
            
//            self.buttonsView.snp.makeConstraints { (make) in
//                make.bottom.equalTo(200.0)
//            }
            self.buttonsView.alpha = 0.0
            
        },completion: {(bool) in
            self.buttonsView.isHidden = true

            self.buttonViewTimer?.invalidate()
            
        })
        
        //        })
    }
    
    
    @objc func displayButtonView() {
//        print("****Function: \(#function), line: \(#line)****\n-- self.buttonsView.isHidden \(self.buttonsView.isHidden)")
        
        
 
        
        if self.buttonsView.isHidden{
            
            
            buttonViewTimer?.invalidate()
            buttonViewTimer = Timer.scheduledTimer(timeInterval: hideInSeconds, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
            self.buttonsView.isHidden = false

            UIView.animate(withDuration: 0.25) {
                print("self.buttonsView.frame.origin.y \(self.buttonsView.frame.origin.y)")
                self.buttonsView.alpha = 1.0
//                self.buttonsView.frame.origin.y -= self.offsetYValue
//                self.buttonsView.snp.makeConstraints { (make) in
//                    make.bottom.equalTo(-20.0)
//                }

            } completion: { (value) in

            }

            
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        if #available(iOS 11.0, *) {
            safeAreaHeight   = self.view.safeAreaLayoutGuide.layoutFrame.height
            safeAraeWidth  = self.view.safeAreaLayoutGuide.layoutFrame.width
            
        } else {
            // Fallback on earlier versions
            safeAreaHeight   = self.view.frame.height
            safeAraeWidth  = self.view.frame.width
        }
        
        
//        print("safeAreaHeight \(safeAreaHeight)" )
//        print("safeAraeWidth \(safeAraeWidth)" )
        
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        
        
        
        
        
        
        
        self.firstCollectionView.reloadData()
        self.firstCollectionView.collectionViewLayout.invalidateLayout()
        self.secondCollectionView.reloadData()
        self.secondCollectionView.collectionViewLayout.invalidateLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    
    
    @IBAction func shareButtonAction(_ sender: UIButton) {
        
        let toEncode = "\(roomNameStr)_roomid_codelabs_\(clientServer?.roomId ?? 1234)"
        print("toEncode \(toEncode)")
        print("base64 toEncode \(toEncode.base64Encoded.string ?? "")")
        
        let url = "https://projects.codelabs.inc/CodelabsWebRtc/?room=\(toEncode.base64Encoded.string ?? "")"
        print("url \(url)")


    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender
        present(activityVC, animated: true, completion: nil)
        activityVC.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            
            if completed  {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func cameraSwapPressed(_ sender: Any) {
        switchCamera()
    }
    
    
    @IBAction func audioBtnPressed(_ sender: Any) {
        
        rtcManager?.setAudioEnable(flag: audioMute)
        
        
        audioMute.toggle()
        
        if audioMute {
            
            audioBtn.setImage(#imageLiteral(resourceName: "Mic open"), for: .normal)
            audioBtn.tintColor = .white
            
        }else{
            audioBtn.setImage(#imageLiteral(resourceName: "mute"), for: .normal)
            audioBtn.tintColor = .white
            
            
        }
        
    }
    
    
    @IBAction func callButton(_ sender: Any) {
        
        
        
        
        //        if isConnected{
        callEnded = true
        clientServer?.disconnectMeeting()
        
        callBtn.setTitle("", for: .normal)
        callBtn.setTitleColor(.green, for: .normal)
        callBtn.setImage(#imageLiteral(resourceName: "connect call"), for: .normal)
        self.navigationController?.popViewController(animated: true)
        
        
        
        //        }else{
        //            clientServer?.registerMeetRoom(Int64(roomID))
        //            callBtn.setTitle("", for: .normal)
        //            callBtn.setTitleColor(.red, for: .normal)
        //            callBtn.setImage(#imageLiteral(resourceName: "end call"), for: .normal)
        //
        //        }
        //        rtcManager.con
        
        //        rtcManager?.disconnectAll()
        
        
        //        clientServer.
    }
    
    
    @IBAction func feedOffBtnPressed(_ sender: Any) {
        
        if isPublishing {
            unpublishMyself()
            videFeedBtn.setImage(#imageLiteral(resourceName: "cam on"), for: .normal)
            videFeedBtn.tintColor = .white
            
        }else{
            publishMyself()
            videFeedBtn.setImage(#imageLiteral(resourceName: "cam off"), for: .normal)
            videFeedBtn.tintColor = .white
            
            
        }
        isPublishing.toggle()
        
        self.firstCollectionView.reloadData()
        self.firstCollectionView.collectionViewLayout.invalidateLayout()
        self.secondCollectionView.reloadData()
        self.secondCollectionView.collectionViewLayout.invalidateLayout()
        
    }
    
    
    
    func switchCamera()
    {
        if(localVideoTrack != nil && (localVideoTrack!.source as? RTCAVFoundationVideoSource)?.canUseBackCamera == true){
            (localVideoTrack!.source as! RTCAVFoundationVideoSource).useBackCamera = !(localVideoTrack!.source as! RTCAVFoundationVideoSource).useBackCamera
        }
    }
    
    
    @IBAction public func unpublishMyself()
    {
        clientServer?.unpublishMyself()
        rtcLocalView?.isHidden = true
        //        rtcLocalView?.removeFromSuperview()
        
        //        tmRemoteView.view.first?.rtcRemoteView?.removeFromSuperview()
    }
    @IBAction public func publishMyself()
    {
        clientServer?.publishMyself()
        rtcLocalView?.isHidden = false
        //        localView?.addSubview(rtcLocalView!)
        //        tmRemoteView.view.first?.uiView?.addSubview(rtcLocalView!)
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateNames(){
        //        print("****Function: \(#function), line: \(#line)****\n-- tmremoteView \(tmRemoteView.view.count)")
        
        
        //        dump(clientServer?.joinedParticipant)
        
        clientServer?.joinedParticipant?.plugindata.data.publishers!.forEach({ (publisher) in
            
            
            
            let record = tmRemoteView.view.first { (rv) -> Bool in
                return (rv.id ?? "") == "\(publisher.id)"
            }
            record?.name = publisher.display
            DispatchQueue.main.async {
                
                record?.rtcRemoteView?.tag = Int(record?.id ?? "0")!
            }
        })
        
        
        DispatchQueue.main.async {
            self.firstCollectionView.reloadData()
            self.secondCollectionView.reloadData()
            self.secondCollectionView.collectionViewLayout.invalidateLayout()
            
        }
        
        
        
        DispatchQueue.main.async{
            
            
            //            print("self.clientServer?.joinedParticipant?.plugindata.data.description?.isEmpty ?? false \(self.clientServer?.joinedParticipant?.plugindata.data.description?.isEmpty ?? false)")
            //            print("self.clientServer?.joinedParticipant?.plugindata.data.description? == nil \(self.clientServer?.joinedParticipant?.plugindata.data.description == nil)")
            
            if  self.clientServer?.joinedParticipant?.plugindata.data.description != nil && self.roomNameStr.isEmpty
            {
                self.roomName.isHidden = false
                self.roomNameLblView.isHidden = false
                self.shareRoomButton.isHidden = false
                if !((self.clientServer?.joinedParticipant?.plugindata.data.description ?? "").isEmpty)
                {
                    self.roomName.text = "Room Name: \(self.clientServer?.joinedParticipant?.plugindata.data.description ?? "")"
                    self.roomNameStr = self.clientServer?.joinedParticipant?.plugindata.data.description ?? ""
                
                
                }
            }
            
            
            
            
        }
        
        
    }
    
    
    //
    //    func updateLayout(){
    //
    //        let count = tmRemoteView.view.count
    //
    //
    //        switch count {
    ////        case 1:
    //
    //        case 2:
    //            self.mainStackView.addArrangedSubview((tmRemoteView.view[count-1].rtcRemoteView)!)
    //
    //
    //            self.mainStackView.sizeToFit()
    //            self.mainStackView.layoutIfNeeded()
    //
    //
    //        case 3...4:
    //            print()
    //
    //
    //
    //            self.stackView1.addArrangedSubview((tmRemoteView.view[count-1].rtcRemoteView)!)
    //            self.stackView1.axis = .horizontal
    //            self.stackView1.distribution = .fillEqually
    //            self.stackView1.spacing = 5.0
    //
    //            self.mainStackView.addArrangedSubview((self.stackView1))
    //
    //            self.mainStackView.sizeToFit()
    //            self.mainStackView.layoutIfNeeded()
    //            self.stackView1.sizeToFit()
    //            self.stackView1.layoutIfNeeded()
    //
    //
    //
    //
    //        default:
    //            print()
    //        }
    //
    //    }
    
 }
 
 
 // MARK: - RTC Events
 extension ViewController : RTCVideoServerDelegate {
    func serverDidNotConnect(error: Error?) {
        print("serverDidNotConnect \(String(describing: error?.localizedDescription))")
        
        
        if let e = error {
            
            if (!callEnded) {
                let alert = UIAlertController(title: "Alert", message: "Failed to connect to server! \(e.localizedDescription)", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                    
                    DispatchQueue.main.async(execute: {
                        
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                })
                alert.addAction(ok)
                
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true)
                })
                
            }
            
            isConnected = false
            
        }
    }
    
    func videoView(_ videoView: RTCMTLVideoView, didChangeVideoSize size: CGSize) {
        //        rtcRemoveView?.renderFrame(RTCVideoFrame(buffer: <#T##RTCVideoFrameBuffer#>, rotation: <#T##RTCVideoRotation#>, timeStampNs: <#T##Int64#>))
        print("......videoView... \(videoView.tag)   \(size)")
        //        rtcRemoveView?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let record  = tmRemoteView.view.first { (rv) -> Bool in
            return (rv.id ?? "") == "\(videoView.tag)"
        }
        print("record \(String(describing: record?.name))")
        record?.size = size
        
        
        DispatchQueue.main.async {
            //            if record?.rtcRemoteView != nil{
            //
            //            let defaultAspectRatio: CGSize = CGSize(width: 4, height: 3)
            //              let aspectRatio: CGSize = size.equalTo(CGSize.zero) ? defaultAspectRatio : size
            //                let videoRect: CGRect = self.view.bounds
            //                let width = record?.rtcRemoteView?.frame.size.width
            //                let height = record?.rtcRemoteView?.frame.size.height
            //
            //                let maxFloat = CGFloat.maximum((width!), (height!))
            //                let newAspectRatio = aspectRatio.width / aspectRatio.height
            //                var frame = CGRect(x: 0, y: 0, width: width!, height: height!)
            //                if (aspectRatio.width < aspectRatio.height) {
            //                  frame.size.width = maxFloat;
            //                  frame.size.height = frame.size.width / newAspectRatio;
            //              } else {
            //                  frame.size.height = maxFloat;
            //                  frame.size.width = frame.size.height * newAspectRatio;
            //              }
            //              frame.origin.x = (self.view.frame.width - frame.size.width) / 2
            //              frame.origin.y = (self.view.frame.height - frame.size.height) / 2
            //
            //
            //
            //                record?.rtcRemoteView!.frame = frame
            //            }
            
            
            self.firstCollectionView.reloadData()
            self.firstCollectionView.collectionViewLayout.invalidateLayout()
            self.secondCollectionView.reloadData()
            self.secondCollectionView.collectionViewLayout.invalidateLayout()
            
            //            self.updateLayout()
            
        }
    }
    //
    
    
    
    
    func rtcClient(_ id: String, didReceiveLocalVideoTrack localVideoTrack:RTCVideoTrack) {
        //        rtcLocalView?.captureSession=(localVideoTrack.source as! RTCAVFoundationVideoSource).captureSession
        self.localVideoTrack = localVideoTrack
        
        localVideoTrack.add(self.rtcLocalView!)
    }
    
    
    
    func rtcClient(_ id: String, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
        //        print("[didReceive RemoteVideo Track..] ")
        //        print("id= \(id), remoteVideoTrack= \(remoteVideoTrack.source) ")
        //        print("self.clientServer?.joinedParticipant?.plugindata.data.description \(String(describing: self.clientServer?.joinedParticipant?.plugindata.data.description))")
        
        
        
        
        //        dump("self.cl/ientServer?.participantsData \(String(describing: self.clientServer?.joinedParticipant?.plugindata.data.description))")
        
        //        print("")
        //        dump(self.clientServer?.joinedParticipant)
        
        
        
        
        
        DispatchQueue.main.async{
            
            //            if(self.rtcRemoteView?.tag==0){
            //                self.remoteVideoTrack = remoteVideoTrack
            //                self.rtcRemoteView?.delegate = self
            //                self.rtcRemoteView?.tag = Int(id)!
            //                //                self.remoteView.addSubview(self.rtcRemoteView!)
            //                self.tmRemoteView.add(videoTrack: remoteVideoTrack, remoteView: self.rtcRemoteView!, id: id)
            //                remoteVideoTrack.add(self.rtcRemoteView!)
            //            }else if (self.rtcRemoteView2?.tag==0){
            //                self.remoteVideoTrack2 = remoteVideoTrack
            //                self.rtcRemoteView2?.delegate = self
            //                self.rtcRemoteView2?.tag = Int(id)!
            //                //                self.remoteView2.addSubview(self.rtcRemoteView2!)
            //                self.tmRemoteView.add(videoTrack: remoteVideoTrack, remoteView: self.rtcRemoteView2!, id: id)
            //
            //                remoteVideoTrack.add(self.rtcRemoteView2!)
            //
            //            }
            //            else if (self.rtcRemoteView3?.tag==0){
            //                self.remoteVideoTrack3 = remoteVideoTrack
            //                self.rtcRemoteView3?.delegate = self
            //                self.rtcRemoteView3?.tag = Int(id)!
            //                //                self.remoteView2.addSubview(self.rtcRemoteView2!)/
            //                self.tmRemoteView.add(videoTrack: remoteVideoTrack, remoteView: self.rtcRemoteView3!, id: id)
            //
            //                remoteVideoTrack.add(self.rtcRemoteView3!)
            //
            //            }
            //            else{
            
            //            }
            
            
            if self.tmRemoteView.view.count > 4{
                return
            }
            
            let temprtcRemoteView:RTCMTLVideoView = RTCMTLVideoView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            var tempremoteVideoTrack:RTCVideoTrack?
            
            //            temprtcRemoteView.setSize(<#T##size: CGSize##CGSize#>)
            tempremoteVideoTrack = remoteVideoTrack
            //            temprtcRemoteView.delegate = self
            temprtcRemoteView.tag = Int(id)!
            
            //            temprtcRemoteView.contentMode = .scaleAspectFit
            self.tmRemoteView.add(videoTrack: tempremoteVideoTrack!, remoteView: temprtcRemoteView, id: id)
            remoteVideoTrack.add(temprtcRemoteView)
            
            
            
            
        }
        
        DispatchQueue.main.async {
            
            self.firstCollectionView.reloadData()
            self.firstCollectionView.collectionViewLayout.invalidateLayout()
            self.secondCollectionView.reloadData()
            self.secondCollectionView.collectionViewLayout.invalidateLayout()
            
            //            self.updateLayout()
            
        }
        self.updateNames()
    }
    
    func rtcClient(_ id: String, client: RTCClient, didRemoveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
        print("[didReceive didRemoveRemoteVideoTrack Track..] ")
        
    }
    
    
    
    
    func rtcClient(_ id: String, didReceiveError error: Error) {
        print("[Error]:\(error)")
    }
    
    
    
    func rtcClient(_ id: String, didChangeConnectionState connectionState: RTCIceConnectionState) {
        if(connectionState == .checking){
            print("[didChangeConnectionState]:checking)")
        }
        if(connectionState == .closed){
            print("[didChangeConnectionState]:closed)")
            isConnected = false
            DispatchQueue.main.async{
                
                
                
                
                //                if(self.rtcRemoteView?.tag==Int(id)){
                //                    self.remoteVideoTrack?.remove(self.rtcRemoteView!)
                //                    self.rtcRemoteView?.removeFromSuperview()
                //                    self.rtcRemoteView?.tag = 0
                //                    self.tmRemoteView.view.remove(at:  self.tmRemoteView.removeRemoteView(id: id))
                //
                //                }else if (self.rtcRemoteView2?.tag==Int(id)){
                //                    self.remoteVideoTrack2?.remove(self.rtcRemoteView2!)
                //                    self.rtcRemoteView2?.removeFromSuperview()
                //                    self.rtcRemoteView2?.tag = 0
                //                    self.tmRemoteView.view.remove(at:  self.tmRemoteView.removeRemoteView(id: id))
                //
                //                }
                //                else if (self.rtcRemoteView3?.tag==Int(id)){
                //                    self.remoteVideoTrack3?.remove(self.rtcRemoteView3!)
                //                    self.rtcRemoteView3?.removeFromSuperview()
                //                    self.rtcRemoteView3?.tag = 0
                //                    self.tmRemoteView.view.remove(at:  self.tmRemoteView.removeRemoteView(id: id))
                //
                //                }
                
                //                self.tmRemoteView.view.remove(at:  self.tmRemoteView.removeRemoteView(id: id))
                
                
                var record = self.tmRemoteView.view.first(where: {$0.id == id})
                
                //                record?.rtcRemoteView?.removeFromSuperview()
                record?.rtcRemoteView?.isHidden = true
                
                self.tmRemoteView.view.removeAll(where: {$0.id == id})
                //                print("self.tmRemoteView.view \(self.tmRemoteView.view.count)")
                
                
                //                self.updateLayout()
                
            }
            self.updateNames()
            
        }
        if(connectionState == .completed){
            print("[didChangeConnectionState]:completed)")
        }
        if(connectionState == .connected){
            isConnected = true
            print("[didChangeConnectionState]:connected)")
            self.updateNames()
            
            DispatchQueue.main.async {
                //                self.updateLayout()
                
            }
        }
        if(connectionState == .disconnected){
            print("[didChangeConnectionState]:disconnected)")
            isConnected = false
            
            
            
        }
        if(connectionState == .failed){
            print("[didChangeConnectionState]:failed)")
            isConnected = false
            
            let alert = UIAlertController(title: "Alert", message: "Failed to connect to server!", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                
                DispatchQueue.main.async(execute: {
                    
                    self.navigationController?.popViewController(animated: true)
                })
                
            })
            alert.addAction(ok)
            
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
            
            
        }
        
        
        DispatchQueue.main.async{
            
            self.firstCollectionView.reloadData()
            self.firstCollectionView.collectionViewLayout.invalidateLayout()
            self.secondCollectionView.reloadData()
            self.secondCollectionView.collectionViewLayout.invalidateLayout()
        }
        
    }
    
    
    
    
 }
 
 
 
 // MARK: - CollectionView
 
 extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        print("****Function: \(#function), line: \(#line)****\n   -- self.tmRemoteView.view.count = \(self.tmRemoteView.view.count) ")
        
        
        
        
        
        switch collectionView {
        case firstCollectionView:
            
            if self.tmRemoteView.view.count <= viewBreakAtNumber {
                return self.tmRemoteView.view.count
                
            }else{
                return viewBreakAtNumber
                
            }
            
        case secondCollectionView:
            if self.tmRemoteView.view.count > viewBreakAtNumber {
                
                //self.secondCollectionView.isHidden = false
                return self.tmRemoteView.view.count - viewBreakAtNumber
                
            }else{
                self.secondCollectionView.isHidden = true
                
                return 0
                
            }
            
        default:
            print()
            
        }
        
        
        return 1
    }
    
    
    //    func numberOfSections(in collectionView: UICollectionView) -> Int {
    //        switch self.tmRemoteView.view.count {
    //        case 1:
    //            return 1
    //        case 2...3:
    //            return 2
    //        case 2...4:
    //            return 2
    //        case 5...6:
    //            return 3
    //        case 7...100:
    //            return 4
    //        default:
    //           return 1
    //        }
    //
    //
    //     }
    //
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //                print("****Function: \(#function), line: \(#line)****\n   -- indexPath.row \(indexPath.row) tmRemoteView.view.count \(String(describing: tmRemoteView.view.count))")
        
        
        
        if collectionView == firstCollectionView {
            
            
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
            
            
            
            
            
            
            //        let label = UILabel()
            //        label.textColor = .white
            switch tmRemoteView.view.count {
            case 1:
                
                
                cell.videoView.addSubview(tmRemoteView.view[indexPath.item].rtcRemoteView!)
                tmRemoteView.view[indexPath.item].rtcRemoteView!.layer.cornerRadius = 10.0
                tmRemoteView.view[indexPath.item].rtcRemoteView!.snp.makeConstraints { (make) in
                    make.left.top.right.equalToSuperview()
                    make.bottom.equalToSuperview().offset(-5)
                }
                
                //            tmRemoteView.view[indexPath.item].rtcRemoteView!.contentMode = .scaleToFill
                //            cell.videoView.contentMode = .scaleToFill
                
                
                cell.label.text = username
                
                
                
            case 2..<100:
                //            print("tmRemoteView.view[indexPath.item].name \(tmRemoteView.view[indexPath.item].name ?? "")")
                cell.videoView.addSubview(tmRemoteView.view[indexPath.item].rtcRemoteView!)
                cell.label.text = tmRemoteView.view[indexPath.item].name ?? ""
                //            tmRemoteView.view[indexPath.item].rtcRemoteView!.snp.makeConstraints { (make) in
                //                make.top.bottom.left.right.equalToSuperview()
                //            }
                
                
                tmRemoteView.view[indexPath.item].rtcRemoteView!.snp.makeConstraints { (make) in
                    make.left.top.right.equalToSuperview()
                    make.bottom.equalToSuperview().offset(-5)
                }
                
                tmRemoteView.view[indexPath.item].rtcRemoteView!.layer.cornerRadius = 10.0
                
                
            //            let maxWidthContainer: CGFloat = self.view.frame.width
            //               let maxHeightContainer: CGFloat = 180
            //
            //            tmRemoteView.view[indexPath.item].rtcRemoteView!.snp.makeConstraints { (make) in
            //                   // centered X and Y
            //                   make.centerX.centerY.equalToSuperview()
            //
            //                   // at least 38 points "padding" on all 4 sides
            //
            //                   // leading and top >= 38
            //                   make.leading.top.greaterThanOrEqualTo(5)
            //
            //                   // trailing and bottom <= 38
            //                   make.trailing.bottom.lessThanOrEqualTo(5)
            //
            //                   // width ratio to height
            //                   make.width.equalTo(tmRemoteView.view[indexPath.item].rtcRemoteView!.snp.height).multipliedBy(maxWidthContainer/maxHeightContainer)
            //
            //                   // width and height equal to superview width and height with high priority (but not required)
            //                   // this will make it as tall and wide as possible, until it violates another constraint
            //                   make.width.height.equalToSuperview().priority(.high)
            //
            //                   // max height
            //                   make.height.lessThanOrEqualTo(maxHeightContainer)
            //               }
            //
            
            //            cell.videoView.translatesAutoresizingMaskIntoConstraints = false
            //            cell.videoView.contentMode = self.contentMode
            //            cell.videoView.setNeedsDisplay()
            
            //            tmRemoteView.view[indexPath.item].rtcRemoteView?.translatesAutoresizingMaskIntoConstraints = false
            //            tmRemoteView.view[indexPath.item].rtcRemoteView?.contentMode = self.contentMode
            //            tmRemoteView.view[indexPath.item].rtcRemoteView?.setNeedsDisplay()
            
            
            //            tmRemoteView.view[indexPath.item].rtcRemoteView?.setSize(CGSize(width: 200, height: 200))
            //            tmRemoteView.view[indexPath.item].rtcRemoteView?.setNeedsLayout()
            
            
            
            
            default:
                print()
            }
            
            //         print("cell.count \(CollectionViewCell.count) , tmRemoteView.view.count \(tmRemoteView.view.count)")
            
            
            
            
            //        cell.videoView.addSubview(cell.labelView)
            //            tmRemoteView.view[indexPath.item].rtcRemoteView?.addSubview(cell.labelView)
            
            
            
            
            return cell
            
        }
        else if tmRemoteView.view.count > viewBreakAtNumber {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
            //            print("inside cell for item at second collectionview indexPath.item = \(indexPath.item)")
            //            print("inside cell for item at second collectionview indexPath.item + viewBreakAtNumber = \(indexPath.item + viewBreakAtNumber)")
            //        let label = UILabel()
            //        label.textColor = .white
            //            switch tmRemoteView.view.count {
            //            case 1:
            //
            //
            //                cell.videoView.addSubview(tmRemoteView.view[indexPath.item].rtcRemoteView!)
            //                cell.label.text = username
            //
            //
            //
            //            case 2..<10:
            //            print("tmRemoteView.view[indexPath.item].name \(tmRemoteView.view[indexPath.item].name ?? "")")
            cell.videoView.addSubview(tmRemoteView.view[indexPath.item + viewBreakAtNumber ].rtcRemoteView!)
            cell.label.text = tmRemoteView.view[indexPath.item + viewBreakAtNumber].name ?? ""
            
            
            
            //
            //            default:
            //                print()
            //            }
            //
            //         print("cell.count \(CollectionViewCell.count) , tmRemoteView.view.count \(tmRemoteView.view.count)")
            
            
            
            
            //            cell.videoView.addSubview(cell.labelView)
            
            
            
            
            return cell
            
            
            
            
        }
        
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        return cell
    }
    
    
    
    
    
    
    
    // 1
    
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 2
        //        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        //        let availableWidth = view.frame.width - paddingSpace
        //        let widthPerItem = availableWidth / itemsPerRow
        
        //                print("****Function: \(#function), line: \(#line)****\n--  tmRemoteView.view.count \(tmRemoteView.view.count)")
        
        
        //
        //        let width = collectionView.frame.width
        //           let rect = AVMakeRect(aspectRatio: CGSize(width: 16, height: 9), insideRect: CGRect(origin: .zero, size: CGSize(width: width / 3, height: CGFloat.infinity)))
        //           let videoHeight: CGFloat = rect.size.height
        //           return CGSize(width: width, height: videoHeight)
        
        
        
        
        
        if collectionView == firstCollectionView {
            
            
            
            switch tmRemoteView.view.count {
            case 0...1:
                
                
                
                
                let width = self.view.frame.width - 10
                //                let height = self.view.frame.height - (self.roomNameLblView.frame.height + 30)
                //                let height = (UIApplication.shared.statusBarOrientation == .portrait ? safeAreaHeight : self.view.frame.height) - (self.roomNameLblView.frame.height + 30)
                let height = self.firstCollectionView.frame.height - 10
                
                
                tmRemoteView.view[indexPath.item].rtcRemoteView?.frame =  CGRect(x: 0, y: 0, width: width, height: height)
                
                //            print("views \(tmRemoteView.view.count) width x height \(width)x\(height)")
                
                return CGSize(width: width, height: height)
            case 2:
                
                // /*
                let width = UIApplication.shared.statusBarOrientation == .portrait ? (self.firstCollectionView.frame.width - 10): (self.firstCollectionView.frame.width/2 - 2)
                
                
                
                //                let height = UIApplication.shared.statusBarOrientation == .portrait ? (safeAreaHeight/2 - 40) : (self.view.frame.height - 50)
                let height = UIApplication.shared.statusBarOrientation == .portrait ? (self.firstCollectionView.frame.height - 15) / 2 : (self.firstCollectionView.frame.height - 10)
                
                
                var size = tmRemoteView.view[indexPath.item].size
                
                
                
                //            if ( tmRemoteView.view[indexPath.item].size == nil)
                //            {
                
                size = CGSize(width: width, height: height)
                tmRemoteView.view[indexPath.item].rtcRemoteView?.frame =  CGRect(x: 0, y: 0, width: width, height: height)
                //            }else{
                //                tmRemoteView.view[indexPath.item].rtcRemoteView?.frame.size = size!
                //            }
                //                tmRemoteView.view[indexPath.item].rtcRemoteView?.contentMode = self.contentMode
                //                tmRemoteView.view[indexPath.item].rtcRemoteView?.setNeedsLayout()
                collectionView.setNeedsLayout()
                self.view.setNeedsLayout()
                
                //                print("view \(indexPath.item)  cell \(width)x\(height) ")
                //                print("view \(indexPath.item)  rtcvideo frame \(String(describing: tmRemoteView.view[indexPath.item].rtcRemoteView?.frame.width))x\(String(describing: tmRemoteView.view[indexPath.item].rtcRemoteView?.frame.height)) ")
                //                print("view \(indexPath.item)  rtcvideo bounds \(String(describing: tmRemoteView.view[indexPath.item].rtcRemoteView?.bounds.width))x\(String(describing: tmRemoteView.view[indexPath.item].rtcRemoteView?.bounds.height)) ")
                
                tmRemoteView.view[indexPath.item].rtcRemoteView?.sizeToFit()
                //                print("sizeThatFits \(String(describing: tmRemoteView.view[indexPath.item].rtcRemoteView?.sizeThatFits(CGSize(width: width, height: height))))")
                
                return size!
            //                return (tmRemoteView.view[indexPath.item].rtcRemoteView?.sizeThatFits(CGSize(width: width, height: height)))!
            //  */
            
            //            return tmRemoteView.view[indexPath.item].size ?? CGSize(width: 100, height: 100)
            case 3...100:
                
                //            print("indexPath.item \(indexPath.item)")
                var size = tmRemoteView.view[indexPath.item].size
                
                //for 3 views
                if indexPath.item == 2 && tmRemoteView.view.count == 3{
                    let width = UIApplication.shared.statusBarOrientation == .portrait ? (self.firstCollectionView.frame.width) - 1 : (self.firstCollectionView.frame.width) - 1
                    let height = UIApplication.shared.statusBarOrientation == .portrait ? (self.firstCollectionView.frame.height / 2 )  - 5 : (self.firstCollectionView.frame.height/2 - 10)
                    
                    //                if ( tmRemoteView.view[indexPath.item].size == nil)
                    //                {
                    
                    size = CGSize(width: width, height: height)
                    tmRemoteView.view[indexPath.item].rtcRemoteView?.frame =  CGRect(x: 0, y: 0, width: width, height: height)
                    //                }else{
                    //                    tmRemoteView.view[indexPath.item].rtcRemoteView?.frame.size = size!
                    //                }
                    return size!
                    
                }
                
                let width = (self.firstCollectionView.frame.width/2) - 1
                let height =  (UIApplication.shared.statusBarOrientation == .portrait ? self.firstCollectionView.frame.height : self.firstCollectionView.frame.height) / 2 - 10
                //                if ( tmRemoteView.view[indexPath.item].size == nil)
                //                {
                
                size = CGSize(width: width, height: height)
                tmRemoteView.view[indexPath.item].rtcRemoteView?.frame =  CGRect(x: 0, y: 0, width: width, height: height)
                //                }else{
                //                    tmRemoteView.view[indexPath.item].rtcRemoteView?.frame.size = size!
                //                }
                //                tmRemoteView.view[indexPath.item].rtcRemoteView?.contentMode = .scaleAspectFill
                //                tmRemoteView.view[indexPath.item].rtcRemoteView?.setNeedsLayout()
                //            print("views \(tmRemoteView.view.count) width x height \(width)x\(height)")
                
                return size!
                
                
                
                
//            case 5...100:
//
//
//
//
//
//                let width = (self.firstCollectionView.frame.width/2) - 1
//                //    let height =  (UIApplication.shared.statusBarOrientation == .portrait ? self.firstCollectionView.frame.height  : self.firstCollectionView.frame.height) / 3 - 30
//                let height : CGFloat = safeAreaHeight / 3
//
//                tmRemoteView.view[indexPath.item].rtcRemoteView?.frame =  CGRect(x: 0, y: 0, width: width, height: height)
//                //            print("views \(tmRemoteView.view.count) width x height \(width)x\(height)")
//
//                return CGSize(width: width, height: height)
//
            default:
                print()
            }
            
            return CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
            
            
        } else{
            
            var size : CGSize = CGSize(width: 0.0, height: 0.0)
            
            if UIApplication.shared.statusBarOrientation == .portrait
            {
                let value =  100
                size = CGSize(width: value, height: value)
                
            }else{
                
                let width = (self.firstCollectionView.frame.width/2) - 1
                let height : CGFloat = safeAreaHeight / 3
                
                size = CGSize(width: width, height: height)
                
            }
            
            
            tmRemoteView.view[indexPath.item + viewBreakAtNumber].rtcRemoteView?.frame =  CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
            
            
            
            //            tmRemoteView.view[indexPath.item + viewBreakAtNumber].rtcRemoteView?.frame =  CGRect(x: 0, y: 0, width: value, height: value)
            
            return size
            
        }
    }
    
    
    // 3
    func collectionView(
        _ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.top
        //        return 0.0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        //        return sectionInsets.top
        return 0.0
        
    }
    
    
    
    
    
    
    
 }
 
 
 
 //extension UIViewController: CommandDelegate {
 //    public func receive(strData: String) {
 //
 //    }
 //
 //    public func getSendData() -> String {
 //
 //    }
 //
 //
 //}
