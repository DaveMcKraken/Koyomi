//
//  KoyomiCell.swift
//  Pods
//
//  Created by Shohei Yokoyama on 2016/10/09.
//
//

import UIKit

final class KoyomiCell: UICollectionViewCell {
    
    // Fileprivate properties
    fileprivate let contentLabel: UILabel = .init()
    fileprivate let circularView: UIView  = .init()
    fileprivate let lineView: UIView      = .init()
    
    fileprivate let leftSemicircleView: UIView  = .init()
    fileprivate let rightSemicircleView: UIView = .init()
    
    fileprivate let leftConnectorView: UIView = .init()
    fileprivate let rightConnectorView: UIView = .init()
    
    static let identifier = "KoyomiCell"
    
    enum CellStyle {
        case standard, circle, semicircleEdge(position: SequencePosition), line(position: SequencePosition?), connectedCircle(position: SequencePosition)
        
        enum SequencePosition { case left, middle, right, single }
    }
    
    // Internal properties
    var content = "" {
        didSet {
            contentLabel.text = content
            adjustSubViewsFrame()
        }
    }
    var textColor: UIColor = UIColor.KoyomiColor.black {
        didSet {
            contentLabel.textColor = textColor
        }
    }
    var dayBackgroundColor: UIColor = .white {
        didSet {
            backgroundColor = dayBackgroundColor
        }
    }
    var contentPosition: ContentPosition = .center
    
    var lineViewAppearance: Koyomi.LineView? {
        didSet {
            configureLineView()
        }
    }
    var circularViewDiameter: CGFloat = 0.75 {
        didSet {
            configureCircularView()
            configureConnectorViews()
        }
    }
    
    // MARK: - Initializer -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustSubViewsFrame()
    }
    
    // MARK: - Internal Methods -
    
    func setContentFont(fontName name: String, size: CGFloat) {
        contentLabel.font = UIFont(name: name, size: size)
        adjustSubViewsFrame()
    }
    
    func configureAppearance(of style: CellStyle, withColor color: UIColor, secondaryColor: UIColor?, backgroundColor: UIColor, isSelected: Bool) {
        switch style {
        case .standard:
            self.backgroundColor = isSelected ? color : backgroundColor
            
            circularView.isHidden  = true
            lineView.isHidden = true
            rightSemicircleView.isHidden = true
            leftSemicircleView.isHidden  = true
            leftConnectorView.isHidden = true
            rightConnectorView.isHidden = true
            
        // isSelected is always true
        case .circle:
            circularView.backgroundColor = color
            self.backgroundColor = backgroundColor
            
            circularView.isHidden  = false
            lineView.isHidden = true
            rightSemicircleView.isHidden = true
            leftSemicircleView.isHidden  = true
            leftConnectorView.isHidden = true
            rightConnectorView.isHidden = true
            
        // isSelected is always true
        case .semicircleEdge(let position):
            lineView.isHidden = true
            circularView.isHidden = true
            leftConnectorView.isHidden = true
            rightConnectorView.isHidden = true
            
            if case .left = position {
                rightSemicircleView.isHidden = false
                leftSemicircleView.isHidden  = false
                self.backgroundColor = backgroundColor
                
                leftSemicircleView.backgroundColor  = color
                rightSemicircleView.backgroundColor = color
                
                leftSemicircleView.mask(with: .left)
                rightSemicircleView.mask(with: .none)
                
            } else if case .middle = position {
                rightSemicircleView.isHidden = true
                leftSemicircleView.isHidden  = true
                self.backgroundColor = color
                
            } else if case .right = position {
                rightSemicircleView.isHidden = false
                leftSemicircleView.isHidden  = false
                self.backgroundColor = backgroundColor
                
                leftSemicircleView.backgroundColor  = color
                rightSemicircleView.backgroundColor = color
                
                leftSemicircleView.mask(with: .none)
                rightSemicircleView.mask(with: .right)
                
            } else if case .single = position {
                rightSemicircleView.isHidden = false
                leftSemicircleView.isHidden  = false
                self.backgroundColor = backgroundColor
                
                leftSemicircleView.backgroundColor  = color
                rightSemicircleView.backgroundColor = color
                
                leftSemicircleView.mask(with: .left)
                rightSemicircleView.mask(with: .right)
            }
            
        // isSelected is always true
        case .connectedCircle(let position):
            lineView.isHidden = true
            circularView.isHidden = true
            rightSemicircleView.isHidden = true
            leftSemicircleView.isHidden  = true
            
            if case .left = position {
                self.backgroundColor = backgroundColor
                
                circularView.isHidden = false
                rightConnectorView.isHidden = false
                leftConnectorView.isHidden = true
                
                circularView.backgroundColor = color
                rightConnectorView.backgroundColor = secondaryColor
                
            } else if case .middle = position {
                self.backgroundColor = backgroundColor
                
                leftConnectorView.isHidden = false
                rightConnectorView.isHidden = false
                
                leftConnectorView.backgroundColor = secondaryColor
                rightConnectorView.backgroundColor = secondaryColor
                
            } else if case .right = position {
                self.backgroundColor = backgroundColor
                
                circularView.isHidden = false
                rightConnectorView.isHidden = true
                leftConnectorView.isHidden = false
                
                circularView.backgroundColor = color
                leftConnectorView.backgroundColor = secondaryColor
                
            } else if case .single = position {
                self.backgroundColor = backgroundColor
                
                circularView.isHidden = false
                rightConnectorView.isHidden = true
                leftConnectorView.isHidden = true
                
                circularView.backgroundColor = color
                
            }
            
        case .line(let position):
            rightSemicircleView.isHidden = true
            leftSemicircleView.isHidden  = true
            circularView.isHidden = true
            leftConnectorView.isHidden = true
            rightConnectorView.isHidden = true
            lineView.isHidden = false
            lineView.backgroundColor = color
            
            // Config of lineView should end. (configureLineView())
            // position is only sequence style
            guard let position = position else {
                lineView.frame.origin.x = (bounds.width - lineView.frame.width) / 2
                return
            }
            switch position {
            case .left:
                lineView.frame.origin.x = bounds.width - lineView.frame.width
            case .middle:
                lineView.frame.size.width = bounds.width
                lineView.frame.origin.x   = (bounds.width - lineView.frame.width) / 2
            case .right:
                lineView.frame.origin.x = 0
            case .single:
                lineView.frame.origin.x = 0
            }
        }
    }
}

// MARK: - Private Methods

private extension KoyomiCell {
    var postion: CGPoint {
        let dayWidth  = contentLabel.frame.width
        let dayHeight = contentLabel.frame.height
        let width  = frame.width
        let height = frame.height
        let padding: CGFloat = 2
        
        switch contentPosition {
        // Top
        case .topLeft:   return .init(x: padding, y: padding)
        case .topCenter: return .init(x: (width - dayWidth) / 2, y: padding)
        case .topRight:  return .init(x: width - dayWidth - padding, y: padding)
        // Center
        case .left:   return .init(x: padding, y: (height - dayHeight) / 2)
        case .center: return .init(x: (width - dayWidth) / 2, y: (height - dayHeight) / 2)
        case .right:  return .init(x: width - dayWidth - padding, y: (height - dayHeight) / 2)
        // Bottom
        case .bottomLeft:   return .init(x: padding, y: height - dayHeight - padding)
        case .bottomCenter: return .init(x: (width - dayWidth) / 2, y: height - dayHeight - padding)
        case .bottomRight:  return .init(x: width - dayWidth - padding, y: height - dayHeight - padding)
        // Custom
        case .custom(let x, let y): return .init(x: x, y: y)
        }
    }
    
    func setup() {
        leftConnectorView.isHidden = true
        rightConnectorView.isHidden = true
        addSubview(leftConnectorView)
        addSubview(rightConnectorView)
        
        circularView.isHidden = true
        addSubview(circularView)
        
        leftSemicircleView.frame = CGRect(x: 0, y: 0, width: bounds.width / 2, height: bounds.height)
        leftSemicircleView.isHidden = true
        addSubview(leftSemicircleView)
        
        rightSemicircleView.frame = CGRect(x: bounds.width / 2, y: 0, width: bounds.width / 2, height: bounds.height)
        rightSemicircleView.isHidden = true
        addSubview(rightSemicircleView)
        
        addSubview(contentLabel)
        
        let lineViewSize: CGSize = .init(width: bounds.width, height: 1)
        lineView.frame = CGRect(origin: .init(x: 0, y: (bounds.height - lineViewSize.height) / 2), size: lineViewSize)
        lineView.isHidden = true
        addSubview(lineView)
    }
    
    func adjustSubViewsFrame() {
        contentLabel.sizeToFit()
        contentLabel.frame.origin = postion
        
        rightSemicircleView.frame = CGRect(x: bounds.width / 2, y: 0, width: bounds.width / 2, height: bounds.height)
        leftSemicircleView.frame  = CGRect(x: 0, y: 0, width: bounds.width / 2, height: bounds.height)
    }
    
    func configureCircularView() {
        let diameter = bounds.width * circularViewDiameter
        circularView.frame = CGRect(x: (bounds.width - diameter) / 2, y: (bounds.height - diameter) / 2, width: diameter, height: diameter)
        circularView.layer.cornerRadius = diameter / 2
    }
    
    func configureConnectorViews() {
        let diameter = bounds.width * circularViewDiameter
        leftConnectorView.frame = CGRect(x: 0, y: (bounds.height - diameter) / 2, width: bounds.width / 2, height: diameter)
        rightConnectorView.frame = CGRect(x: bounds.width / 2, y: (bounds.height - diameter) / 2, width: bounds.width / 2, height: diameter)
    }
    
    func configureLineView() {
        guard let appearance = lineViewAppearance else { return }
        lineView.frame.size = CGSize(width: bounds.width * appearance.widthRate, height: appearance.height)
        lineView.frame.origin.y = {
            switch appearance.position {
            case .top:    return (bounds.height / 2 - lineView.frame.height) / 2
            case .center: return (bounds.height - lineView.frame.height) / 2
            case .bottom: return (bounds.height / 2 - lineView.frame.height) / 2 + bounds.height / 2
            }
        }()
    }
}
