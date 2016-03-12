//
//  TFVideoPlayerController.swift
//  YouTubeDraggableVideoSwift
//
//  Created by Tengfei on 16/3/12.
//  Copyright © 2016年 tengfei. All rights reserved.
//

import UIKit
import MediaPlayer

//typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
//    UIPanGestureRecognizerDirectionUndefined,
//    UIPanGestureRecognizerDirectionUp,
//    UIPanGestureRecognizerDirectionDown,
//    UIPanGestureRecognizerDirectionLeft,
//    UIPanGestureRecognizerDirectionRight
//};

public enum UIPanGestureRecognizerDirection : Int {
    case Undefined // No controls
    case Up // Controls for an embedded view
    case Fullscreen // Controls for fullscreen playback
    case Down // No controls
    case Left // Controls for an embedded view
    case Right // Controls for fullscreen playback
}

class TFVideoPlayerController: UIViewController,UIGestureRecognizerDelegate {
    @IBOutlet weak var btnDown: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewYouTube: UIView!
    @IBOutlet weak var viewTable: UIView!
    
    
    var player:MPMoviePlayerController!
    var onView:UIView!
    var initialFirstViewFrame:CGRect!
    var isExpandedMode:Bool = true
    
    //local restriction Offset--- for checking out of bound
//    float restrictOffset,restrictTrueOffset,restictYaxis;
    var restrictOffset:Float?
    var restrictTrueOffset:Float?
    var restictYaxis:Float?

    
    //local Frame store
    var youtubeFrame:CGRect!
    var tblFrame:CGRect!
    var menuFrame:CGRect!
    var viewFrame:CGRect!
    var minimizedYouTubeFrame:CGRect!
    var growingTextViewFrame:CGRect!
    
    var transaparentVw:UIView!
    
//    //detecting Pan gesture Direction
//    UIPanGestureRecognizerDirection direction;
    var direction:UIPanGestureRecognizerDirection!
 
    
    //local touch location
//    CGFloat _touchPositionInHeaderY;
//    CGFloat _touchPositionInHeaderX;
    var touchPositionInHeaderY:CGFloat!
    var touchPositionInHeaderX:CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        btnDown.hidden = true
        
        self.performSelector("addPlayerVideo", withObject: nil, afterDelay: 0.8)
        
        let pan = UIPanGestureRecognizer(target: self, action: "panAction:")
        pan.delegate = self
        viewYouTube.addGestureRecognizer(pan)
    }

    
    func addPlayerVideo(){
        let path = NSBundle .mainBundle().pathForResource("sample", ofType: "mp4")!
        let url = NSURL(fileURLWithPath: path)
        player = MPMoviePlayerController(contentURL: url)
        player.controlStyle = .None
        player.shouldAutoplay = true
        player.repeatMode = .None
        player.scalingMode = .AspectFit
        
        viewYouTube.addSubview(player.view)
        player .prepareToPlay()
        
        calculateFrames()
    }

    func calculateFrames(){
        youtubeFrame = viewYouTube.frame
        tblFrame = viewTable.frame
        UIApplication .sharedApplication().setStatusBarHidden(true, withAnimation: .Slide)
        
        viewYouTube.translatesAutoresizingMaskIntoConstraints = true
        viewTable.translatesAutoresizingMaskIntoConstraints = true
        
      
        restrictOffset = Float(initialFirstViewFrame.width) - 200.0
        restrictTrueOffset = Float(initialFirstViewFrame.height) - 180.0
        restictYaxis = Float(initialFirstViewFrame.height - viewYouTube.frame.height)

        view.hidden = true
        transaparentVw = UIView(frame: initialFirstViewFrame)
        transaparentVw.backgroundColor = UIColor.blackColor()
        transaparentVw.alpha = 0.9
        onView.addSubview(transaparentVw)
        
        onView.addSubview(viewTable)
        onView.addSubview(viewYouTube)
        
        stGrowingTextViewProperty()
        player.view.addSubview(btnDown)
        
        //animate Button Down
        btnDown.translatesAutoresizingMaskIntoConstraints = true
        btnDown.frame = CGRect(x: btnDown.frame.origin.x, y: btnDown.frame.origin.y-22, width: btnDown.frame.width, height: btnDown.frame.height)
        let frameBtnDown = btnDown.frame
        // animateWithDuration
        UIView.animateKeyframesWithDuration(2.0, delay: 2.0, options: .Autoreverse, animations: { () -> Void in
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: { () -> Void in
                self.btnDown.transform = CGAffineTransformMakeScale(1.5, 1.5)
                
                self.addShadow()
                
                self.btnDown.frame = CGRect(x: frameBtnDown.origin.x, y: frameBtnDown.origin.y+17, width: frameBtnDown.width, height: frameBtnDown.height)
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { () -> Void in
                self.btnDown.frame = CGRect(x: frameBtnDown.origin.x, y: frameBtnDown.origin.y, width: frameBtnDown.width, height: frameBtnDown.height)
                self.btnDown.transform = CGAffineTransformIdentity
                self.addShadow()
            })
            
            }, completion: nil)
        
        
    }
    
    
    func addShadow(){
        btnDown.imageView?.layer.shadowColor = UIColor.whiteColor().CGColor
        btnDown.imageView?.layer.shadowOffset = CGSize(width: 0, height: 1)
        btnDown.imageView?.layer.shadowOpacity = 1
        btnDown.imageView?.layer.shadowRadius = 4.0
        btnDown.imageView?.clipsToBounds = false
    }
    
    
    func stGrowingTextViewProperty(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIContentSizeCategoryDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)

    }
    
    func keyboardWasShown(aNotification:NSNotification){
    
    }
    
    func keyboardWillBeHidden(aNotification:NSNotification){
    
    }
    
    func removePlayerVC(){
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnDownTapAction(sender: UIButton) {
        player.stop()
        self.view .removeFromSuperview()
    }
    
    
    //pragma mark- Pan Gesture Delagate
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view?.frame.origin.y < 0{
            return false
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
         return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //#pragma mark- Pan Gesture Selector Action
    func panAction(recognizer:UIPanGestureRecognizer){
        
        let y = recognizer.locationInView(view).y
        
        if recognizer.state == UIGestureRecognizerState.Began{
            //
            direction = .Undefined
            
            let velocity:CGPoint = recognizer .velocityInView(recognizer.view)
            
            detectPanDirection(velocity)
            
            //Snag the Y position of the touch when panning begings
            touchPositionInHeaderX = recognizer.locationInView(viewYouTube).x
            touchPositionInHeaderY = recognizer.locationInView(viewYouTube).y
        
            if direction == .Down {
                player.controlStyle = .None
            }
        }else if (recognizer.state == .Changed){
            
            if (direction == .Down || direction == .Up){
                let trueOffset = y - touchPositionInHeaderY
                let xOffset = (y - touchPositionInHeaderY)*0.35
                
//                adjustview
            }
            
        }else if (recognizer.state == .Ended){
            
        }
        
        
    }

    
    func detectPanDirection(velocity:CGPoint){
        btnDown.hidden = true
        
        let isVerticalGesture:Bool = fabs(velocity.y) > fabs(velocity.x)
        
        if isVerticalGesture == true {
            if(velocity.y > 0){
                direction = .Down
            }else{
                direction = .Up
            }
        }else{
            if velocity.x > 0 {
                direction = .Right
            }else{
                direction = .Left
            }
            
        }
    }

    
}


extension TFVideoPlayerController :UITableViewDelegate,UITableViewDataSource{    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 8
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath)
        
        
        
        return cell
    }
}
