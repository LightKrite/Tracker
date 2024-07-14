//
//  String.swift
//  Tracker
//
//  Created by Egor Partenko on 09.07.2024.
//

import Foundation

extension String {
    /// откуда брать строку
    enum Source: String {
        /// общий файл
        case common = "Localizable"
        /// локализация
        case target = "Localizable (English)"
    }
    
    func localized(
        from source: Source = .common,
        _ bundle: Bundle = Bundle.main,
        _ comment: String = "") -> String {
        var notFoundValue = self
        // на всякий случай пытаемся найти значение в общем файле, вернем его если не будет найдено в source
        if source != .common {
            notFoundValue = NSLocalizedString(
                self,
                tableName: Source.common.rawValue,
                bundle: bundle,
                comment: comment)
        }
        return NSLocalizedString(
            self,
            tableName: source.rawValue,
            bundle: bundle,
            value: notFoundValue,
            comment: comment)
    }
    
    func localizedPlural(for number: Int, from source: Source = .common) -> String {
        let locale = Locale(identifier: "ru_RU")
        return String(format: self.localized(from: source), locale: locale, arguments: [number])
    }
}
