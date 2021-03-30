 
//

import Foundation
import Starscream
import WebRTC


enum CodelabsType
{
    case Join
    case Create
    case Listparticipants
}


public class RTCVideoServer: WebSocketDelegate ,CodelabsRTCServerDelegate{
  
    

    var videoServerDelegate:RTCVideoServerDelegate?


    open var initPublish = true
    open var maxViewer = 20
    open var display:String=""
    var roomId:Int64=1234
   open var roomName:String=""
    
    open var participantsData: JoinParticipantsData?
     var joinedParticipant: JoinData?
    var session_id:Int64 = 0
    var private_id:Int64 = 0
    var codelabsId_id_to_handle:[String:Int64] = [:]
    var info_from_codelabsId:[Int64:Publisher] = [:]
    open var client:RTCClient?
    
    var type:CodelabsType = .Join
    
    private var socket:WebSocket?
    private var tempRemotSdp:String?
    private var _aliveTimer:Timer?
    
    var myCodelabsId:String = ""
    
    var commandList = [BaseCommand]()
    /**
     url : handshake socket server url
     */
    public init(url:String,client:RTCClient){
        socket = WebSocket(url: URL(string:url)!, protocols: ["janus-protocol"])
        socket?.delegate = self
        self.client = client
        
        
    }
    
    func setSessionId(_ id :Int64)
    {
        session_id = id
        _aliveTimer = Timer.scheduledTimer(timeInterval: 25, target: self, selector: #selector(senfAlive), userInfo: nil, repeats: true)
  
    }
    @objc func senfAlive()
    {
        self.sendCommand(command: KeepAliveCommand(delegate: self, handleId: 0))
    }
    
    public func getHandIdForCodelabsId(id:String)->Int64?
    {
        for (codelabsId,handleId) in codelabsId_id_to_handle {
            if codelabsId == id{
                return handleId
            }
        }
        return nil
    }
    public func getCodelabsIdFromHandId(id:Int64)->String?
    {
        for (codelabsId,handleId) in codelabsId_id_to_handle {
            if handleId == id{
                return codelabsId
            }
        }
        return nil
    }
    
    public func getDisplayForCodelabsId(id:String)-> String?
    {
        for (codelabsId,publishData) in info_from_codelabsId {
            if String(codelabsId) == id {
                return publishData.display
            }
        }
        return nil
    }
    
    public func getCodelabsIdForDisplay(display:String)-> Int64?
    {
        for (codelabsId,publishData) in info_from_codelabsId {
            if publishData.display == display {
                return codelabsId
            }
        }
        return nil
    }
    
    public func getHandIdForDisplay(display:String)-> Int64?
    {
        if let codelabsId = getCodelabsIdForDisplay(display:display)
        {
            return getHandIdForCodelabsId(id: String(codelabsId))
        }
        return nil
    }
    
    public func unpublishMyself()
    {
        if let myHanldId = getHandIdForCodelabsId(id: myCodelabsId)
        {
            sendCommand(command: UnpublishCommand(delegate: self, handleId: myHanldId))
        }
    }
    public func publishMyself()
    {
        client?.startConnection(myCodelabsId, localStream: true)
        client?.makeOffer(myCodelabsId)
    }

    public func sendCommand(command:BaseCommand)
    {
        
        
        
        
        if showWEBRTCLog {
        print("Sending command \(command)")
        }
        commandList.append(command);
        let sendText = command.getSendData();
        socket?.write(string:sendText)
    }
    
    
    
    
    public func websocketDidConnect(socket: WebSocketClient) {
        
        print("[websocket connected]")
        codelabsId_id_to_handle = [:]
        info_from_codelabsId = [:]
        sendCommand(command: CreateCommand(delegate: self, handleId: 0))
    }

    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error {
            print("[websocket  is disconnected: \(e.localizedDescription)]")
            videoServerDelegate?.serverDidNotConnect(error: error)
        } else {
            print("[websocket disconnected]")
        }
    }
    
    
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
     
        onDataReceived(str: text)
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//        print("Received data: \(data.count)")
        let dataString = String(data: data, encoding: .utf8)!
        onDataReceived(str: dataString)
        
    }
    
    func onDataReceived(str:String)
    {
        //        #if DEBUG
        
        
        
        if showWEBRTCLog     {
            let words = ["ack","keepalive"]

            if !words.contains(where: {str.contains($0)})  {
                print("[Received text]:\n___start___\n \(str)\n___end___")
                
            }
            
//            print("contains \(words.contains(where: {str.contains($0)}))")
            
 
        }
//        #endif
        if(str.contains("transaction"))
        {
            for command in commandList {
                if str.contains(command.transaction)
                {
                    command.receive(strData: str)
                }
            }
        }
        else
        {
            if(str.contains("unpublished")){
                ReceiveUnpublishCommand(delegate: self, handleId: 0).receive(strData: str)
                
            }else if(str.contains("publishers")){
                
                if((client?.getConnectActiveNum())! - 1 < maxViewer){
                    NewJoinActiveCommand(delegate: self, handleId: 0).receive(strData: str)
                }
            }
        }
        
        cleanTimeOutCommad()
        
    }
    
    public func registerMeetRoom(_ roomId:Int64){
        
        
//        if type == .Create{
//
//
//        }else if type == .Join{
//
        
        
        self.roomId = roomId
        socket?.connect()
        print("[registerMeetRoom]:\(roomId),clientId:\(myCodelabsId)")
//        }
    }
    
    public func disconnectMeetingById(id:String)
    {
        client?.disconnect(id)
    }
    public func disconnectMeeting()
    {
        client?.disconnectAll()
        socket?.disconnect()
        _aliveTimer?.invalidate()
    }
    
    deinit{
        _aliveTimer?.invalidate()
        socket?.disconnect()
        socket?.delegate = nil
        socket = nil
        client?.disconnectAll()
        client?.delegate = nil
        client = nil
    }
    
//    private func doRegister()
//    {
//        let props = ["cmd": "register", "clientid":clientId,"roomid":roomId] as [String : Any]
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: props,
//                                                      options: .prettyPrinted)
//            socket?.write(string:String(data: jsonData, encoding: String.Encoding.utf8)!)
//            print("[doRegister]:\(roomId),clientId:\(clientId)")
//        } catch let error {
//            print("error converting to json: \(error)")
//        }
//    }
    
    
    func sendMsg(string :String)
    {
        socket?.write(string: string)
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
    
    private func cleanTimeOutCommad()
    {
        let now = Date().timeIntervalSince1970
        var active = [BaseCommand]()
        for command in commandList {
            if now - command.time < 30
            {
                active.append( command)
            }
        }
        commandList = active
    }
    
    
    func codelabsServerError(error : String){
        videoServerDelegate?.serverDidNotConnect(error: AppError(message: error))

    }

}


 public protocol RTCVideoServerDelegate: class {
     func serverDidNotConnect(error: Error?)
   
    
 }

 
 struct AppError {
     let message: String

     init(message: String) {
         self.message = message
     }
 }
 extension AppError: LocalizedError {
     var errorDescription: String? { return message }
 //    var failureReason: String? { get }
 //    var recoverySuggestion: String? { get }
 //    var helpAnchor: String? { get }
 }

