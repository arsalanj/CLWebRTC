 

import UIKit
 import CLWebRTC
//import SnapKit

class CollectionViewCell: UICollectionViewCell {
//    @IBOutlet weak var view: UIView!
    @IBOutlet weak var videoView: UIView!
    
//    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var label: UILabel!
    
    static var count = 0
    
    
    var previousScale:CGFloat = 1.0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //do some work here that needs to happen only once, you don’t wanna change them later.
        
        var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView))
        videoView.isUserInteractionEnabled = true
        videoView.addGestureRecognizer(pinchGesture)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
           tap.numberOfTapsRequired = 2
        videoView.addGestureRecognizer(tap)
        
//        
//        let panGesture = UIPanGestureRecognizer(target: self, action:#selector(self.handlePanGesture(gesture:)))
//           self.videoView.addGestureRecognizer(panGesture)
        
    }
    
    
    
    // Listener
    
    @objc func pinchedView(sender: UIPinchGestureRecognizer) {
        //        if sender.scale > 1 {
        //            print("Zoom out")
        //        } else{
        //            print("Zoom in")
        //        }
        //
        if sender.scale > 1 {
            
            DispatchQueue.main.async {
                
                
                let scale:CGFloat = self.previousScale * sender.scale
                self.videoView.transform = CGAffineTransform(scaleX: scale, y: scale);
                
                
                
                self.previousScale = sender.scale
                
            }
        }
        
        
        
    }
    
    @objc func doubleTapped() {
        // do something here
        let scale:CGFloat = 1.0
        
        
        DispatchQueue.main.async {
            self.videoView.transform = CGAffineTransform(scaleX: scale, y: scale);
            
        }
        
    }
    
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began || gesture.state == UIGestureRecognizer.State.changed{
            //print("UIPanGestureRecognizer")
            let translation = gesture.translation(in: videoView)
            gesture.view?.transform = (gesture.view?.transform)!.translatedBy(x: translation.x, y: translation.y)
            gesture.setTranslation(CGPoint(x: 0, y: 0), in: videoView)
        }
    }
    
    
    
}


