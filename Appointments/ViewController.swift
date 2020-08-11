//
//  ViewController.swift
//  Appointments
//
//  Created by Shilpa Garg on 06/06/20.
//  Copyright © 2020 Shilpa Garg. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    private var events = [Event]()
    
    private lazy var timelineView: TimelineView = {
        var timelineFrame = view.frame
        timelineFrame.origin.y = 60
        timelineFrame.size.height = view.frame.height
        timelineFrame.size.width = UIScreen.main.bounds.width
        let view = TimelineView(frame: timelineFrame)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            view.backgroundColor = .white
        
        view.addSubview(timelineView)
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        timelineView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        timelineView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        timelineView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        timelineView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        loadEvents { [unowned self] (events) in
            self.events = events
            timelineView.create(events: events)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}


extension ViewController {
    func loadEvents(completion: ([Event]) -> Void) {
        var events = [Event]()
        let decoder = JSONDecoder()
                
        guard let path = Bundle.main.path(forResource: "events", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let result = try? decoder.decode(ItemData.self, from: data) else { return }
        
        for (_, item) in result.data.enumerated() {
            let startDate = self.formatter(date: item.start)
            let endDate = self.formatter(date: item.end)
            let startTime = self.timeFormatter(date: startDate)
            let endTime = self.timeFormatter(date: endDate)
            
            var event = Event()
            event.start = startDate
            event.end = endDate
            event.text = "\(item.title):\(startTime)-\(endTime)"
            events.append(event)
        }
        completion(events)
    }
    
    func timeFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    func formatter(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        return formatter.date(from: date) ?? Date()
    }
}

struct ItemData: Decodable {
    let data: [Item]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([Item].self, forKey: CodingKeys.data)
    }
}
struct Item: Decodable {
    let title: String
    let start: String
    let end: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case start
        case end
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: CodingKeys.title)
        start = try container.decode(String.self, forKey: CodingKeys.start)
        end = try container.decode(String.self, forKey: CodingKeys.end)
    }
}

