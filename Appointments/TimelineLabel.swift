//
//  TimelineLabel.swift
//  Appointments
//
//  Created by Shilpa Garg on 06/06/20.
//  Copyright © 2020 Shilpa Garg. All rights reserved.
//

import UIKit

final class TimelineLabel: UILabel {
    var valueHash: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
