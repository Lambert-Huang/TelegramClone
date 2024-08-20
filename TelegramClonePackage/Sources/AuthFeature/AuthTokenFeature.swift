//
//  File.swift
//  
//
//  Created by lambert on 2024/8/15.
//

import Foundation
import Perception
import SwiftUIX
import SwiftUI
import ColorPalette
import SwiftNavigation
import IssueReporting

@MainActor
@Perceptible
public final class AuthTokenModel {
  var first = true
  var tokenOptions: [ExportTokenOption] = ExportTokenOption.tokenOptions
  var onPhoneNumberLoginTapped: () -> Void = unimplemented("phoneNumberLoginTapped")
  public init() {}
  func phoneNumberLoginTapped() {
    onPhoneNumberLoginTapped()
  }
}

extension AuthTokenModel: HashableObject {}

public struct AuthTokenView: View {
  @State private var model: AuthTokenModel
  public init(model: AuthTokenModel) {
    self.model = model
  }
  public var body: some View {
    WithPerceptionTracking {
      VStack {
        HStack {
          Spacer()
          Button {
            
          } label: {
            Image(systemName: "bookmark.circle")
              .resizable()
              .renderingMode(.template)
              .frame(width: 24, height: 24)
              .foregroundColor(ColorPalette.dark.accent)
          }
          .buttonStyle(PlainButtonStyle())
        }
        Color.white
          .cornerRadius(8, style: .continuous)
          .frame(width: 186, height: 186)
          .padding(.bottom, 20)
        Text("Log in to Telegram by QR Code")
          .font(.title)
        VStack(alignment: .leading, spacing: 16) {
          ForEach(model.tokenOptions) { tokenOption in
            ExportTokenOptionView(tokenOption: tokenOption)
          }
        }
        .padding(.top, 12)
        .padding(.bottom, 32)
        
        Button {
          withAnimation(.bouncy(duration: 0.15)) {
            model.phoneNumberLoginTapped()
          }
        } label: {
          Text("Log in by Phone Number")
            .font(.title3)
            .fontWeight(.medium)
            .foregroundColor(ColorPalette.dark.accent)
        }
        .buttonStyle(PlainButtonStyle())
        
        Spacer()
      }
    }
  }
}

#Preview {
  AuthTokenView(model: AuthTokenModel())
    .background(ColorPalette.dark.background)
}
