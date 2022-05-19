//
//  PasscodeView.swift
//  MobileWAY
//
//  Created by Tiago Ribeiro on 07/02/2022.
//

import SwiftUI

public struct PasscodeView: View {
    
    public enum ValidationError: Error, CustomDebugStringConvertible {
        case hasNotThreeUniqueDigits
        case isWrappingSequence
        
        public var debugDescription: String {
            switch self {
            case .hasNotThreeUniqueDigits:
                return "Passcode does not contain three unique digits."
            case .isWrappingSequence:
                return "Passcode contains wrapping sequence."
            }
        }
    }
    
    public enum PasscodeState {
        case valid
        case invalid
        case unknown
    }
    
    private var buttonsStrokeColor: Color = .accentColor
    private var foregroundColor: Color = .primary
    private var dotsColor: Color = .accentColor
    private var validColor: Color = .green
    private var invalidColor: Color = .red
    
    @State private var state: PasscodeState = .unknown
    @State private var passcodeText: String = ""
    @State private var performErrorAnimation: Bool = false
    
    @Binding private var bindableState: PasscodeState
    private let numberOfDigits: Int
    private let validationRules: [PasscodeValidationRules]
    private let onCompleteAction: (String) -> ()
    private let onValidationFailure: ((ValidationError) -> ())?
    
    private var currentStateColor: Color {
        switch self.state {
        case .valid:
            return self.validColor
        case .invalid:
            return self.invalidColor
        case .unknown:
            return self.dotsColor
        }
    }
    
    public init(numberOfDigits: Int = 4, state: Binding<PasscodeState>? = nil, validationRules: [PasscodeValidationRules] = [], onCompleteAction: @escaping (String) -> (), onValidationFailure: ((ValidationError) -> ())? = nil) {
        self.numberOfDigits = numberOfDigits
        self.validationRules = validationRules
        self.onCompleteAction = onCompleteAction
        self.onValidationFailure = onValidationFailure
        if let state = state {
            self._bindableState = state
        }
        else {
            self._bindableState = .constant(.unknown)
        }
    }
    
    public var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    ForEach(0..<self.numberOfDigits, id: \.self) { digit in
                        Image(systemName: digit < self.passcodeText.count ? "circle.fill" : "circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(self.currentStateColor)
                    }
                }
                .frame(height: 10)
                .padding(.vertical)
                .offset(x: self.performErrorAnimation ? -20 : 0)
                .onChange(of: self.state) {
                    if case .invalid = $0 {
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.1, blendDuration: 0.7)) {
                            self.performErrorAnimation.toggle()
                        }
                        self.performErrorAnimation.toggle()
                    }
                }
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 44)),
                        GridItem(.flexible(minimum: 44)),
                        GridItem(.flexible(minimum: 44))],
                    spacing: 0.012 * geometry.size.height) {
                    ForEach(1..<10) { digit in
                        Button("\(digit)") { self.digitTouched(digit) }
                    }
                    Spacer()
                    Button("0") { self.digitTouched(0) }
                    Button {
                        self.deleteTouched()
                    } label: {
                        Image(systemName: "delete.left")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                    }
                }
                .buttonStyle(PasscodeButtonStyle(
                    foregroundColor: self.foregroundColor,
                    strokeColor: self.buttonsStrokeColor))
                .padding(.top)
            }
        }
        .onChange(of: self.state) { self.bindableState = $0 }
        .onChange(of: self.bindableState) { self.state = $0 }
    }
    
    private func reset() {
        self.state = .unknown
        self.passcodeText = ""
    }
    
    private func digitTouched(_ digit: Int) {
        if case .invalid = self.state {
            self.reset()
        }
        
        if self.passcodeText.count < self.numberOfDigits {
            self.passcodeText.append("\(digit)")
            
            if self.passcodeText.count == self.numberOfDigits {
                self.validatePasscode()
            }
        }
    }
    
    private func deleteTouched() {
        if self.passcodeText.count > 0 {
            self.passcodeText.removeLast()
        }
    }
    
    private func validatePasscode() {
        if self.validationRules.count > 0 {
            if self.validationRules.contains(.hasThreeUniqueDigits) && !PasscodeValidationRules.hasThreeUniqueDigits.validate(self.passcodeText) {
                self.state = .invalid
                self.onValidationFailure?(.hasNotThreeUniqueDigits)
                return
            }
            else if self.validationRules.contains(.isNotWrappingSequence) && !PasscodeValidationRules.isNotWrappingSequence.validate(self.passcodeText) {
                self.state = .invalid
                self.onValidationFailure?(.isWrappingSequence)
                return
            }
            self.state = .valid
        }
        self.onCompleteAction(self.passcodeText)
    }
}

public extension PasscodeView {
    
    func dotsColor(_ color: Color) -> PasscodeView {
        var view = self
        view.dotsColor = color
        return view
    }
    
    func buttonsStrokeColor(_ color: Color) -> PasscodeView {
        var view = self
        view.buttonsStrokeColor = color
        return view
    }
    
    func foregroundColor(_ color: Color) -> PasscodeView {
        var view = self
        view.foregroundColor = color
        return view
    }
}

#if DEBUG
struct PasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PasscodeView(validationRules: [.hasThreeUniqueDigits, .isNotWrappingSequence]) { _ in }
                .buttonsStrokeColor(.blue)
                .dotsColor(.accentColor)
                .foregroundColor(.blue)
                .font(.headline)
                .minimumScaleFactor(0.5)
        }
        .padding(.horizontal, 100)
    }
}
#endif
