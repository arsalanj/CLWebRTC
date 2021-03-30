//
 
//

import Foundation

public protocol CommandDelegate: class {
    func receive(strData:String)
    func getSendData()->String
    
}

public class BaseCommand:CommandDelegate
{
    var time:TimeInterval
    var transaction:String
   public var delegate:RTCVideoServer
    var handle_id:Int64
    var preData:Codable?
    public init(delegate:RTCVideoServer,handleId:Int64,data:Codable? = nil) {
        self.transaction = UUID.init().uuidString
        self.delegate = delegate
        self.handle_id = handleId
        self.preData = data
        self.time = Date().timeIntervalSince1970
    }
    
    final public func getSendData() -> String {
        var sendData = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: getDataObject(),options: .prettyPrinted)
            sendData = String(data: jsonData, encoding: String.Encoding.utf8)!
            if showWEBRTCLog {
                let words = ["ack","keepalive"]
                if !words.contains(where: {sendData.contains($0)}) {
                print("sendData: \(sendData)")
                }
                
            }
        } catch let error {
           print("\(self) error converting to json: \(error) ")
 
        }
        return sendData
    }
    
    func getDataObject()->[String : Any]{return [:]}
    
    public func receive(strData str: String) {
        
//        print("****Function: \(#function), line: \(#line)****\n-- ")
    }
    
    
    public func errorReceived(command: BaseCommand, error : String){
        
        
 
         delegate.codelabsServerError(error: error)
        
    }
}


class CreateCommand:BaseCommand
{
    override func receive(strData: String) {
        do {
            let data:CreateData = try JSONDecoder().decode(CreateData.self, from: strData.data(using: .utf8)!)
            
            delegate.setSessionId( data.data.id)
            delegate.sendCommand(command: AttachCommand(delegate: delegate, handleId: 0))
            
        }catch let error {
           print("\(self) error converting to json: \(error) ")
            super.errorReceived(command: self, error: error.localizedDescription)
        }
    }
    
    override func getDataObject() -> [String : Any] {
        return ["codelabs": "create", "transaction":transaction] as [String : Any]
    }
}




class CreateRoomCommand:BaseCommand
{
    override func receive(strData: String) {
        do {
            let data:CreateRoomData = try JSONDecoder().decode(CreateRoomData.self, from: strData.data(using: .utf8)!)
            
            delegate.setSessionId( (data.session_id))
            
            delegate.roomId = (data.plugindata.data.room)
            //            delegate.sendCommand(command: AttachCommand(delegate: delegate, handleId: 0))
            delegate.sendCommand(command: JoinForPublisherCommand(delegate: delegate, handleId: handle_id))
            
            
        }catch let error {
            print("\(self) error converting to json: \(error) ")
            super.errorReceived(command: self, error: error.localizedDescription)
        }
    }
    
    override func getDataObject() -> [String : Any] {
        return [
            "body": [
                "request": "create",
                "description": delegate.roomName,
                "bitrate": 512000
            ],
            "session_id":delegate.session_id,
            "handle_id":handle_id,
            "codelabs": "message",
            "transaction":transaction
            
        ] as [String : Any]
    }
}



class AttachCommand:BaseCommand
{
    override func receive(strData: String) {
        do {
            let data:AttachData = try JSONDecoder().decode(AttachData.self, from: strData.data(using: .utf8)!)
            handle_id = data.data.id
            
            if(delegate.type == .Listparticipants){
                delegate.sendCommand(command: ListparticipantsCommand(delegate: delegate, handleId: handle_id))
            }else{
                if(preData == nil){
                    
                    if delegate.type == .Create {
                        delegate.sendCommand(command: CreateRoomCommand(delegate: delegate, handleId: handle_id))
                    }
                    
                    
                    
                    else{
                        delegate.sendCommand(command: JoinForPublisherCommand(delegate: delegate, handleId: handle_id))
                    }
                }else{
                    delegate.sendCommand(command: JoinForSubscriberCommand(delegate: delegate, handleId: handle_id,data:preData))
                }
            }
        }catch let error {
            print("\(self) error converting to json: \(error) ")
            super.errorReceived(command: self, error: error.localizedDescription)
            print("here")
        }
    }
    
    override func getDataObject() -> [String : Any] {
        return ["codelabs": "attach", "transaction":transaction, "session_id":delegate.session_id,"plugin":"janus.plugin.videoroom","opaque_id":"videoroomtest-"
        ] as [String : Any]
    }
}

class JoinForPublisherCommand:BaseCommand
{
    override func receive(strData: String) {
        do {
            if strData.contains("event")
            {
                let data:JoinData = try JSONDecoder().decode(JoinData.self, from: strData.data(using: .utf8)!)
                
                
                if data.plugindata.data.error_code ?? 0 > 0 {
                    super.errorReceived(command: self, error: data.plugindata.data.error ?? "Unknown Error" )
                    return
                }
                
                let id = String(data.plugindata.data.id ?? 0)
                
                delegate.myCodelabsId = id
                delegate.codelabsId_id_to_handle[delegate.myCodelabsId] = handle_id
                
                if(delegate.initPublish){
                    delegate.client?.startConnection(id, localStream: true)
                    delegate.client?.makeOffer(id)
                }
                
                delegate.private_id = data.plugindata.data.private_id!
                delegate.joinedParticipant = data


                var index = 0
                for publisher in data.plugindata.data.publishers ?? []
                {
                    if index == delegate.maxViewer {
                        return
                    }
                    delegate.info_from_codelabsId[publisher.id] = publisher
                    delegate.sendCommand(command: AttachCommand(delegate: delegate, handleId: handle_id,data:AttachId(id: publisher.id)))
                    index += 1
                }
            }
        }catch let error {
           print("\(self) error converting to json: \(error)")
            super.errorReceived(command: self, error: error.localizedDescription)
        }
    }
    
    override func getDataObject() -> [String : Any] {
        
        return ["codelabs": "message", "transaction":transaction, "session_id":delegate.session_id,"handle_id":handle_id,"body":["display":delegate.display,"ptype":"publisher","request":"join","room":delegate.roomId]
            ] as [String : Any]
    }
}


class JoinForSubscriberCommand:BaseCommand
{
    override func receive(strData: String) {
        do {
            if strData.contains("event")
            {
                let data:JoinOfferData = try JSONDecoder().decode(JoinOfferData.self, from: strData.data(using: .utf8)!)
                
                if data.plugindata.data.error_code ?? 0 > 0 {
                    
                    super.errorReceived(command: self, error: data.plugindata.data.error ?? "Unknown Error" )

                    return
                }
                let id = String(data.plugindata.data.id!)
        
                delegate.client?.startConnection(id, localStream: false)
                delegate.client?.createAnswerForOfferReceived(id, withRemoteSDP: data.jsep.sdp)
            }
        }catch let error {
            print("error converting to json on JoinForSubscriberCommand: \(error)")
        }
    }
    
    override func getDataObject() -> [String : Any] {

        let pData:AttachId = preData as! AttachId
        delegate.codelabsId_id_to_handle[String(pData.id)] = handle_id
        return ["codelabs": "message", "transaction":transaction, "session_id":delegate.session_id,"handle_id":handle_id,"body":["display":"subscriber", "feed":pData.id,"private_id":delegate.private_id,"ptype":"subscriber","request":"join","room":delegate.roomId]
            ] as [String : Any]
    }
}

class NewJoinActiveCommand:BaseCommand
{
    override func receive(strData: String) {
        do {
            if strData.contains("event")
            {
                let data:JoinData = try JSONDecoder().decode(JoinData.self, from: strData.data(using: .utf8)!)
                if data.plugindata.data.error_code ?? 0 > 0 {
                    
                    super.errorReceived(command: self, error: data.plugindata.data.error ?? "Unknown Error" )

                    return
                }
                let id = data.plugindata.data.publishers![0].id
                delegate.info_from_codelabsId[id] = data.plugindata.data.publishers![0]
                delegate.sendCommand(command: AttachCommand(delegate: delegate, handleId: 0, data: AttachId(id: id)))
                
                delegate.joinedParticipant = data

            }
        }catch let error {
           print("\(self) error converting to json: \(error) ")
            super.errorReceived(command: self, error: error.localizedDescription)
        }
    }
    
}
class ReceiveUnpublishCommand:BaseCommand
{
    override func receive(strData: String) {
        do {
            if strData.contains("event")
            {
                let data:UnpublishData = try JSONDecoder().decode(UnpublishData.self, from: strData.data(using: .utf8)!)
                if data.plugindata.data.error_code ?? 0 > 0 {
                    
                    super.errorReceived(command: self, error: data.plugindata.data.error ?? "Unknown Error" )

                    return
                }
                delegate.disconnectMeetingById(id: String(data.plugindata.data.unpublished!))
            }
        }catch let error {
           print("\(self) error converting to json: \(error) ")
            super.errorReceived(command: self, error: error.localizedDescription)
        }
    }
    
}
public class UnpublishCommand:BaseCommand
{
    override public func receive(strData: String) {
        if strData.contains("event") ,let _codelabsId = delegate.getCodelabsIdFromHandId(id: handle_id)
        {
            delegate.disconnectMeetingById(id:_codelabsId )
        }
    }
    override func getDataObject() -> [String : Any] {
        return ["codelabs": "message", "transaction":transaction, "session_id":delegate.session_id,"handle_id":handle_id,"body":["request":"unpublish"]
            ] as [String : Any]
    }
}
//---------------------------------------------------------

class ListparticipantsCommand:BaseCommand
{
    override func receive(strData: String) {
        do {
            let data:JoinParticipantsData = try JSONDecoder().decode(JoinParticipantsData.self, from: strData.data(using: .utf8)!)
            if data.plugindata.data.error_code ?? 0 > 0 {
                
                super.errorReceived(command: self, error: data.plugindata.data.error ?? "Unknown Error" )

                return
            }
            delegate.sendCommand(command: JoinParticipantCommand(delegate: delegate, handleId: handle_id,data:data))
            delegate.participantsData = data
            
            dump("strData \(strData)")
            
            
//            delegate.participantsData?.plugindata.plugin.

        }catch let error {
           print("\(self) error converting to json: \(error) ")
            super.errorReceived(command: self, error: error.localizedDescription)
        }
    }
    
    override func getDataObject() -> [String : Any] {
        return ["codelabs": "message", "transaction":transaction, "session_id":delegate.session_id,"handle_id":handle_id,"body":["request":"listparticipants","room":delegate.roomId]
            ] as [String : Any]
    }
}

class JoinParticipantCommand:BaseCommand
{
    override func receive(strData: String) {
        do {
            if strData.contains("event")
            {
                let data:JoinOfferData = try JSONDecoder().decode(JoinOfferData.self, from: strData.data(using: .utf8)!)
                if data.plugindata.data.error_code ?? 0 > 0 {
                    
                    super.errorReceived(command: self, error: data.plugindata.data.error ?? "Unknown Error" )

                    return
                }
                let id = String(data.plugindata.data.id!)
                var iceServers = [RTCIceServer]()
                //            iceServers.append(RTCIceServer(urlStrings: iceServerdata.urls, username: iceServerdata.username, credential: iceServerdata.credential))
                iceServers.append(RTCIceServer(urlStrings:["stun:stun.l.google.com:19302"] ))
                delegate.client?.setIceServer(id, iceServers: iceServers)
                delegate.client?.startConnection(id, localStream: false)
                delegate.client?.createAnswerForOfferReceived(String(data.plugindata.data.id!), withRemoteSDP: data.jsep.sdp)
                delegate.roomName = data.plugindata.data.videoroom!
                dump("str \(strData)")
                
                
            }
        }catch let error {
           print("\(self) error converting to json: \(error) ")
            super.errorReceived(command: self, error: error.localizedDescription)
        }
    }
    
    override func getDataObject() -> [String : Any] {
        let pData:JoinParticipantsData = preData as! JoinParticipantsData
        let view_id = pData.plugindata.data.participants![0].id
        delegate.codelabsId_id_to_handle[String(view_id)] = handle_id
        return ["codelabs": "message", "transaction":transaction, "session_id":delegate.session_id,"handle_id":handle_id,"body":["feed":view_id,"private_id":0,"ptype":"subscriber","request":"join","room":delegate.roomId]
            ] as [String : Any]
    }
}

import WebRTC
class SendOfferCommand:BaseCommand
{
    override func receive(strData: String) {
        do {
            if strData.contains("event")
            {
                let data:OfferReturnData = try JSONDecoder().decode(OfferReturnData.self, from: strData.data(using: .utf8)!)
                if data.plugindata.data.error_code ?? 0 > 0 {
                    
                    super.errorReceived(command: self, error: data.plugindata.data.error ?? "Unknown Error" )

                    return
                }
                if let id = delegate.getCodelabsIdFromHandId(id: data.sender){
                    delegate.client?.handleAnswerReceived(id,withRemoteSDP: data.jsep.sdp)
                }
                
            }
        }catch let error {
           print("\(self) error converting to json: \(error) ")
            super.errorReceived(command: self, error: error.localizedDescription)
        }
    }
    
    override func getDataObject() -> [String : Any] {
        let pData:JsepData = preData as! JsepData
        return ["codelabs": "message", "transaction":transaction, "session_id":delegate.session_id,"handle_id":handle_id,"body":["request":"configure","audio":true,"video":true],"jsep":["type":pData.type,"sdp":pData.sdp]
            ] as [String : Any]
    }
}
class SendAnswerCommand:BaseCommand
{
    
    override func getDataObject() -> [String : Any] {
        let pData:JsepData = preData as! JsepData
        return ["codelabs": "message", "transaction":transaction, "session_id":delegate.session_id,"handle_id":handle_id,"body":["request":"start","room":delegate.roomId],"jsep":["type":"answer","sdp":pData.sdp]
            ] as [String : Any]
    }
}
class SendCandidateCommand:BaseCommand
{
    
    override func getDataObject() -> [String : Any] {
        let pData:CandidateData = preData as! CandidateData
        return ["codelabs": "trickle", "transaction":transaction, "session_id":delegate.session_id,"handle_id":handle_id,"candidate":["candidate":pData.candidate,"sdpMLineIndex":pData.lineIndex,"sdpMid":pData.sdpMid]
            ] as [String : Any]
    }
}
class SendCandidateEndCommand:BaseCommand
{
    
    override func getDataObject() -> [String : Any] {
        return ["codelabs": "trickle", "transaction":transaction, "session_id":delegate.session_id,"handle_id":handle_id,"candidate":["completed":true]
            ] as [String : Any]
    }
}
class KeepAliveCommand:BaseCommand
{

    override func getDataObject() -> [String : Any] {
        return ["codelabs": "keepalive", "transaction":transaction, "session_id":delegate.session_id] as [String : Any]
    }
}




