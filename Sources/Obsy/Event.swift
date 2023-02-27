//
//  File.swift
//  
//
//  Created by Young Bin on 2023/02/25.
//

import Foundation

// MARK: - Event
@frozen public enum Event<Element> {
    case next(Element)
    case error(Swift.Error)
}
