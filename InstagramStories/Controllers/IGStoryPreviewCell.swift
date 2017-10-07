//
//  IGStoryPreviewCell.swift
//  InstagramStories
//
//  Created by Srikanth Vellore on 06/09/17.
//  Copyright © 2017 Dash. All rights reserved.
//

import UIKit

protocol StoryPreviewProtocol:class {func didCompletePreview()}

class IGStoryPreviewCell: UICollectionViewCell {
    
    @IBOutlet weak private var headerView: UIView!
    @IBOutlet weak internal var scrollview: UIScrollView!{
        didSet{
            if let count = story?.snaps?.count {
                scrollview.contentSize = CGSize(width:scrollview.frame.size.width * CGFloat(count), height:scrollview.frame.size.height)
            }
        }
    }
    
    //MARK: - Overriden functions
    override func awakeFromNib() {
        super.awakeFromNib()
        storyHeaderView = IGStoryPreviewHeaderView.instanceFromNib()
        storyHeaderView?.frame = CGRect(x:0,y:0,width:frame.width,height:80)
        headerView.addSubview(storyHeaderView!)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let iv:UIImageView = self.scrollview.subviews.last as? UIImageView else{return}
        iv.sd_cancelCurrentImageLoad()
    }
    
    //MARK: - iVars
    public weak var delegate:StoryPreviewProtocol?
    //TODO: - Make UI Elements scope as private
    public var storyHeaderView:IGStoryPreviewHeaderView?
    public var snapIndex:Int = 0 {
        didSet {
            if snapIndex < story?.snapsCount ?? 0 {
                if let snap = story?.snaps?[snapIndex] {
                    if let picture = snap.url {
                        createImageView(with:picture)
                    }
                    storyHeaderView?.lastUpdatedLabel.text = snap.lastUpdated
                }
            }
        }
    }
    public var story:IGStory? {
        didSet {
            storyHeaderView?.story = story
            if let picture = story?.user?.picture {
                self.storyHeaderView?.snaperImageView.setImage(url: picture)
            }
        }
    }
    
    //MARK: - Private functions
    private func createImageView(with picture:String) {
        let iv = UIImageView(frame: CGRect(x:scrollview.subviews.last?.frame.maxX ?? CGFloat(0.0),
                                           y:0, width:scrollview.frame.size.width, height:scrollview.frame.size.height))
        startLoadContent(with: iv, picture: picture)
        scrollview.addSubview(iv)
    }
    
    //TODO:This expensive code should move to controller(ie.StoryPreviewController)
    //If Child wants an image it should not simply go and take
    //It should ask parent i want an image to represent the UIImageView!!!
    private func startLoadContent(with imageView:UIImageView,picture:String) {
        imageView.setImage(url: picture, style: .squared, completion: { (result, error) in
            debugPrint("Loading content")
            if let error = error {
                debugPrint(error.localizedDescription)
            }else {
                let pv = self.storyHeaderView?.progressView(with: self.snapIndex)
                pv?.delegate = self
                pv?.willBeginProgress()
            }
        })
    }
}

extension IGStoryPreviewCell:SnapProgresser {
    func didCompleteProgress() {
        let n = snapIndex + 1
        if let count = story?.snapsCount {
            if n < count {
                //Move to next snap
                let x = n.toFloat() * frame.width
                let offset = CGPoint(x:x,y:0)
                scrollview.setContentOffset(offset, animated: false)
                snapIndex = n
            }else {
                delegate?.didCompletePreview()
            }
        }
    }
}
