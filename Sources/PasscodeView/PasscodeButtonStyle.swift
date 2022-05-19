import SwiftUI

struct PasscodeButtonStyle: ButtonStyle {
    let foregroundColor: Color
    let strokeColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .white : self.foregroundColor)
            .frame(
                minWidth: 44,
                idealWidth: 60,
                maxWidth: .infinity,
                minHeight: 44,
                idealHeight: 60,
                maxHeight: .infinity)
            .background(configuration.isPressed ? Color.accentColor : Color.clear)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(self.strokeColor))
    }
}
