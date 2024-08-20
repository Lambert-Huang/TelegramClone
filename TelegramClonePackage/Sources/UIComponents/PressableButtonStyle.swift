//
//  PressableButtonStyle.swift
//
//
//  Created by lambert on 2024/8/19.
//

import SwiftUI

public struct PressableButtonStyle: ViewModifier {
  @State private var isPressed = false
  let action: () -> Void
  public init(action: @escaping () -> Void) {
    self.action = action
  }
  public func body(content: Content) -> some View {
    content
      .scaleEffect(isPressed ? 0.95 : 1.0)
      .animation(.bouncy(duration: 0.1), value: isPressed)
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { _ in isPressed = true }
          .onEnded { _ in 
            isPressed = false
            action()
          }
      )
  }
}

extension View {
  public func pressableStyle(action: @escaping () -> Void) -> some View {
    self
      .modifier(PressableButtonStyle(action: action))
  }
}
