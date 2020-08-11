//
//  TimelineModel.swift
//  Appointments
//
//  Created by Shilpa Garg on 06/06/20.
//  Copyright © 2020 Shilpa Garg. All rights reserved.
//

import Foundation

struct PageTree: Hashable {
    let parent: Parent
    var children: [Child]
    var count: Int
    
    init(parent: Parent, children: [Child]) {
        self.parent = parent
        self.children = children
        self.count = children.count + 1
    }
    
    func equalToChildren(_ event: Event) -> Bool {
        return children.contains(where: { $0.start == event.start.timeIntervalSince1970 })
    }
    
    func excludeToChildren(_ event: Event) -> Bool {
        return children.contains(where: { $0.start..<$0.end ~= event.start.timeIntervalSince1970 })
    }
    
    static func == (lhs: PageTree, rhs: PageTree) -> Bool {
        return lhs.parent == rhs.parent
            && lhs.children == rhs.children
            && lhs.count == rhs.count
    }
}

struct Parent: Equatable, Hashable {
    let start: TimeInterval
    let end: TimeInterval
}

struct Child: Equatable, Hashable {
    let start: TimeInterval
    let end: TimeInterval
}

protocol CompareEventDateProtocol {
    func compareStartDate(event: Event, date: Date?) -> Bool
    func compareEndDate(event: Event, date: Date?) -> Bool
}

extension CompareEventDateProtocol {
    func compareStartDate(event: Event, date: Date?) -> Bool {
        return event.start.year == date?.year && event.start.month == date?.month && event.start.day == date?.day
    }
    
    func compareEndDate(event: Event, date: Date?) -> Bool {
        return event.end.year == date?.year && event.end.month == date?.month && event.end.day == date?.day
    }
}
