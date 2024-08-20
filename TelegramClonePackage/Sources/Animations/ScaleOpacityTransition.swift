//
//  File.swift
//  
//
//  Created by lambert on 2024/8/15.
//

import SwiftUI

public struct AsymmetricScaleOpacityTransition: ViewModifier {
  public let insertionScale: CGFloat
  public let removalScale: CGFloat
  public init(insertionScale: CGFloat = 1.15, removalScale: CGFloat = 0.75) {
    self.insertionScale = insertionScale
    self.removalScale = removalScale
  }
  public func body(content: Content) -> some View {
    content
      .transition(
        .asymmetric(
          insertion: .opacity.combined(with: .scale(scale: insertionScale)),
          removal: .scale(scale: removalScale).combined(with: .opacity)
        )
      )
  }
}

extension View {
  public func asymmetricScaleOpacityTransition(
    insertionScale: CGFloat = 1.15,
    removalScale: CGFloat = 0.75
  ) -> some View {
    self.modifier(
      AsymmetricScaleOpacityTransition(
        insertionScale: insertionScale,
        removalScale: removalScale
      )
    )
  }
}
