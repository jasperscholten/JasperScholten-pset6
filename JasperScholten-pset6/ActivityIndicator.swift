//
//  ActivityIndicator.swift
//  JasperScholten-pset6
//
//  Created by Jasper Scholten on 12-12-16.
//  Copyright © 2016 Jasper Scholten. All rights reserved.
//
//  This class defines the properties of the activity indicators used throughout the app. To use, first initialise an indicator with a constant (let spinner = customActivityIndicator(text: "Locaties ophalen")) and a statement in viewdidload (self.view.addSubview(self.spinner)). Subsequently, alter the behavior and appearance of this indicator thorugh the functions 'show' and 'hide'. Adapted from a post on Stackoverflow. [1]

import Foundation
import UIKit

class customActivityIndicator: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: .dark)
    let vibrancyView: UIVisualEffectView
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(activityIndicator)
        vibrancyView.contentView.addSubview(label)
        activityIndicator.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            
            let width: CGFloat = 200
            let height: CGFloat = 50.0
            self.frame = CGRect(x: superview.frame.size.width / 2 - width / 2,
                                y: superview.frame.height / 2 - height,
                                width: width, height: height)
            
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40
            activityIndicator.frame = CGRect(x: 5, y: height / 2 - activityIndicatorSize / 2,
                                             width: activityIndicatorSize,
                                             height: activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            
            label.text = text
            label.textAlignment = NSTextAlignment.center
            label.frame = CGRect(x: activityIndicatorSize + 5, y: 0, width: width - activityIndicatorSize - 20, height: height)
            label.textColor = UIColor.gray
            label.font = UIFont.boldSystemFont(ofSize: 16)
            
        }
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
}

// MARK: References

/*
 1. http://stackoverflow.com/questions/27960556/loading-an-overlay-when-running-long-tasks-in-ios
 */

