//
//  HomeViewController.swift
//  YouTubeDraggableVideoSwift
//
//  Created by Tengfei on 16/3/12.
//  Copyright © 2016年 tengfei. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {
    
    var videoPlayerVC:TFVideoPlayerController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.rowHeight = 100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 8
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if videoPlayerVC == nil {
            showPlayerVc()
        }else{
            videoPlayerVC!.removePlayerVC()
            videoPlayerVC?.view .removeFromSuperview()
            videoPlayerVC = nil
            
            showPlayerVc()
        }
    }
    
    
    func showPlayerVc(){
        videoPlayerVC = (storyboard!.instantiateViewControllerWithIdentifier("playerVC") as! TFVideoPlayerController)
        videoPlayerVC?.view.frame = CGRect(x: view.frame.width-50, y: view.frame.height-50, width: view.frame.width, height: view.frame.height)
        videoPlayerVC!.initialFirstViewFrame = view.frame
        
        videoPlayerVC?.view.alpha = 0
        videoPlayerVC?.view.transform = CGAffineTransformMakeScale(0.2, 0.2)
        
        view.addSubview((videoPlayerVC?.view)!)
        videoPlayerVC?.onView = view
        
        UIView.animateWithDuration(0.9) { () -> Void in
            self.videoPlayerVC?.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            self.videoPlayerVC?.view.alpha = 1
            self.videoPlayerVC?.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        }
    }
 
}
