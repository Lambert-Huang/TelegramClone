//
//  File.swift
//
//
//  Created by lambert on 2024/8/15.
//

import CasePaths
import Dependencies
import Perception
import SwiftNavigation
import SwiftUI
import SwiftUIX
import Animations
import IssueReporting
import UIComponents

@MainActor
@Perceptible
public final class AuthModel {
  var destination: Destination {
    didSet {
      self.bind()
    }
  }
  
  var alert: Alert?

  var onLoadingFinished: () -> Void = unimplemented("", placeholder: ())
  
  public init(destination: Destination) {
    self.destination = destination
    self.bind()
  }

  @CasePathable
  @dynamicMemberLookup
  public enum Destination: Hashable {
    case authToken(AuthTokenModel)
    case authPhoneNumber(AuthPhoneNumberModel)
    case loading
  }
  
  @CasePathable
  @dynamicMemberLookup
  public enum Alert: Hashable {
    case authPhoneNumberNextAlert(ModalAlertData)
  }
  
  func loadingDidFinished() {
    onLoadingFinished()
  }

  private func bind() {
    self.onLoadingFinished = { [weak self] in
      guard let self else { return }
      self.destination = .authToken(AuthTokenModel())
    }
    switch self.destination {
      case let .authToken(authTokenModel):
        self.bindAuthToken(model: authTokenModel)
      case let .authPhoneNumber(authPhoneNumberModel):
        self.bindAuthPhoneNumber(model: authPhoneNumberModel)
      default: break
    }
  }

  private func bindAuthToken(model: AuthTokenModel) {
    model.onPhoneNumberLoginTapped = { [weak self] in
      guard let self else { return }
      self.destination = .authPhoneNumber(AuthPhoneNumberModel())
    }
  }

  private func bindAuthPhoneNumber(model: AuthPhoneNumberModel) {
    model.onLogInByQrCodeTapped = { [weak self] in
      guard let self else { return }
      self.destination = .authToken(AuthTokenModel())
    }
    model.onNextTapped = { [weak self, weak model] in
      guard let self, let model else { return }
      self.alert = .authPhoneNumberNextAlert(
        ModalAlertData(
          title: "Telegram",
          message: model.readyValue,
          secondaryButtonTitle: "Cancel",
          primaryButtonTitle: "Ok",
          secondaryBackgroundColorHex: 0x292b36,
          primaryBackgroundColorHex: 0x2481cc,
          secondaryButtonAction: {
            self.alert = nil
          },
          primaryButtonAction: {
            self.alert = nil
          }
        )
      )
    }
  }
  func dismissAlert() {
    self.alert = nil
  }
}

extension AuthModel: HashableObject {}

public struct AuthView: View {
  @State private var model: AuthModel
  public init(model: AuthModel) {
    self.model = model
  }

  public var body: some View {
    WithPerceptionTracking {
      Group {
        switch self.model.destination {
          case let .authToken(authTokenModel):
            WithPerceptionTracking {
              AuthTokenView(model: authTokenModel)
                .asymmetricScaleOpacityTransition()
            }
          case let .authPhoneNumber(authPhoneNumberModel):
            WithPerceptionTracking {
              AuthPhoneNumberView(model: authPhoneNumberModel)
                .asymmetricScaleOpacityTransition()
            }
          case .loading:
            ActivityIndicator()
              .asymmetricScaleOpacityTransition()
              .onAppear {
                Task {
                  try await Task.sleep(nanoseconds: 2_000_000_000)
                  self.model.loadingDidFinished()
                }
              }
        }
      }
      .frame(width: 380, height: 500)
      .modalAlert(item: $model.alert.authPhoneNumberNextAlert) { modalAlertData in
        ModalAlertView(modalAlertData: modalAlertData)
      }
    }
  }
}
