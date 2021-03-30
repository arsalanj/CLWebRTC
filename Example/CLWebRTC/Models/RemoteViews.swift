 
//

import Foundation
import CLWebRTC
 import WebRTC




class RemoteViews {

    
    var roomName = "Demo Room"
    var view : [RemoteView] = []
    
    
    
  
    
    func initView(remoteView: RTCMTLVideoView = RTCMTLVideoView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))){
        
//        remoteView.setSize(1)
        let rv = RemoteView(id: "", rtcRemoteView: remoteView)
        rv.uiView?.addSubview(remoteView)
        view.append(rv)
        
    }
    
    func add(videoTrack: RTCVideoTrack, remoteView: RTCMTLVideoView,id:String) -> Bool{
 
        let condition = !view.contains(where: {$0.id == id})
        
        
        if condition {
            let remoteView = RemoteView(id: id,remoteVideoTrack: videoTrack, rtcRemoteView: remoteView)
//            remoteView
            
            view.append(remoteView)
            
        }
        
         return condition
    }
    
    
    func removeRemoteView(id : String) -> Int{
        
        if let i = view.firstIndex(where: { $0.id == id }) {
            //            print("\(students[i]) starts with 'A'!")
            return i
            
        }
        
        return -1
    }
    
    
    
    
    
 
    
    
}





class RemoteView {
    
    var remoteVideoTrack:RTCVideoTrack?
    var rtcRemoteView:RTCMTLVideoView?
    var id : String?
    var name : String?
    var uiView:UIView?
    var size : CGSize?
    
    init(id : String,remoteVideoTrack: RTCVideoTrack) {
        self.id = id
        
        self.remoteVideoTrack = remoteVideoTrack
        
        

    }
    
    init(id : String,rtcRemoteView: RTCMTLVideoView) {
        self.id = id
        
        self.rtcRemoteView = rtcRemoteView
        
    }
    init(id : String,remoteVideoTrack:RTCVideoTrack,rtcRemoteView: RTCMTLVideoView) {
        self.id = id
        //        if remoteVideoTrack != nil{
        self.remoteVideoTrack = remoteVideoTrack
        //        }
        self.rtcRemoteView = rtcRemoteView
        
    }
    
}
