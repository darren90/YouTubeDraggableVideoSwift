//
//  TFVideoPlayerController.swift
//  YouTubeDraggableVideoSwift
//
//  Created by Tengfei on 16/3/12.
//  Copyright © 2016年 tengfei. All rights reserved.
//

import UIKit
import MediaPlayer

class TFVideoPlayerController: UIViewController,UIGestureRecognizerDelegate {
    @IBOutlet weak var btnDown: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewYouTube: UIView!
    @IBOutlet weak var viewTable: UIView!
    
    
    var player:MPMoviePlayerController!
    var onView:UIView!
    var initialFirstViewFrame:CGRect!
    var isExpandedMode:Bool = true
    
    //local Frame store
    var youtubeFrame:CGRect!
    var tblFrame:CGRect!
    var menuFrame:CGRect!
    var viewFrame:CGRect!
    var minimizedYouTubeFrame:CGRect!
    var growingTextViewFrame:CGRect!
 

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        
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
        print("pan-----pan")
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
