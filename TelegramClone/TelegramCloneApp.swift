//
//  TelegramCloneApp.swift
//  TelegramClone
//
//  Created by lambert on 2024/8/14.
//

import SwiftUI
import RootFeature
import Perception

@main
struct TelegramCloneApp: App {
  var body: some Scene {
    WindowGroup {
      WithPerceptionTracking {
        RootView(
          model: RootModel()
        )
      }
    }
  }
}
