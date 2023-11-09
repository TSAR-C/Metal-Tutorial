//
//  FloatPicker.swift
//  Metal 3D
//
//  Created by TSAR Weasley on 2023/11/9.
//

import SwiftUI

struct FloatPicker: View {
    @Binding var value: Float
    private(set) var range: ClosedRange<Float> = -1...1
    var label: String = ""
    
    private var displayString: String {
        let valueStr = value.formatted(
            .number.precision(.integerAndFractionLength(integer: 1, fraction: 2))
        )
        
        if value < 0 {
            return "\(label): \(valueStr)"
        } else {
            return "\(label):  \(valueStr)"
        }
    }
    
    var body: some View {
        HStack {
            Slider(value: $value, in: range)
            Stepper(value: $value, in: range) {
                Text(displayString).monospaced()
            }
        }.frame(width: 200)
    }
}

#Preview {
    FloatPicker(value: .constant(.zero))
}
