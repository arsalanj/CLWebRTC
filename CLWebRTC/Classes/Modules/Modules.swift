 
//

import Foundation
import WebRTC


struct send : Codable {
    var cmd:String
    var msg:String
}

struct Params : Codable {
    var result:String
    var params:Params_detail
    var msg:[String:String]
}

//struct SendSdp : Codable {
//    var type:String
//    var sdp:Sdp
//}

struct Sdp : Codable {
    var type:String
    var sdp:String
}


struct Candidate : Codable {
    var type:String
    var id:String
    var label:Int
    var candidate:String
    
}

struct Bye : Codable {
    var type:String
}


struct Params_detail : Codable {
    var error_messages:[String]
    var messages:[String]
    var room_id:String
    var client_id:String
    var turn_server_override:[ice_server]
    var pc_config:String
    var is_initiator:String
    
}

struct ice_server : Codable {
    var urls:[String]
    var username:String?
    var credential:String?
}
//-------------------------------------------------------

struct CodelabsData : Codable {

    var codelabs:String
    var transaction:String
    var session_id:Int64
}

 struct CreateData : Codable {
     struct SessionData: Codable{
         var id:Int64
     }
     var codelabs:String
     var transaction:String
     var data:SessionData
 }
 
 
 
 struct CreateRoomData : Codable {
    
    var codelabs:String
    var transaction:String
 
    var session_id: Int64
    var sender: Int64
    var plugindata: Plugindata
    
    // MARK: - Plugindata
    struct Plugindata: Codable {
       var plugin: String
       var data: DataClass
    }
    
    // MARK: - DataClass
    struct DataClass: Codable {
       var videoroom: String
       var room: Int64
       var permanent: Bool
    }

    
 }
 


struct AttachData : Codable {
    struct HandleData: Codable{
        var id:Int64
    }
    var codelabs:String
    var transaction:String
    var data:HandleData
    var session_id:Int64
}
struct AttachId : Codable {
    var id:Int64
}
struct Publisher : Codable {
    var id:Int64
    var display:String
    var audio_codec:String?
    var video_codec:String?
    var talking:Bool?
}
public struct Participant : Codable {
    public var id:Int64
    public var display:String
    public var publisher:Bool
    public var talking:Bool
}
struct JsepData: Codable{
    var type:String
    var sdp:String
}
struct CandidateData: Codable{
    var sdpMid:String
    var lineIndex:Int32
    var candidate:String
}


struct JoinData : Codable {
   
    struct InData: Codable{
        var videoroom:String?
        var description:String?
        var id:Double?
        var room:Int64?
        var private_id:Int64?
        var publishers:[Publisher]?
        //for error parsing
        var error_code:Int64?
        var error:String?
    }
    struct PluginData: Codable{
        var plugin:String
        var data:InData
    }
    var codelabs:String
    var transaction:String?
    var plugindata:PluginData
    var session_id:Int64
    var sender :Int64
}
struct JoinOfferData : Codable {
    
    struct InData: Codable{
        var videoroom:String?
        var display:String?
        var id:Int64?
        var room:Int64?
        //for error parsing
        var error_code:Int64?
        var error:String?
    }
    struct PluginData: Codable{
        var plugin:String
        var data:InData
    }
    var codelabs:String
    var transaction:String
    var plugindata:PluginData
    var jsep:JsepData
    var session_id:Int64
    var sender :Int64
}

public struct JoinParticipantsData : Codable {
    
    public struct InData: Codable{
        public var videoroom:String?
        public var room:Int64?
        public var participants:[Participant]?
        //for error parsing
        var error_code:Int64?
        var error:String?
    }
    public struct PluginData: Codable{
        public var plugin:String
        public var data:InData
    }
    public  var codelabs:String
    public  var transaction:String
    public  var plugindata:PluginData
    public  var session_id:Int64
    public  var sender :Int64
}

struct AnswerReturnData : Codable {
    
    struct InData: Codable{
        var videoroom:String?
        var started:String?
        var room:Int64?
        //for error parsing
        var error_code:Int64?
        var error:String?
    }
    struct PluginData: Codable{
        var plugin:String
        var data:InData
    }
    var codelabs:String
    var transaction:String
    var plugindata:PluginData
    var session_id:Int64
    var sender :Int64
}
struct OfferReturnData : Codable {
    
    struct InData: Codable{
        var videoroom:String?
        var room:Int64?
        var configured:String?
        var audio_codec:String?
        var video_codec:String?
        //for error parsing
        var error_code:Int64?
        var error:String?

    }
    struct PluginData: Codable{
        var plugin:String
        var data:InData
    }
    struct JsepData: Codable{
        var type:String
        var sdp:String
    }
    var jsep:JsepData
    var transaction:String
    var plugindata:PluginData
    var session_id:Int64
    var sender :Int64
}

struct UnpublishData:Codable{
    struct InData: Codable{
        var videoroom:String?
        var room:Int64?
        var unpublished:Int64?
        //for error parsing
        var error_code:Int64?
        var error:String?
    }
    struct PluginData: Codable{
        var plugin:String
        var data:InData
    }
    var codelabs:String
    var plugindata:PluginData
    var session_id:Int64
    var sender :Int64
}
