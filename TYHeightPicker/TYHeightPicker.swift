//
//  TYHeightPicker.swift
//  TYHeightPicker
//
//  Created by Yash Thaker on 26/04/18.
//  Copyright © 2018 Yash Thaker. All rights reserved.
//

import UIKit

protocol TYHeightPickerDelegate {
    func selectedHeight(height: CGFloat, unit: HeightUnit)
}

enum HeightUnit: String {
    case CM = "CM"
    case Inch = "Inch"
}

class TYHeightPicker: UIView {
    
    var delegate: TYHeightPickerDelegate?
    
    private var separatorLineView, indicatorView, pointerView: UIView!
    private var cmBtn, feetInchBtn: UIButton!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 1, height: 75)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = #colorLiteral(red: 0, green: 0.5558522344, blue: 1, alpha: 1)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private var layout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    private var cellWidthIncludingSpacing: CGFloat {
        return layout.itemSize.width + layout.minimumLineSpacing
    }
    
    private let cellId = "cellId"
    
    private let resultLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 11)
        lbl.textAlignment = .center
        lbl.backgroundColor = .clear
        lbl.text = "0 CM"
        return lbl
    }()
    
    private var selectedIndex: Int = 0
    
    private var selectedCM: CGFloat = 0 {
        didSet {
            self.resultLabel.text = "\(Int(selectedCM)) CM"
        }
    }
    
    private var selectedInch: CGFloat = 0 {
        didSet {
            let feet = Int(selectedInch / 12)
            let inch = Int(selectedInch) % 12
            let resultString = inch != 0 ? "\(feet) Feet \(inch) Inch" : "\(feet) Feet"
            self.resultLabel.text = resultString
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        separatorLineView = createView(#colorLiteral(red: 0.8823529412, green: 0.8823529412, blue: 0.8705882353, alpha: 0.4))
        cmBtn = createButton("Centimeter", tag: 0)
        feetInchBtn = createButton("Feet/inch", tag: 1)
        indicatorView = createView(#colorLiteral(red: 0, green: 0.5558522344, blue: 1, alpha: 1))
        indicatorView.layer.cornerRadius = 1.5
        pointerView = createView(.white)
        pointerView.translatesAutoresizingMaskIntoConstraints = false
        pointerView.transform = CGAffineTransform(rotationAngle: .pi/4)
        
        addSubview(separatorLineView)
        addSubview(cmBtn)
        addSubview(feetInchBtn)
        addSubview(indicatorView)
        addSubview(collectionView)
        addSubview(pointerView)
        addSubview(resultLabel)
        
        collectionView.register(TYLineCell.self, forCellWithReuseIdentifier: cellId)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapped)))
    }
    
    @objc func btnTapped(sender: UIButton) {
        if selectedIndex == sender.tag { return }
        selectedIndex = sender.tag
        
        animateIndicatorView(selectedIndex)
        
        collectionView.reloadData()
        
        changeUnit()
    }
    
    private func changeUnit() {
        if selectedIndex == 0 {
            let cm = selectedInch / 0.39370 // inch to cm convert
            selectedCM = round(cm) < 300 ? round(cm) : 300
            delegate?.selectedHeight(height: selectedCM, unit: .CM)
            
            let offset = CGPoint(x: selectedCM * cellWidthIncludingSpacing - collectionView.contentInset.left, y: -collectionView.contentInset.top)
            collectionView.setContentOffset(offset, animated: true)
        }
        
        if selectedIndex == 1 {
            let inch = selectedCM * 0.39370 // cm to inch convert
            selectedInch = round(inch)
            delegate?.selectedHeight(height: selectedInch, unit: .Inch)
            
            let offset = CGPoint(x: selectedInch * cellWidthIncludingSpacing - collectionView.contentInset.left, y: -collectionView.contentInset.top)
            collectionView.setContentOffset(offset, animated: true)
        }
    }
    
    func setDefaultHeight(_ height: CGFloat, unit: HeightUnit) {
        selectedIndex = unit == .CM ? 0 : 1
        collectionView.reloadData()
        collectionView.layoutSubviews()
        animateIndicatorView(selectedIndex)
        
        if selectedIndex == 0 {
            selectedCM = height
            delegate?.selectedHeight(height: selectedCM, unit: .CM)
            let offset = CGPoint(x: selectedCM * cellWidthIncludingSpacing - collectionView.contentInset.left, y: -collectionView.contentInset.top)
            collectionView.setContentOffset(offset, animated: true)
            
        } else {
            selectedInch = height
            delegate?.selectedHeight(height: selectedInch, unit: .Inch)
            let offset = CGPoint(x: selectedInch * cellWidthIncludingSpacing - collectionView.contentInset.left, y: -collectionView.contentInset.top)
            collectionView.setContentOffset(offset, animated: true)
        }
    }
    
    private func animateIndicatorView(_ index: Int) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.indicatorView.center.x = index == 0 ? self.cmBtn.center.x : self.feetInchBtn.center.x
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = true
        
        separatorLineView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 5)
        cmBtn.frame = CGRect(x: 0, y: 5, width: (bounds.width/2) - 30, height: 45)
        feetInchBtn.frame = CGRect(x: (bounds.width/2) + 30, y: 5, width: (bounds.width/2) - 30, height: 45)
        indicatorView.frame = CGRect(x: 0, y: 40, width: 70, height: 3)
        indicatorView.center.x = selectedIndex == 0 ? cmBtn.center.x : feetInchBtn.center.x
        collectionView.frame = CGRect(x: 0, y: 60, width: bounds.width, height: 75)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: bounds.width / 2, bottom: 0, right: bounds.width / 2)
        
        pointerView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0.5).isActive = true
        pointerView.topAnchor.constraint(equalTo: topAnchor, constant: 50).isActive = true
        pointerView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        pointerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        resultLabel.centerXAnchor.constraint(equalTo: pointerView.centerXAnchor).isActive = true
        resultLabel.topAnchor.constraint(equalTo: pointerView.topAnchor, constant: -8).isActive = true
    }
    
    private func createButton(_ title: String, tag: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle(title, for: .normal)
        btn.addTarget(self, action: #selector(btnTapped(sender:)), for: .touchUpInside)
        btn.tag = tag
        return btn
    }
    
    private func createView(_ bgColor: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = bgColor
        return view
    }
    
    /// this is for nothing, just prevent to close view
    @objc private func handleTapped () { }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension TYHeightPicker: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedIndex == 0 ? 301 : 121
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
            as! TYLineCell
        let heightUnit: HeightUnit = selectedIndex == 0 ? .CM : .Inch
        cell.calcLineViewHeight(indexPath.row, heightUnit: heightUnit)
        return cell
    }
}

extension TYHeightPicker: UIScrollViewDelegate {
    
    // this is for exactly stop on line
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        if selectedIndex == 0 {
            selectedCM = roundedIndex <= 0 ? 0 : roundedIndex
            
        } else {
            selectedInch = roundedIndex <= 0 ? 0 : roundedIndex
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let unit = selectedIndex == 0 ? HeightUnit.CM : .Inch
        let height = selectedIndex == 0 ? selectedCM : selectedInch
        delegate?.selectedHeight(height: height, unit: unit)
    }
    
}

class TYLineCell: UICollectionViewCell {
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    var numberLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 15)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
        
        addSubview(lineView)
        addSubview(numberLabel)
    }
    
    func calcLineViewHeight(_ index: Int, heightUnit: HeightUnit) {
        var firstModulo: Int = 0
        var secondModulo: Int = 0
        
        if heightUnit == .CM {
            firstModulo = 10
            secondModulo = 5
            
        } else if heightUnit == .Inch {
            firstModulo = 12
            secondModulo = 6
        }
        
        if index % firstModulo == 0 {
            lineView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 37)
            numberLabel.frame = CGRect(x: 0, y: 37 + 5, width: 50, height: 30)
            numberLabel.center.x = lineView.center.x
            let num = firstModulo == 12 ? index/12 : index
            numberLabel.text = "\(num)"
            
        } else if index % secondModulo == 0 {
            lineView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 28)
            numberLabel.frame = .zero
            numberLabel.text = ""
            
        } else {
            lineView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 18)
            numberLabel.frame = .zero
            numberLabel.text = ""
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

