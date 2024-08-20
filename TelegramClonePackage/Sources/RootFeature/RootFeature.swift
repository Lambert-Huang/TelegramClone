
import AuthFeature
import CasePaths
import ColorPalette
import Dependencies
import Foundation
import Perception
import SwiftNavigation
import SwiftUI
import SwiftUIX

@MainActor
@Perceptible
public final class RootModel {
  var destination: Destination = .auth(
    AuthModel(
      destination: .loading
    )
  )
  public init() {}

  @CasePathable
  @dynamicMemberLookup
  public enum Destination: Hashable {
    case auth(AuthModel)
  }
}

public struct RootView: View {
  @State private var model: RootModel
  public init(model: RootModel) {
    self.model = model
  }

  public var body: some View {
    WithPerceptionTracking {
      Group {
        switch model.destination {
          case .auth(let authModel):
            WithPerceptionTracking {
              AuthView(model: authModel)
                .padding()
            }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(ColorPalette.dark.background)
    }
  }
}
