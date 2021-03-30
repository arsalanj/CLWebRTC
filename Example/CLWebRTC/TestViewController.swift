

import UIKit
import CLWebRTC
import WebRTC
import SnapKit

class TestViewController: UIViewController ,CodelabsRTCClientDelegate,RTCEAGLVideoViewDelegate{
    func rtcClient(_ id: String, client: RTCClient, didRemoveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
        
    }
    
    
    
    @IBOutlet var localView:UIView!
    @IBOutlet var removeView:UIView!
    @IBOutlet var removeView2:UIView!
    var rtcLocalView:RTCEAGLVideoView?
    //    var rtcLocalView:RTCCameraPreviewView?
    var rtcRemoveView:RTCEAGLVideoView?
    var rtcRemoveView2:RTCEAGLVideoView?
    var rtcRemoveViews:[RTCEAGLVideoView] = []
    var localVideoTrack:RTCVideoTrack?
    var removeVideoTrack:RTCVideoTrack?
    var removeVideoTrack2:RTCVideoTrack?
    var removeVideoTracks:[RTCVideoTrack] = []
    
    var rtcManager:RTCClient?
    var clientServer: RTCVideoServer?
    var rtcOperator: WebRTCOperator?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
   
        
        rtcLocalView = RTCEAGLVideoView(frame: CGRect(x: 0, y: 0, width: localView.frame.width, height: localView.frame.height))
        rtcRemoveView = RTCEAGLVideoView(frame: CGRect(x: 0, y: 0, width: removeView.frame.width, height: removeView.frame.height))
        rtcRemoveView2 = RTCEAGLVideoView(frame: CGRect(x: 0, y: 0, width: removeView.frame.width, height: removeView.frame.height))
        
        localView.addSubview(rtcLocalView!)
        
        
//        localView.transform = CGAffineTransform(scaleX: 2, y: 1)

        
        var iceServers = [RTCIceServer]()
        //            iceServers.append(RTCIceServer(urlStrings: iceServerdata.urls, username: iceServerdata.username, credential: iceServerdata.credential))
        iceServers.append(RTCIceServer(urlStrings:["stun:stun.l.google.com:19302"] ))
        let n = Int(arc4random_uniform(11142))
        let myId = String(n)
        rtcManager = RTCClient(videoCall: true)
        rtcManager?.defaultIceServer = iceServers
        clientServer = RTCVideoServer(url: "wss://webrtc2.codelabs.inc:8989/janus", client: rtcManager!)
        clientServer?.display = myId
//        clientServer?.initPublish = false
        rtcOperator = WebRTCOperator(delegate: self,clSocket: clientServer!)
        rtcManager?.delegate = rtcOperator
        clientServer?.registerMeetRoom(1234)
        
        
        
        //        _=setTimeout(delay: 15, block: switchCanera)
    }
    
    func switchCanera()
    {
        if(localVideoTrack != nil && (localVideoTrack!.source as? RTCAVFoundationVideoSource)?.canUseBackCamera == true){
            (localVideoTrack!.source as! RTCAVFoundationVideoSource).useBackCamera = !(localVideoTrack!.source as! RTCAVFoundationVideoSource).useBackCamera
        }
    }
    
    
    @IBAction public func unpublishMyself()
    {
        clientServer?.unpublishMyself()
        rtcLocalView?.removeFromSuperview()
    }
    @IBAction public func publishMyself()
    {
        clientServer?.publishMyself()
        localView.addSubview(rtcLocalView!)
    }
    
    
    func videoView(_ videoView: RTCEAGLVideoView, didChangeVideoSize size: CGSize) {
        //        rtcRemoveView?.renderFrame(RTCVideoFrame(buffer: <#T##RTCVideoFrameBuffer#>, rotation: <#T##RTCVideoRotation#>, timeStampNs: <#T##Int64#>))
        //        print("......videoView...\(videoView==rtcRemoveView)")
//        self.rtcRemoveView?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//        self.removeView?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        
        
    }
    
    
    func rtcClient(_ id: String, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
        //        rtcLocalView?.captureSession=(localVideoTrack.source as! RTCAVFoundationVideoSource).captureSession
        self.localVideoTrack = localVideoTrack
        localVideoTrack.add(self.rtcLocalView!)
    }
    
    func rtcClient(_ id: String, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
        print("[didReceive RemoteVideo Track..]")
        
        DispatchQueue.main.async{
            if(self.rtcRemoveView?.tag==0){
                self.removeVideoTrack = remoteVideoTrack
                self.rtcRemoveView?.delegate = self
                self.rtcRemoveView?.tag = Int(id)!
                self.removeView.addSubview(self.rtcRemoveView!, withFillingMode: .aspectFit(ratio: 2.0))
                
                
//                self.rtcRemoveView!.translatesAutoresizingMaskIntoConstraints = false

//                let margins = self.removeView.layoutMarginsGuide
//
//
//                self.rtcRemoveView!.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0.0).isActive = true
//                self.rtcRemoveView!.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0.0).isActive = true
//                self.rtcRemoveView!.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0.0).isActive = true
//                self.rtcRemoveView!.heightAnchor.constraint(equalTo: self.rtcRemoveView!.widthAnchor, multiplier: 1.0/3.0).isActive = true
                
//                let maxWidthContainer: CGFloat = self.removeView.frame.width
//                let maxHeightContainer: CGFloat = self.removeView.frame.height
//                self.rtcRemoveView!.snp.makeConstraints { (make) in
//                    make.centerY.equalTo(self.removeView)
//
//
//                    make.left.right.top.bottom.equalTo(self.removeView)
//
////                    // at least 38 points "padding" on all 4 sides
////
////                    // leading and top >= 38
////                    make.leading.top.greaterThanOrEqualTo(5)
////
////                    // trailing and bottom <= 38
////                    make.trailing.bottom.lessThanOrEqualTo(5)
////
////                    // width ratio to height
////                    make.width.equalTo(self.rtcRemoveView!.snp.height).multipliedBy(maxWidthContainer/maxHeightContainer)
////
////                    // width and height equal to superview width and height with high priority (but not required)
////                    // this will make it as tall and wide as possible, until it violates another constraint
////                    make.width.height.equalToSuperview().priority(.high)
////
////                    // max height
////                    make.height.lessThanOrEqualTo(maxHeightContainer)
//
//
//                }
//
                
//                self.rtcRemoveView?.contentMode = .scaleAspectFill
                remoteVideoTrack.add(self.rtcRemoveView!)
            }else if (self.rtcRemoveView2?.tag==0){
                self.removeVideoTrack2 = remoteVideoTrack
                self.rtcRemoveView2?.delegate = self
                self.rtcRemoveView2?.tag = Int(id)!
                self.removeView2.addSubview(self.rtcRemoveView2!)
                remoteVideoTrack.add(self.rtcRemoveView2!)
                
            }
        }
        
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
            DispatchQueue.main.async{
                if(self.rtcRemoveView?.tag==Int(id)){
                    self.removeVideoTrack?.remove(self.rtcRemoveView!)
                    self.rtcRemoveView?.removeFromSuperview()
                    self.rtcRemoveView?.tag = 0
                }else if (self.rtcRemoveView2?.tag==Int(id)){
                    self.removeVideoTrack2?.remove(self.rtcRemoveView2!)
                    self.rtcRemoveView2?.removeFromSuperview()
                    self.rtcRemoveView2?.tag = 0
                }
            }
        }
        if(connectionState == .completed){
            print("[didChangeConnectionState]:completed)")
        }
        if(connectionState == .connected){
            print("[didChangeConnectionState]:connected)")
        }
        if(connectionState == .disconnected){
            print("[didChangeConnectionState]:disconnected)")
        }
        if(connectionState == .failed){
            print("[didChangeConnectionState]:failed)")
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

