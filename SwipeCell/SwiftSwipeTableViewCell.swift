//
//  SwiftSwipeTableViewCell.swift
//  SwipeCell
//
//  Created by Jian on 6/22/18.
//  Copyright © 2018 Jian. All rights reserved.
//

import UIKit



extension Notification.Name {
    static let swipeCellSlide = Notification.Name("swiftSwipeCellSlide")
}



@objc protocol SwipeCell: AnyObject {
    func cellButtonTouched(_ sender: UIButton, atIndexPath indexPath: IndexPath)
}



class SwiftSwipeTableViewCell: UITableViewCell {

    weak var delegate: SwipeCell?

    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    
    private var arrOptions = [UIButton]()
    private var indexPath: IndexPath?
    private var panGesture  = UIPanGestureRecognizer()
    
    override var textLabel: UILabel? {
        get {
            return lblTitle
        }
    }
    
    override var detailTextLabel: UILabel? {
        get {
            return lblDetail
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // gesture
        let panGesture  = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        
        // notification
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotification(_:)), name: .swipeCellSlide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.showOptions(false, false)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let cell = panGesture.view
            let translation = panGesture.translation(in: cell?.superview)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
        }
        
        return false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected == true {
            NotificationCenter.default.post(name: .swipeCellSlide, object: nil, userInfo: nil)
        }
    }
    
    func receiveNotification(_ notification: Notification) {
        let hashValue = notification.userInfo?["cell"] as? Int
        
        if hashValue != self.hashValue {
            self.showOptions(false, true)
        }
    }
    
    func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            let userInfo = ["cell": self.hashValue]
            NotificationCenter.default.post(name: .swipeCellSlide, object: nil, userInfo: userInfo)
        case .changed:
            let translation = panGesture.translation(in: self)
            panGesture.setTranslation(.zero, in: self)
            self.translateViewBy(x: slideView.center.x + translation.x)
        case .ended:
            let show = (slideView.center.x <= (self.center.x * 0.5));
            self.showOptions(show, true)
        default:
            print("")
        }
    }

    private func translateViewBy(x xOffSet: CGFloat) {
        
        let minSlide = -self.frame.width * 0.1
        let maxSlide =  self.frame.width * 0.5

        guard xOffSet >= minSlide, xOffSet <= maxSlide else {
            return
        }
        
        slideView.center.x = xOffSet
        
        guard arrOptions.count > 0 else {
            return
        }
        
        var xMin   = slideView.frame.maxX
        let width  = (self.frame.width - xMin) / CGFloat(arrOptions.count)
        let height = self.frame.height
        
        for button in arrOptions {
            button.frame = CGRect(x: xMin, y: 0, width: width, height: height)
            xMin = button.frame.maxX
        }
    }
    
    func showOptions(_ show: Bool, _ animated: Bool) {
        let x = show ? 0.0 : self.frame.size.width * 0.5
        
        guard slideView.center.x != x else {
            return
        }
        
        if animated == true {
            let damping: CGFloat  = show ? 0.5 : 1.0
            let velocity: CGFloat = show ? 0.5 : 1.0
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: damping,
                           initialSpringVelocity: velocity,
                           options: .curveEaseOut,
                           animations: {
                            self.translateViewBy(x: x)
            },
                           completion: nil)
        } else {
            self.translateViewBy(x: x)
        }
    }
    
    func addOptions(_ options: [String], atIndexPath indexPath: IndexPath)  {
        self.indexPath = indexPath
        
        let colors = [UIColor.red, UIColor.blue, UIColor.gray]
        
        for i in 0 ..< options.count {
            let title = options[i]
            let frame = CGRect(x: self.frame.width, y: 0, width: 0, height: self.frame.height);
            let button = UIButton.init(frame: frame)
            button.tag = i
            button.titleLabel?.lineBreakMode = .byClipping
            button.backgroundColor = colors[i % colors.count]
            
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
            
            self.contentView.addSubview(button)
            arrOptions.append(button)
        }
    }
    
    func buttonTouched(_ sender: UIButton) {
        // TODO: check if delegate method responds
        
        guard delegate != nil else {
            return
        }
        
        if let indexPath = self.indexPath {
            delegate?.cellButtonTouched(sender, atIndexPath: indexPath)
            self.showOptions(false, true)
        }
    }
}







