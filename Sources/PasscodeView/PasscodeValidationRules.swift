//
//  PasscodeValidationRules.swift
//  MobileWAY
//
//  Created by Tiago Ribeiro on 09/02/2022.
//

import Foundation


public struct PasscodeValidationRules: Equatable {
    public static func == (lhs: PasscodeValidationRules, rhs: PasscodeValidationRules) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    private let rawValue: Int
    let validate: (_ pin: String) -> Bool
    
    public static var hasThreeUniqueDigits = PasscodeValidationRules(rawValue: 0<<1) { pin in
        let differenceCount = pin
            .reduce("") {
                $0.contains($1) ? $0 : $0.appending(String($1))
            }
            .count
        return differenceCount >= 3
    }
    
    public static var isNotWrappingSequence = PasscodeValidationRules(rawValue: 0<<2) { pin in
        return [
            PasscodeValidationRules.isNotIncreasingWrappingSequence,
            .isNotDecreasingWrappingSequence
        ].reduce(true) { $0 && $1.validate(pin) }
    }
    
    private static var isNotIncreasingWrappingSequence = PasscodeValidationRules(rawValue: 0<<3) { pin in
        guard
            let firstCharacter = pin.first,
            let firstDigit = Int(String(firstCharacter))
        else { return false }
        
        let indexOffsetArray = 0..<pin.count
        let result = indexOffsetArray
            .map { String((firstDigit + $0) % 10) }
            .joined()
        return result != pin
    }
    
    private static var isNotDecreasingWrappingSequence = PasscodeValidationRules(rawValue: 0<<4) { pin in
        guard
            let firstCharacter = pin.first,
            let firstDigit = Int(String(firstCharacter))
        else { return false }
        
        let indexOffsetArray = 0..<pin.count
        let result = indexOffsetArray
            .map {
                let dividend = firstDigit - $0
                let modulus = dividend % 10
                let positiveModulus = modulus >= 0 ? modulus : modulus + 10
                return String(positiveModulus)
            }
            .joined()
        return result != pin
    }
}
