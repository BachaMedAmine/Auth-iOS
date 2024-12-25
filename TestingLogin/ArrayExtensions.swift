//
//  ArrayExtensions.swift
//  TestingLogin
//
//  Created by Becha Med Amine on 11/12/2024.
//

import Foundation

extension Array where Element: Identifiable, Element.ID: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element.ID>()
        return self.filter { element in
            guard !seen.contains(element.id) else { return false }
            seen.insert(element.id)
            return true
        }
    }
}
