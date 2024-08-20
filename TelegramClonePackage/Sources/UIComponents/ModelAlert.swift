//
//  File.swift
//
//
//  Created by lambert on 2024/8/19.
//

import ColorPalette
import SwiftUI
import SwiftUINavigation

public struct ModalAlertData: Identifiable, Hashable {
  public static func == (lhs: ModalAlertData, rhs: ModalAlertData) -> Bool {
    lhs.title == rhs.title &&
      lhs.message == rhs.message &&
      lhs.secondaryButtonTitle == rhs.secondaryButtonTitle &&
      lhs.primaryButtonTitle == rhs.primaryButtonTitle &&
      lhs.secondaryBackgroundColorHex == rhs.secondaryBackgroundColorHex &&
      lhs.primaryBackgroundColorHex == rhs.primaryBackgroundColorHex
  }
  public let id: UUID
  public let title: String?
  public let message: String
  public let secondaryButtonTitle: String
  public let primaryButtonTitle: String
  public let secondaryBackgroundColorHex: Int
  public let primaryBackgroundColorHex: Int
  public let secondaryButtonAction: () -> Void
  public let primaryButtonAction: () -> Void
  public init(
    id: UUID = UUID(),
    title: String?,
    message: String,
    secondaryButtonTitle: String,
    primaryButtonTitle: String,
    secondaryBackgroundColorHex: Int,
    primaryBackgroundColorHex: Int,
    secondaryButtonAction: @escaping () -> Void,
    primaryButtonAction: @escaping () -> Void
  ) {
    self.id = id
    self.title = title
    self.message = message
    self.secondaryButtonTitle = secondaryButtonTitle
    self.primaryButtonTitle = primaryButtonTitle
    self.secondaryBackgroundColorHex = secondaryBackgroundColorHex
    self.primaryBackgroundColorHex = primaryBackgroundColorHex
    self.secondaryButtonAction = secondaryButtonAction
    self.primaryButtonAction = primaryButtonAction
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(title)
    hasher.combine(message)
    hasher.combine(secondaryButtonTitle)
    hasher.combine(primaryButtonTitle)
    hasher.combine(secondaryBackgroundColorHex)
    hasher.combine(primaryBackgroundColorHex)
  }
}

private struct DismissActionKey: EnvironmentKey {
  static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
  var dismissModalAlert: () -> Void {
    get { self[DismissActionKey.self] }
    set { self[DismissActionKey.self] = newValue }
  }
}

public struct ModalAlertModifier<Item: Identifiable & Equatable, AlertContent: View>: ViewModifier {
  @Binding var item: Item?
  let onDismiss: (() -> Void)?
  let alertContent: (Binding<Item>) -> AlertContent
  public init(
    item: Binding<Item?>,
    onDismiss: (() -> Void)?,
    alertContent: @escaping (Binding<Item>) -> AlertContent
  ) {
    self._item = item
    self.alertContent = alertContent
    self.onDismiss = onDismiss
  }
  
  @State private var contentScale: CGFloat = 0.5
  @State private var backgroundOpacity: CGFloat = 0
  @State private var contentOpacity: CGFloat = 0
  public func body(content: Content) -> some View {
    ZStack {
      content
      Group {
        if let item {
          Color.black.opacity(backgroundOpacity)
            .animation(.easeInOut(duration: 0.15), value: backgroundOpacity)
            .onTapGesture {
              self.dimissWithAnimation()
            }
          
          self.alertContent(Binding(unwrapping: self._item, default: item))
            .environment(\.dismissModalAlert, dimissWithAnimation)
            .scaleEffect(contentScale)
            .opacity(contentOpacity)
            .animation(.spring(response: 0.15, dampingFraction: 0.6, blendDuration: 0), value: self.contentScale)
            .animation(.easeInOut(duration: 0.15), value: self.contentOpacity)
        }
      }
    }
    .onChange(of: self.item) { newValue in
      if let _ = newValue {
        contentScale = 1.0
        contentOpacity = 1.0
        backgroundOpacity = 0.5
      }
    }
  }
  
  func dimissWithAnimation() {
    withAnimation {
      contentScale = 0.5
      contentOpacity = 0.0
      backgroundOpacity = 0.0
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
      onDismiss?()
      self.item = nil
    }
  }
}

public struct ModalAlertView: View {
  @Binding var modalAlertData: ModalAlertData
  @Environment(\.dismissModalAlert) var dismiss
  public init(modalAlertData: Binding<ModalAlertData>) {
    self._modalAlertData = modalAlertData
  }
  public var body: some View {
    VStack(spacing: 20) {
      if let title = modalAlertData.title {
        Text(title)
          .font(.system(size: 14, weight: .medium))
          .lineLimit(2)
          .foregroundColor(ColorPalette.dark.text)
      }
      Text(modalAlertData.message)
        .foregroundColor(ColorPalette.dark.grayText)
        .font(.system(size: 14))
        .lineLimit(1)
      
      HStack(spacing: 20) {
        Text(modalAlertData.secondaryButtonTitle)
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(ColorPalette.dark.text)
          .frame(maxWidth: .infinity)
          .frame(height: 40)
          .background(Color(hexadecimal6: modalAlertData.secondaryBackgroundColorHex).opacity(0.5))
          .buttonStyle(PlainButtonStyle())
          .border(ColorPalette.dark.border, width: 0.5, cornerRadius: 10, style: .continuous)
          .cornerRadius(8, style: .continuous)
          .pressableStyle {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
              modalAlertData.secondaryButtonAction()
            }
          }
        
        Text(modalAlertData.primaryButtonTitle)
          .font(.system(size: 14, weight: .medium))
          .foregroundColor(ColorPalette.dark.text)
          .frame(maxWidth: .infinity)
          .frame(height: 40)
          .background(Color(hexadecimal6: modalAlertData.primaryBackgroundColorHex))
          .buttonStyle(PlainButtonStyle())
          .border(ColorPalette.dark.border, width: 0.5, cornerRadius: 10, style: .continuous)
          .cornerRadius(8, style: .continuous)
          .pressableStyle {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
              modalAlertData.primaryButtonAction()
            }
          }
      }
    }
    .padding()
    .background(ColorPalette.dark.grayBackground)
    .frame(maxWidth: 280)
    .clipShape(
      RoundedRectangle(cornerRadius: 10, style: .continuous)
    )
    .border(ColorPalette.dark.border, width: 0.5, cornerRadius: 10, style: .continuous)
    .shadow(color: .black.opacity(0.3), radius: 20, x: 0.0, y: 0.0)
  }
}

//public struct ModalAlert: ViewModifier {
//  @Binding var modelAlertData: ModalAlertData?
//  @State private var scale: CGFloat = 0.5
//  @State private var backgroundOpacity: CGFloat = 0
//  public init(
//    modelAlertData: Binding<ModalAlertData?>
//  ) {
//    self._modelAlertData = modelAlertData
//  }
//
//  public func body(content: Content) -> some View {
//    content
//      .overlay {
//        if let modelAlertData {
//          ZStack {
//            Color.black
//              .opacity(self.backgroundOpacity)
//              .ignoresSafeArea()
//              .animation(.easeInOut(duration: 0.15), value: self.backgroundOpacity)
//              .onTapGesture {
//                self.modelAlertData = nil
//              }
//              .onAppear {
//                self.backgroundOpacity = 0.6
//              }
//              .onDisappear {
//                self.backgroundOpacity = 0.0
//              }
//            VStack(spacing: 20) {
//              if let title = modelAlertData.title {
//                Text(title)
//                  .font(.system(size: 14, weight: .medium))
//                  .lineLimit(2)
//                  .foregroundColor(ColorPalette.dark.text)
//              }
//              Text(modelAlertData.message)
//                .foregroundColor(ColorPalette.dark.grayText)
//                .font(.system(size: 14))
//                .lineLimit(1)
//              
//              HStack(spacing: 20) {
//                Text(modelAlertData.secondaryButtonTitle)
//                  .font(.system(size: 14, weight: .medium))
//                  .foregroundColor(ColorPalette.dark.text)
//                  .frame(maxWidth: .infinity)
//                  .frame(height: 40)
//                  .background(Color(hexadecimal6: modelAlertData.secondaryBackgroundColorHex).opacity(0.5))
//                  .buttonStyle(PlainButtonStyle())
//                  .border(ColorPalette.dark.border, width: 0.5, cornerRadius: 10, style: .continuous)
//                  .cornerRadius(8, style: .continuous)
//                  .pressableStyle {
//                    modelAlertData.secondaryButtonAction()
//                    self.modelAlertData = nil
//                  }
//                
//                Text(modelAlertData.primaryButtonTitle)
//                  .font(.system(size: 14, weight: .medium))
//                  .foregroundColor(ColorPalette.dark.text)
//                  .frame(maxWidth: .infinity)
//                  .frame(height: 40)
//                  .background(Color(hexadecimal6: modelAlertData.primaryBackgroundColorHex))
//                  .buttonStyle(PlainButtonStyle())
//                  .border(ColorPalette.dark.border, width: 0.5, cornerRadius: 10, style: .continuous)
//                  .cornerRadius(8, style: .continuous)
//                  .pressableStyle {
//                    modelAlertData.primaryButtonAction()
//                    self.modelAlertData = nil
//                  }
//              }
//            }
//            .padding()
//            .background(ColorPalette.dark.grayBackground)
//            .frame(maxWidth: 280)
//            .clipShape(
//              RoundedRectangle(cornerRadius: 10, style: .continuous)
//            )
//            .border(ColorPalette.dark.border, width: 0.5, cornerRadius: 10, style: .continuous)
//            .shadow(color: .black.opacity(0.3), radius: 20, x: 0.0, y: 0.0)
//            .scaleEffect(self.scale)
//            .animation(.spring(response: 0.15, dampingFraction: 0.6, blendDuration: 0), value: self.scale)
//            .onAppear {
//              self.scale = 1.0
//            }
//            .onDisappear {
//              self.scale = 0.5
//            }
//          }
//        }
//      }
//  }
//}

extension View {
  public func modalAlert<Item: Identifiable & Equatable, AlertContent: View>(
    item: Binding<Item?>,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder alertContent: @escaping (Binding<Item>) -> AlertContent
  ) -> some View {
    self.modifier(ModalAlertModifier(item: item, onDismiss: onDismiss, alertContent: alertContent))
  }
}

//public extension View {
//  func modalAlert(alertData: Binding<ModalAlertData?>) -> some View {
//    modifier(ModalAlert(modelAlertData: alertData))
//  }
//}
