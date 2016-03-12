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
    var youtubeFrame:CGRect = CGRectZero
    var tblFrame:CGRect = CGRectZero
    var menuFrame:CGRect = CGRectZero
    var viewFrame:CGRect = CGRectZero
    var minimizedYouTubeFrame:CGRect = CGRectZero
    var growingTextViewFrame:CGRect = CGRectZero
    
    var transaparentVw:UIView!
    
//    //detecting Pan gesture Direction
//    UIPanGestureRecognizerDirection direction;
    var direction:UIPanGestureRecognizerDirection!
    
    var tapRecognizer:UITapGestureRecognizer?
 
    
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
        self.player.stop()
        viewYouTube.removeFromSuperview()
        viewTable.removeFromSuperview()
        transaparentVw.removeFromSuperview()
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
                
               adjustViewOnVerticalPan(trueOffset, xOffset: xOffset, recognizer: recognizer)
            }else if(direction == .Right || direction == .Left){
                
                 adjustViewOnHorizontalPan(recognizer)
            }
            
        }else if (recognizer.state == .Ended){
            
            
            if (direction == .Down || direction == .Up ){
                
                if recognizer.view?.frame.origin.y < 0 {
                    expandViewOnPa()
                    
                    recognizer.setTranslation(CGPointZero, inView: recognizer.view)
                    
                    return
                }else if ( recognizer.view?.frame.origin.y  > (self.initialFirstViewFrame.size.width/2)){
                    minimizeViewOnPan()
                    
                    recognizer.setTranslation(CGPointZero, inView: recognizer.view)
                    
                    return
                }else if ( recognizer.view?.frame.origin.y < (self.initialFirstViewFrame.size.width/2)){
                    expandViewOnPa()
                    
                    recognizer.setTranslation(CGPointZero, inView: recognizer.view)
                    return
                }
            }else if (direction == .Left){
                
                if (viewTable.alpha <= 0){
                    if recognizer.view?.frame.origin.x < 0 {
                        self.view.removeFromSuperview()
                        removePlayerVC()
                        //MARK : //Delegate
                    }else {
                    
                        animateViewToRight(recognizer)
                    }
                }
            }else if (direction == .Right){
                
                if self.viewTable.alpha <= 0 {
                
                    if recognizer.view?.frame.origin.x > initialFirstViewFrame.size.width - 50{
                    
                        self.view.removeFromSuperview()
                        removePlayerVC()
                        //MARK : //Delegate
                    }else {
                    
                        animateViewToLeft(recognizer)
                    }
                }
            }
            
        }
        
        
    }
    func animateViewToLeft(recognizer:UIPanGestureRecognizer){
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.viewTable.frame = self.menuFrame;
            self.viewYouTube.frame = self.viewFrame;
            self.player.view.frame=CGRectMake( self.player.view.frame.origin.x,  self.player.view.frame.origin.x, self.viewFrame.size.width, self.viewFrame.size.height);
            self.viewTable.alpha = 0;
            self.viewYouTube.alpha = 1;
            }) { (_) -> Void in
                
        }
        recognizer.setTranslation(CGPointZero, inView: recognizer.view)
    }
    func animateViewToRight(recognizer:UIPanGestureRecognizer){
        
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.viewTable.frame = self.menuFrame
            self.viewYouTube.frame = self.viewFrame
            self.player.view.frame=CGRectMake( self.player.view.frame.origin.x,  self.player.view.frame.origin.x, self.viewFrame.size.width, self.viewFrame.size.height);
            self.viewTable.alpha=0;
            self.viewYouTube.alpha=1;
            }) { (_) -> Void in
                
        }
        recognizer.setTranslation(CGPointZero, inView: recognizer.view)
    }
    
    func minimizeViewOnPan(){
        btnDown.hidden = true
        let trueOffset = initialFirstViewFrame.height - 100
        let xOffset = initialFirstViewFrame.width - 160
        
        //Use this offset to adjust the position of your view accordingly
        menuFrame.origin.y = trueOffset;
        menuFrame.origin.x = xOffset;
        menuFrame.size.width=self.initialFirstViewFrame.size.width-xOffset;
        //menuFrame.size.height=200-xOffset*0.5;
        
        // viewFrame.origin.y = trueOffset;
        //viewFrame.origin.x = xOffset;
        viewFrame.size.width=self.view.bounds.size.width-xOffset;
        viewFrame.size.height=200-xOffset*0.5;
        viewFrame.origin.y=trueOffset;
        viewFrame.origin.x=xOffset;
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.viewTable.frame = self.menuFrame;
            self.viewYouTube.frame = self.viewFrame;
            self.player.view.frame=CGRectMake( self.player.view.frame.origin.x,  self.player.view.frame.origin.x, self.viewFrame.size.width, self.viewFrame.size.height);
            self.viewTable.alpha=0;
            self.transaparentVw.alpha=0.0;
            
            }) { (_) -> Void in
                //add tap gesture
                self.tapRecognizer = nil;
                if(self.tapRecognizer == nil)  {
                    self.tapRecognizer = UITapGestureRecognizer(target: self, action: "expandViewOnTap:")
                    
                    self.tapRecognizer!.numberOfTapsRequired = 1;
                    self.tapRecognizer!.delegate = self;
                    self.viewYouTube.addGestureRecognizer(self.tapRecognizer!)
                }
                
                self.isExpandedMode = false;
                self.minimizedYouTubeFrame = self.viewYouTube.frame;
                
                if (self.direction == .Down) {
                    self.onView.bringSubviewToFront(self.view)
                }

        }
    }
    
    func expandViewOnTap(sender:UITapGestureRecognizer){
        expandViewOnPa()
        
        for recognizer:UIGestureRecognizer in self.viewYouTube.gestureRecognizers! {
            if recognizer.isKindOfClass(UITapGestureRecognizer.self){
                self.viewYouTube.removeGestureRecognizer(recognizer)
            }
        }
    }
    
    func expandViewOnPa(){
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.viewTable.frame = self.tblFrame
            self.viewYouTube.frame = self.youtubeFrame
            self.viewYouTube.alpha = 1
            self.player.view.frame = self.youtubeFrame
            self.viewTable.alpha = 1.0
            self.transaparentVw.alpha = 1.0
            }) { (_) -> Void in
                self.player.controlStyle = .Default
                self.isExpandedMode = true
                self.btnDown.hidden = false
        }
    }
    
    func adjustViewOnVerticalPan(var trueOffset:CGFloat,var xOffset:CGFloat,recognizer:UIPanGestureRecognizer){
        
        let y:CGFloat = recognizer.locationInView(view).y
        
        if( trueOffset  >= CGFloat(restrictTrueOffset! + 60) || xOffset >= CGFloat(restrictOffset! + 60) ){
            
            trueOffset = initialFirstViewFrame.height - 100
            xOffset = initialFirstViewFrame.width - 160
        
            //Use this offset to adjust the position of your view accordingly
            menuFrame.origin.y = trueOffset;
            menuFrame.origin.x = xOffset;
            menuFrame.size.width=self.initialFirstViewFrame.size.width-xOffset;
            
            viewFrame.size.width=self.view.bounds.size.width-xOffset;
            viewFrame.size.height=200-xOffset*0.5;
            viewFrame.origin.y=trueOffset;
            viewFrame.origin.x=xOffset;
            
            
            UIView.animateWithDuration(0.05, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                self.viewTable.frame = self.menuFrame
                self.viewYouTube.frame = self.viewFrame
                self.player.view.frame = CGRect(x: self.player.view.frame.origin.x, y: self.player.view.frame.origin.y, width: self.viewFrame.size.width, height: self.viewFrame.size.height)
                self.viewTable.alpha = 0
                
                }, completion: { (_) -> Void in
                    self.minimizedYouTubeFrame = self.viewYouTube.frame
                    self.isExpandedMode = false
            })
            recognizer .setTranslation(CGPointZero, inView: view)
        
        }else{
            //Use this offset to adjust the position of your view accordingly
            menuFrame.origin.y = trueOffset;
            menuFrame.origin.x = xOffset;
            menuFrame.size.width=self.initialFirstViewFrame.size.width-xOffset;
            viewFrame.size.width=self.view.bounds.size.width-xOffset;
            viewFrame.size.height=200-xOffset*0.5;
            viewFrame.origin.y=trueOffset;
            viewFrame.origin.x=xOffset;
            let restrictY = self.initialFirstViewFrame.size.height-self.viewYouTube.frame.size.height-10;
            
            if viewTable.frame.origin.y < restrictY && viewTable.frame.origin.y > 0{
                
                UIView.animateWithDuration(0.09, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.viewTable.frame = self.menuFrame
                    self.viewYouTube.frame = self.viewFrame
                    self.player.view.frame = CGRectMake( self.player.view.frame.origin.x,  self.player.view.frame.origin.x, self.viewFrame.size.width, self.viewFrame.size.height);
                    let percentage = y/self.initialFirstViewFrame.size.height;
                    self.viewTable.alpha =  1.0 - percentage;
                    self.transaparentVw.alpha =  1.0 - percentage
                    
                    }, completion: { (_) -> Void in
                        if self.direction == .Down {
                            self.onView.bringSubviewToFront(self.view)
                        }
                })
            } else if (menuFrame.origin.y<restrictY && menuFrame.origin.y>0) {
            
                UIView.animateWithDuration(0.09, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.viewTable.frame = self.menuFrame;
                    self.viewYouTube.frame = self.viewFrame;
                    self.player.view.frame=CGRectMake(self.player.view.frame.origin.x,  self.player.view.frame.origin.x, self.viewFrame.size.width, self.viewFrame.size.height);
                    }, completion: nil)
                
            }
            recognizer.setTranslation(CGPointZero, inView: recognizer.view)
        }
        
        
    }

    func adjustViewOnHorizontalPan(recognizer:UIPanGestureRecognizer){
        let x = recognizer.locationInView(view).x
        if (direction == .Left){
            if viewTable.alpha <= 0{
                let velocity:CGPoint = recognizer .velocityInView(recognizer.view)
                let isVerticalGesture = fabs(velocity.y) > fabs(velocity.x)
                
                let translation = recognizer .translationInView(recognizer.view)
                recognizer.view?.center = CGPoint(x: ((recognizer.view?.center.x)! + translation.x), y: recognizer.view!.center.y)
                
                if (!isVerticalGesture){
                    let percentage:CGFloat = x / initialFirstViewFrame.width
                    recognizer.view?.alpha = percentage
                }
                
                recognizer .setTranslation(CGPointZero, inView: recognizer.view)
            }
        }else if(direction == .Right){
            
            if(viewTable.alpha <= 0){
                let velocity:CGPoint = recognizer.velocityInView(recognizer.view)
                let isVerticalGesture = fabs(velocity.y) > fabs(velocity.x)
                
                let translation = recognizer .translationInView(recognizer.view)
                recognizer.view?.center = CGPoint(x: ((recognizer.view?.center.x)! + translation.x), y: recognizer.view!.center.y)
                
                if (!isVerticalGesture){
                    if(velocity.x > 0){
                        let percentage:CGFloat = x / initialFirstViewFrame.width
//                        recognizer.view?.alpha = 1 - percentage
                    }else {
                        let percentage:CGFloat = x / initialFirstViewFrame.width
                        recognizer.view?.alpha = percentage
                    }
                }
                
                recognizer .setTranslation(CGPointZero, inView: recognizer.view)

            }
        
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
