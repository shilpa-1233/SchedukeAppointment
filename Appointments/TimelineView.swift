//
//  TimelineView.swift
//  Appointments
//
//  Created by Shilpa Garg on 06/06/20.
//  Copyright © 2020 Shilpa Garg. All rights reserved.
//

import UIKit

public struct TimelineStyle {
    public var eventFont: UIFont = .systemFont(ofSize: 10)
    public var offsetEvent: CGFloat = 1
    public var heightLine: CGFloat = 0.5
    public var offsetLineLeft: CGFloat = 10
    public var offsetLineRight: CGFloat = 10
    public var backgroundColor: UIColor = .red
    public var widthTime: CGFloat = 40
    public var heightTime: CGFloat = 30
    public var offsetTimeX: CGFloat = 10
    public var offsetTimeY: CGFloat = 0
    public var timeColor: UIColor = .black
    public var timeFont: UIFont = .boldSystemFont(ofSize: 12)
}

final class TimelineView: UIView, CompareEventDateProtocol {
    
    private var style: TimelineStyle = TimelineStyle()
    private var hours: [String] = [String]()
    private var allEvents = [Event]()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .white
        return scroll
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.hours = showHours()
        backgroundColor = .white
        var scrollFrame = frame
        scrollFrame.origin.y = 0
        scrollView.frame = scrollFrame
        addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: topAnchor,constant: 100).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showHours() -> [String] {
        let AM = (["9","10","11"].map { $0 + " AM"})
        let noon =  "12 PM"
        let pm = (Array(1...9).map({ String($0) }).map { $0 + " PM" })
        
        return AM+[noon]+pm
    }
    
    private func createTimesLabel(start: Int) -> [TimelineLabel] {
        var times = [TimelineLabel]()
        for (id, hour) in hours.enumerated() where id >= start {
            let yTime = (style.offsetTimeY + style.heightTime) * CGFloat(id - start)
            
            let time = TimelineLabel(frame: CGRect(x: style.offsetTimeX,
                                                   y: yTime,
                                                   width: style.widthTime,
                                                   height: style.heightTime))
            time.font = style.timeFont
            time.textAlignment = .center
            time.textColor = style.timeColor
            time.text = hour
            let formatter = DateFormatter()
            formatter.dateFormat = "h a"
            let hourTmp = showHours()[id]
            time.valueHash = formatter.date(from: hourTmp)?.hour.hashValue
            time.tag = id - start
            times.append(time)
        }
        return times
    }
    
    private func createLines(times: [TimelineLabel]) -> [UIView] {
        var lines = [UIView]()
        for (id, time) in times.enumerated() {
            let xLine = time.frame.width + style.offsetTimeX + style.offsetLineLeft
            let lineFrame = CGRect(x: xLine,
                                   y: time.center.y,
                                   width: frame.width - xLine,
                                   height: style.heightLine)
            let line = UIView(frame: lineFrame)
            line.backgroundColor = .gray
            line.tag = id
            lines.append(line)
        }
        return lines
    }
    
    private func createVerticalLine(pointX: CGFloat) -> UIView {
        let frame = CGRect(x: pointX, y: 0, width: 0.5, height: scrollView.contentSize.height)
        let line = UIView(frame: frame)
        line.tag = -30
        line.backgroundColor = .systemGray
        line.isHidden = false
        return line
    }
    
    private func countEventsInHour(events: [Event]) -> [PageTree] {
        var eventsTemp = events
        var newCountsEvents = [PageTree]()
        
        while !eventsTemp.isEmpty {
            guard let event = eventsTemp.first else { return newCountsEvents }
            
            if let id = newCountsEvents.firstIndex(where: { $0.parent.start..<$0.parent.end ~= event.start.timeIntervalSince1970 }) {
                newCountsEvents[id].children.append(Child(start: event.start.timeIntervalSince1970,
                                                           end: event.end.timeIntervalSince1970))
                newCountsEvents[id].count = newCountsEvents[id].children.count + 1
            } else if let id = newCountsEvents.firstIndex(where: { $0.excludeToChildren(event) }) {
                newCountsEvents[id].children.append(Child(start: event.start.timeIntervalSince1970,
                                                           end: event.end.timeIntervalSince1970))
                newCountsEvents[id].count = newCountsEvents[id].children.count + 1
            } else {
                newCountsEvents.append(PageTree(parent: Parent(start: event.start.timeIntervalSince1970,
                                                                    end: event.end.timeIntervalSince1970),
                                                     children: []))
            }
            
            eventsTemp.removeFirst()
        }
        
        return newCountsEvents
    }
    
    private func setOffsetScrollView() {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func calculatePointYByMinute(_ minute: Int, time: TimelineLabel) -> CGFloat {
        let pointY: CGFloat
        if 1...59 ~= minute {
            let minutePercent = 59.0 / CGFloat(minute)
            let newY = (style.offsetTimeY + time.frame.height) / minutePercent
            let summY = (CGFloat(time.tag) * (style.offsetTimeY + time.frame.height)) + (time.frame.height / 2)
            if time.tag == 0 {
                pointY = newY + (time.frame.height / 2)
            } else {
                pointY = summY + newY
            }
        } else {
            pointY = (CGFloat(time.tag) * (style.offsetTimeY + time.frame.height)) + (time.frame.height / 2)
        }
        return pointY
    }
    
    func create(events: [Event]) {
        
        allEvents = events
        
        let times = createTimesLabel(start: 0)
        let lines = createLines(times: times)
        
        let heightAllTimes = times.reduce(0, { $0 + ($1.frame.height + style.offsetTimeY) })
        scrollView.contentSize = CGSize(width: frame.width, height: heightAllTimes)
        times.forEach({ scrollView.addSubview($0) })
        lines.forEach({ scrollView.addSubview($0) })
            
        let offset = style.widthTime + style.offsetTimeX + style.offsetLineLeft
        let widthPage = (frame.width - offset)
        let heightPage = (CGFloat(times.count) * (style.heightTime + style.offsetTimeY)) - 75
        
        let pointX: CGFloat
        pointX = offset
        scrollView.addSubview(createVerticalLine(pointX: pointX))
        
        let eventsByDate = allEvents
            .sorted(by: { $0.start < $1.start })
        
        let countEventsOneHour = countEventsInHour(events: eventsByDate)
        var pages = [EventView]()
        
        if !eventsByDate.isEmpty {
            var newFrame = CGRect(x: 0, y: 0, width: 0, height: heightPage)
            eventsByDate.forEach { (event) in
                times.forEach({ (time) in
                    if event.start.hour.hashValue == time.valueHash {
                        newFrame.origin.y = calculatePointYByMinute(event.start.minute, time: time)
                    }
                    if event.end.hour.hashValue == time.valueHash {
                        let summHeight = (CGFloat(time.tag) * (style.offsetTimeY + time.frame.height)) - newFrame.origin.y + (time.frame.height / 2)
                        if 0..<59 ~= event.end.minute {
                            let minutePercent = 59.0 / CGFloat(event.end.minute)
                            let newY = (style.offsetTimeY + time.frame.height) / minutePercent
                            newFrame.size.height = summHeight + newY - style.offsetEvent
                        } else {
                            newFrame.size.height = summHeight - style.offsetEvent
                        }
                    }
                })
                
                var newWidth = widthPage
                var newPointX = pointX
                if let id = countEventsOneHour.firstIndex(where: { $0.parent.start == event.start.timeIntervalSince1970 || $0.equalToChildren(event) }) {
                    let count = countEventsOneHour[id].count
                    newWidth /= CGFloat(count)
                    
                    if count > 1 {
                        var stop = pages.count
                        while stop != 0 {
                            for page in pages where page.frame.origin.x.rounded() <= newPointX.rounded()
                                && newPointX.rounded() <= (page.frame.origin.x + page.frame.width).rounded()
                                && page.frame.origin.y.rounded() <= newFrame.origin.y.rounded()
                                && newFrame.origin.y <= (page.frame.origin.y + page.frame.height).rounded() {
                                    newPointX = page.frame.origin.x.rounded() + newWidth
                            }
                            stop -= 1
                        }
                    }
                    
                }
                newFrame.origin.x = newPointX
                newFrame.size.width = newWidth - style.offsetEvent
                
                let page = EventView(event: event, style: style, frame: newFrame)
                scrollView.addSubview(page)
                pages.append(page)
                
            }
        }
        setOffsetScrollView()
    }
    
}
