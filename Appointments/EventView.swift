//
//  EventPageView.swift
//  Appointments
//
//  Created by Shilpa Garg on 06/06/20.
//  Copyright © 2020 Shilpa Garg. All rights reserved.
//

import UIKit

private let pointX: CGFloat = 5

final class EventView: UIView {
    let event: Event
    private let timelineStyle: TimelineStyle
    private let color: UIColor
    
    private let textView: UITextView = {
        let text = UITextView()
        text.backgroundColor = .clear
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        text.textContainer.lineBreakMode = .byTruncatingTail
        text.textContainer.lineFragmentPadding = 0
        text.layoutManager.allowsNonContiguousLayout = true
        return text
    }()
    
    init(event: Event, style: TimelineStyle, frame: CGRect) {
        self.event = event
        self.timelineStyle = style
        self.color = .black
        super.init(frame: frame)
        backgroundColor = .orange
        
        var textFrame = frame
        textFrame.origin.x = pointX
        textFrame.origin.y = 0
        
        textFrame.size.height = textFrame.height
        textFrame.size.width = textFrame.width - pointX
        textView.frame = textFrame
        textView.font = style.eventFont
        textView.textColor = .black
        textView.textAlignment = .center
        textView.text = event.text
        
        if textView.frame.width > 20 {
            addSubview(textView)
        }
        tag = "\(event.id)".hashValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.interpolationQuality = .none
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(2)
        let x: CGFloat = 1
        let y: CGFloat = 0
        context.beginPath()
        context.move(to: CGPoint(x: x, y: y))
        context.addLine(to: CGPoint(x: x, y: bounds.height))
        context.strokePath()
        context.restoreGState()
    }
}

public struct Event {
    public var id: String = ""
    public var text: String = ""
    public var start: Date = Date()
    public var end: Date = Date()
    public init() {}
}

extension Event: EventProtocol {
    public func compare(_ event: Event) -> Bool {
        return "\(id)".hashValue == "\(event.id)".hashValue
    }
}

public protocol EventProtocol {
    func compare(_ event: Event) -> Bool
}
