 
//

import Foundation
import WebRTC
import Starscream

public class  WebRTCOperator: RTCClientDelegate {
    
    
    var delegate:CodelabsRTCClientDelegate
    var clSocket:CodelabsRTCServerDelegate
    var delegateArr:[String:CodelabsRTCClientDelegate] = [String:CodelabsRTCClientDelegate]()
    var clSocketArr:[String:CodelabsRTCServerDelegate] = [String:CodelabsRTCServerDelegate]()
    
    
    // TODO  moew socket , move logic from OMPoperater
    public init(delegate:CodelabsRTCClientDelegate,clSocket:CodelabsRTCServerDelegate) {
        self.delegate = delegate
        self.clSocket = clSocket
    }
    
    func addUnitServer(_ id:String,clSocket:CodelabsRTCServerDelegate)
    {
        self.clSocketArr[id] = clSocket
    }
    func addUnitDelegate(_ id:String,delegate:CodelabsRTCClientDelegate)
    {
        self.delegateArr[id] = delegate
    }
    
     func getServer(_ id:String) -> CodelabsRTCServerDelegate {
        if let _server = self.clSocketArr[id] {
            return _server
        }
        return clSocket
    }
    
    public func disconnectAll()
    {
        for server in clSocketArr {
            server.value.disconnectMeeting()
        }
        clSocket.disconnectMeeting()
    }
    
     func getDelegate(_ id:String) -> CodelabsRTCClientDelegate {
        if let _delegate = self.delegateArr[id] {
            return _delegate
        }
        return delegate
    }
    
    public func rtcClient(_ id:String ,client: RTCClient, didChangeConnectionState connectionState: RTCIceConnectionState) {
        getDelegate(id).rtcClient(id, didChangeConnectionState: connectionState)
    }
    
    
    public func rtcClient(_ id : String,client : RTCClient, didReceiveError error: Error) {
        // Error Received
        getDelegate(id).rtcClient(id, didReceiveError: error)
    }
    
    public func rtcClient(_ id:String ,client : RTCClient, didGenerateIceCandidate iceCandidate: RTCIceCandidate) {
        // iceCandidate generated, pass this to other user using any signal method your app uses

        let cData = CandidateData(sdpMid: iceCandidate.sdpMid!, lineIndex: iceCandidate.sdpMLineIndex, candidate: iceCandidate.sdp)
        let myServer = getServer(id)
        if let handle_id = myServer.getHandIdForCodelabsId(id: id)
        {
            myServer.sendCommand(command: SendCandidateCommand(delegate: myServer as! RTCVideoServer, handleId: handle_id, data: cData))
        }
        
    }
    
    public func rtcClient(_ id : String,client: RTCClient, startCallWithSdp sdp: RTCSessionDescription) {
        // SDP generated, pass this to other user using any signal method your app uses
        if sdp.type == .offer
        {
            let jData = JsepData(type: "offer", sdp: sdp.sdp)
            let myServer = getServer(id)
            if let handle_id = myServer.getHandIdForCodelabsId(id: id)
            {
                myServer.sendCommand(command: SendOfferCommand(delegate: myServer as! RTCVideoServer, handleId: handle_id, data: jData))
            }
            
        }
        else
        {
            let jData = JsepData(type: "answer", sdp: sdp.sdp)
            let myServer = getServer(id)
            if let handle_id = myServer.getHandIdForCodelabsId(id: id)
            {
                myServer.sendCommand(command: SendAnswerCommand(delegate: myServer as! RTCVideoServer, handleId: handle_id, data: jData))
            }
            
        }
        
    }
    
    
    
    public func rtcClient(_ id : String,client : RTCClient, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
        // Use localVideoTrack generated for rendering stream to remoteVideoView
        getDelegate(id).rtcClient(id, didReceiveLocalVideoTrack: localVideoTrack)
        
    }
    public func rtcClient(_ id : String,client : RTCClient, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
        // Use remoteVideoTrack generated for rendering stream to remoteVideoView
        
        
        getDelegate(id).rtcClient(id, didReceiveRemoteVideoTrack: remoteVideoTrack)
//        print("didReceiveRemoteVideoTrack  \(client.)")
    }
    public func rtcClient(_ id : String,client : RTCClient, didRemoveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
        // Use remoteVideoTrack generated for rendering stream to remoteVideoView
        getDelegate(id).rtcClient(id, didReceiveRemoteVideoTrack: remoteVideoTrack)
//        getDelegate(id).rtcClient(id, client: client, didRemoveRemoteVideoTrack: remoteVideoTrack)
    }
     private func returnJsonStr(data : [String : Any])->String
    {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data,
                                                      options: .prettyPrinted)
            return (String(data: jsonData, encoding: String.Encoding.utf8))!
        } catch let error {
            print("error converting to json: \(error)")
            print("****Function: \(#function), line: \(#line)****\n-- ")
            
            return ""
        }
    }
}
 
 
 
public protocol CodelabsRTCServerDelegate: class {
    func sendCommand(command:BaseCommand)
    func getHandIdForCodelabsId(id:String)->Int64?
    func getCodelabsIdFromHandId(id:Int64)->String?
    func disconnectMeeting()
    
}

public protocol CodelabsRTCClientDelegate: class {
    func rtcClient(_ id : String, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack)
    func rtcClient(_ id : String, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack)
    func rtcClient(_ id:String,client : RTCClient, didRemoveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack)

    func rtcClient(_ id : String, didReceiveError error: Error)
    func rtcClient(_ id : String, didChangeConnectionState connectionState: RTCIceConnectionState)
    
}

