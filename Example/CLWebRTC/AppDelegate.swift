//
//  AppDelegate.swift
//  CodelabsWebRTC
//
//  Created by Mehdi on 02/03/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

            guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
                let url = userActivity.webpageURL, let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    return false
                }
        print("url \(url)")
        print("components.path \(components.path)")
        
        let queryItems = URLComponents(string: url.absoluteString)?.queryItems
        let param1 = queryItems?.filter({$0.name == "room"}).first
        print(param1?.value ?? "")
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FirstViewController") as? FirstViewController
        
        
        if (param1?.value != nil )
        
        {
            let decodedData = Data(base64Encoded: param1?.value ?? "")!
            let decodedString = String(data: decodedData, encoding: .utf8)!
            
            print(decodedString)
            
            let strArray = decodedString.components(separatedBy: "_")
            print("roomID \(String(describing: strArray.last))")
            print("roomName \(String(describing: strArray.first))")

            let roomID = strArray.last ?? ""
            let roomName = strArray.first ?? ""
            
            if (!roomID.isEmpty){
                
                
                
                vc?.roomID = roomID
                vc?.roomName = roomName
                
                
                
                
            }
            
            
        }
        let navigationController = UINavigationController(rootViewController: vc!)
        
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.rootViewController = navigationController
        }
        window?.makeKeyAndVisible()
        
        

            //FOR A URL "https://yourwebsite.com/testing/24
            //this will print the ID 24
            
//            if (components.path.contains("testing")) {
//                if let theid = Int(url.lastPathComponent) {
//                    print("test id from deep link \(theid)")
//                }
//            }
            
            
            return false
    }


}

