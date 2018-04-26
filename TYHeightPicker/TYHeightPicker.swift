//
//  TYHeightPicker.swift
//  TYHeightPicker
//
//  Created by Yash Thaker on 26/04/18.
//  Copyright © 2018 Yash Thaker. All rights reserved.
//

import UIKit

protocol TYHeightPickerDelegate {
    func chooseHeight(height: CGFloat, unit: HeightUnit)
}

enum HeightUnit: String {
    
    case CM = "CM"
    case Feet = "Feet"
}

class TYHeightPicker: UIView {
    
    let themeBlue = UIColor(red: 0, green: 118/255, blue: 1, alpha: 1)
    let themeYellow = UIColor(red: 1, green: 186/255, blue: 1/255, alpha: 1)
    
    let separatorLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 225/255, green: 225/255, blue: 222/255, alpha: 0.4)
        return view
    }()
    
    var cmBtn: UIButton!
    var feetBtn: UIButton!
    
    lazy var indicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = themeYellow
        view.layer.cornerRadius = 1.5
        return view
    }()
    
    var indicatorViewCenterX: NSLayoutConstraint?
    
    let pointerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    var mainScrollView: UIScrollView!
    
    let lineWidth: CGFloat = 1
    let lineHeight: CGFloat = 18
    let middleLineHeight: CGFloat = 37
    let gap: CGFloat = 10
    var contentSize: CGFloat = 0
    
    var offSet: UIEdgeInsets!
    
    var selectedIndex: Int = 1
    
    var maxDigit: Int = 301
    
    var delegate: TYHeightPickerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cmBtn = createButton(title: "Centimeter", tag: 1)
        feetBtn = createButton(title: "Feet/inch", tag: 2)
        
        addViews()
        addContrains()
    }
    
    private func addViews () {
        addSubview(separatorLineView)
        addSubview(cmBtn)
        addSubview(feetBtn)
        addSubview(indicatorView)
        addSubview(pointerView)
    }
    
    private func addContrains () {
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        cmBtn.topAnchor.constraint(equalTo: separatorLineView.bottomAnchor).isActive = true
        cmBtn.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        cmBtn.rightAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cmBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        feetBtn.topAnchor.constraint(equalTo: separatorLineView.bottomAnchor).isActive = true
        feetBtn.leftAnchor.constraint(equalTo: centerXAnchor).isActive = true
        feetBtn.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        feetBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        indicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        indicatorViewCenterX = indicatorView.centerXAnchor.constraint(equalTo: cmBtn.centerXAnchor)
        indicatorViewCenterX?.isActive = true
        indicatorView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        indicatorView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        
        pointerView.topAnchor.constraint(equalTo: topAnchor, constant: 50).isActive = true
        pointerView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: lineWidth/2).isActive = true
        pointerView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        pointerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        pointerView.transform = CGAffineTransform(rotationAngle: .pi/4)
    }
    
    @objc func btnTapped(sender: UIButton) {
        selectedIndex = sender.tag
        
        maxDigit = selectedIndex == 1 ? 301 : 121
        
        let xPos = self.feetBtn.frame.origin.x
        indicatorViewCenterX?.constant = selectedIndex ==  2 ? xPos : 0
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = true
        
        setupMainScrollView()
        self.bringSubview(toFront: pointerView)
    }
    
    private func setupMainScrollView() {
        
        offSet = UIEdgeInsets(top: 0, left: self.frame.width / 2, bottom: 0, right: 0)
        
        mainScrollView = UIScrollView(frame: CGRect(x: 0, y: 60, width: self.frame.width, height: 75))
        mainScrollView.backgroundColor = themeBlue
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.delegate = self
        mainScrollView.contentInset = offSet
        for i in 0 ..< maxDigit {
            
            let XPOS: CGFloat = gap * CGFloat(i)
            
            let view = UIView()
            view.backgroundColor = .white
            view.frame = CGRect(x: XPOS, y: 0, width: lineWidth, height: lineHeight)
            mainScrollView.addSubview(view)
            
            let label = UILabel()
            label.textColor = .white
            label.textAlignment = .center
            
            if maxDigit == 301 {
                
                if i % 5 == 0 {
                    view.frame = CGRect(x: XPOS, y: 0, width: lineWidth, height: 33)
                }
                
                if i % 10 == 0 {
                    
                    view.frame = CGRect(x: XPOS, y: 0, width: lineWidth, height: middleLineHeight)
                    label.frame = CGRect(x: 0, y: middleLineHeight + 5, width: 50, height: 30)
                    label.center.x = view.center.x
                    label.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                    
                    let number = selectedIndex == 1 ? i : Int(i/10)
                    
                    label.text = "\(number)"
                    mainScrollView.addSubview(label)
                }
            }
            
            if maxDigit == 121 {
                
                if i % 6 == 0 {
                    view.frame = CGRect(x: XPOS, y: 0, width: lineWidth, height: 33)
                }
                
                if i % 12 == 0 {
                    
                    view.frame = CGRect(x: XPOS, y: 0, width: lineWidth, height: middleLineHeight)
                    label.frame = CGRect(x: 0, y: middleLineHeight + 5, width: 50, height: 30)
                    label.center.x = view.center.x
                    label.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                    
                    let number = Int(i/12)
                    
                    label.text = "\(number)"
                    mainScrollView.addSubview(label)
                }
            }
            
            contentSize = XPOS
        }
        
        mainScrollView.contentSize = CGSize(width: contentSize + offSet.left, height: mainScrollView.frame.height)
        self.addSubview(mainScrollView)
    }
    
    private func createButton(title: String, tag: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle(title, for: .normal)
        btn.addTarget(self, action: #selector(btnTapped(sender:)), for: .touchUpInside)
        btn.tag = tag
        return btn
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TYHeightPicker: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let targetOffset = targetContentOffset.pointee
        var pos = targetOffset.x  + offSet.left
        
        pos = round(pos/10)
        pos = pos * 10
        pos = pos - offSet.left
        
        targetContentOffset.pointee = CGPoint(x: pos, y: 0.0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        let xPos = (scrollView.contentOffset.x + offSet.left)
        
        // cm
        if selectedIndex == 1 {
            let cm = xPos/10
            let roundedCM = round(cm)
            
            if roundedCM > 0 {
                self.delegate?.chooseHeight(height: roundedCM, unit: .CM)
            } else {
                self.delegate?.chooseHeight(height: 0, unit: .CM)
            }
        }
        
        // feet
        if selectedIndex == 2 {
            let feet = xPos/10
            let roundedFeet = round(feet)
            
            if roundedFeet > 0 {
                self.delegate?.chooseHeight(height: roundedFeet, unit: .Feet)
            } else {
                self.delegate?.chooseHeight(height: 0, unit: .Feet)
            }
        }
    
    }
}
