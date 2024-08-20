//
//  File.swift
//
//
//  Created by lambert on 2024/8/15.
//

import ColorPalette
import CountryProvider
import Dependencies
import Foundation
import IssueReporting
import Perception
import SwiftNavigation
import SwiftUI
import SwiftUIX
import UIComponents

@MainActor
@Perceptible
public final class AuthPhoneNumberModel {
  var onLogInByQrCodeTapped: () -> Void = unimplemented("onLogInByQrCodeTapped")
  var onNextTapped: () -> Void = unimplemented("onNextTapped")

  var showCountrySelector = false
  var selectedCountry: Country?
  var countries: [Country] = []
  var isNextAvailable = false
  var showNextAlert = false

  var codeText: String = "+"
  var phoneNumber: String = ""
  
  var readyValue: String {
    codeText + phoneNumber.trimmingCharacters(in: .whitespaces)
  }

  var focus: Field?
//  var placeholder = AttributedString(string: "------", attributes: [.font: NSFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: ColorPalette.dark.grayText])
  var placeholder: AttributedString = {
    var attributedString = AttributedString("")
    attributedString.foregroundColor = ColorPalette.dark.grayText
    attributedString.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
    return attributedString
  }()

  @PerceptionIgnored
  @Dependency(\.countryProvider) var countryProvider

  enum Field: Hashable {
    case code
    case phoneNumber
  }

  func loadCountryItems() {
    if countries.isEmpty {
      countries = allCountryInfos
    }
    showCountrySelector = true
  }

  func logInByQrCodeButtonTapped() {
    onLogInByQrCodeTapped()
  }

  func didSelectCountry(_ country: Country?, updateCodeText: Bool = true) {
    selectedCountry = country
    showCountrySelector = false
    if updateCodeText {
      if let selectedCountryCode = selectedCountry?.countryCodes.first?.code {
        codeText = "+\(selectedCountryCode)"
      } else {
        codeText = "+"
      }
    }
    updatePlaceholder()
  }

  func updateCodeText(_ updateCodeText: String) {
    guard updateCodeText != codeText else {
      return
    }
    codeText = updateCodeText
    let code = codeText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    let dec = code.prefix(4)
    if code.count > 4 {
      let list = code.map { String($0) }
      let reduced = list.reduce([]) { current, value -> [String] in
        var current = current
        current.append((current.last ?? "") + value)
        return current
      }

      var found = false
      for _code in reduced {
        let rest = String(code[String(_code).endIndex...])
        if let item = countryProvider.itemByCodeNumber(codeNumber: _code, prefix: String(rest.prefix(1))) {
          codeText = "+" + String(_code)
          didSelectCountry(item, updateCodeText: false)

          let text = rest + phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
          let formated = String(countryProvider.formatNumber(number: text, country: item).prefix(17))
          phoneNumber = formated
          focus = .phoneNumber
          found = true

          // MARK: - TODO: update Log in by QR Code Button

//          self.updatePhoneNumber?(formated)
          break
        }
      }

      if !found {
        didSelectCountry(nil, updateCodeText: false)
      }
    } else {
      codeText = "+" + String(dec)
      let item = countryProvider.itemByCodeNumber(codeNumber: String(dec), prefix: nil)
      let shouldSwitch = countryProvider.itemByCodeNumberCheckAll(codeNumber: String(dec), checkAll: true).count == 1
      didSelectCountry(item, updateCodeText: false)

      if shouldSwitch {
        focus = .phoneNumber
      }
    }
    updatePlaceholder()
  }

  func updatePhoneNumber(_ updatePhoneNumber: String) {
    guard phoneNumber.trimmingCharacters(in: CharacterSet.whitespaces) != updatePhoneNumber else {
      return
    }
    if let selectedCountry {
      let current = updatePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

      // MARK: - TODO: Dont check prefix now

//      let dec = codeText.prefix(4)
//      let updated = countryProvider.itemByCodeNumber(codeNumber: String(dec), prefix: String(current.prefix(1)))
//      if selectedCountry != updated {
//        didSelectCountry(updated, updateCodeText: true)
//      }
      let formatted = countryProvider.formatNumber(number: current, country: selectedCountry).prefix(17)
      phoneNumber = String(formatted)
    } else {
      let current = "+" + phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
      phoneNumber = ""
      codeText = current
      focus = .code
    }
    isNextAvailable = !phoneNumber.isEmpty && !codeText.isEmpty
    updatePlaceholder()
  }

  func updatePlaceholder() {
    var text = phoneNumber.isEmpty ? "phone number" : ""
    if let selectedCountry {
      var pattern: String?
      if phoneNumber.isEmpty {
        pattern = selectedCountry.countryCodes.first?.patterns.first(where: { value in
          value.trimmingCharacters(in: CharacterSet(charactersIn: "0987654321")).count == value.count
        })
      } else {
        pattern = selectedCountry.countryCodes.first?.patterns.first(where: { value in
          value.first == phoneNumber.first
        })
      }
      if pattern == nil {
        pattern = selectedCountry.countryCodes.first?.patterns.last
      }
      if let pattern {
        text = String(pattern.replacingOccurrences(of: "X", with: "-"))
      }
    }
    var attributedPlaceholder = AttributedString(text)
    attributedPlaceholder.foregroundColor = ColorPalette.dark.grayText
    attributedPlaceholder.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
    if !phoneNumber.isEmpty {
      let range = attributedPlaceholder.range(of: String(text.prefix(min(phoneNumber.count, text.count))))
      if let range = range {
        attributedPlaceholder[range].foregroundColor = .clear
      }
    }
    placeholder = attributedPlaceholder
//    let number = numberText.stringValue
//    var text: String = number.isEmpty ? strings().loginPhoneFieldPlaceholder : ""
//    if let item = selected {
//      var pattern: String?
//      if number.isEmpty {
//        pattern = item.countryCodes.first?.patterns.first(where: { value in
//          return value.trimmingCharacters(in: CharacterSet(charactersIn: "0987654321")).count == value.count
//        })
//      } else {
//        pattern = item.countryCodes.first?.patterns.first(where: { value in
//          return value.first == number.first
//        })
//      }
//      if pattern == nil {
//        pattern = item.countryCodes.first?.patterns.last
//      }
//      if let pattern = pattern {
//        text = String(pattern.replacingOccurrences(of: "X", with: "-"))
//      }
//    }
//    let attr = NSMutableAttributedString()
//    _ = attr.append(string: text, color: theme.colors.grayText, font: .code(.title))
//    if !number.isEmpty {
//      attr.addAttribute(.foregroundColor, value: NSColor.clear, range: NSMakeRange(0, min(number.length, text.length)))
//    }
//    let layout = TextViewLayout(attr)
//    layout.measure(width: .greatestFiniteMagnitude)
//    placeholder.update(layout)
  }
  
  func nextButtonTapped() {
    showNextAlert = true
    onNextTapped()
  }
}

extension Country {
  var fullName: String {
    if let code = countryCodes.first {
      @Dependency(\.countryProvider) var countryProvider
      var countryFlag = countryProvider.emojiFlagForISOCountryCode(countryCode: id)
      countryFlag.append(" ")
      countryFlag.append(name)
      countryFlag.append(" +\(code.code)")
      return countryFlag
    }
    return name
  }
}

extension AuthPhoneNumberModel: HashableObject {}

public struct AuthPhoneNumberView: View {
  @FocusState var focus: AuthPhoneNumberModel.Field?
  @State private var model: AuthPhoneNumberModel
  public init(model: AuthPhoneNumberModel) {
    self.model = model
  }

  public var body: some View {
    WithPerceptionTracking {
      VStack(spacing: 20) {
        headerView
        phoneInput
        bottom
        Spacer()
      }
      .padding()
    }
  }

  @MainActor
  @ViewBuilder
  private var headerView: some View {
    Image(systemName: "paperplane.circle.fill")
      .resizable()
      .renderingMode(.template)
      .foregroundColor(ColorPalette.dark.accent)
      .frame(width: 140, height: 140)
    Text("Telegram")
      .font(.system(size: 22, weight: .medium))
      .foregroundColor(ColorPalette.dark.text)
      .padding(.bottom, 10)
    Text("Please confirm your country code and enter your phone number.")
      .multilineTextAlignment(.center)
  }

  @MainActor
  @ViewBuilder
  private var phoneInput: some View {
    VStack(alignment: .leading) {
      Button {
        model.loadCountryItems()
      } label: {
        Text(model.selectedCountry?.fullName ?? "-----")
          .font(.system(size: 15))
      }
      .padding(.leading, 10)
      .padding(.top, 12)
      .buttonStyle(PlainButtonStyle())
      .popover(isPresented: $model.showCountrySelector) {
        ScrollView {
          VStack(alignment: .leading) {
            ForEach(model.countries, id: \.fullName) { country in
              Button {
                model.didSelectCountry(country)
              } label: {
                Text(country.fullName)
              }
              .buttonStyle(PlainButtonStyle())
            }
          }
          .padding()
        }
        .frame(maxHeight: 600)
        .fixedSize()
      }
      HStack {
        TextField(
          "",
          text: Binding(
            get: { model.codeText },
            set: { codeText in model.updateCodeText(codeText) }
          )
        )
        .fixedSize()
        .frame(height: 18)
        .padding(10)
        .focused($focus, equals: .code)
        ZStack(alignment: .leadingFirstTextBaseline) {
          Text(model.placeholder)

          TextField(
            "",
            text: Binding(
              get: { model.phoneNumber },
              set: { updatedInput in model.updatePhoneNumber(updatedInput) }
            )
          )
          .textFieldStyle(PlainTextFieldStyle())
          .focused($focus, equals: .phoneNumber)
        }
        .fixedSize()
        .frame(height: 18)
        Spacer()
      }
      .textFieldStyle(PlainTextFieldStyle())
    }
    .background(ColorPalette.dark.grayBackground)
    .cornerRadius(10, style: .continuous)
    .bind($model.focus, to: $focus)
  }

  @MainActor
  @ViewBuilder
  private var bottom: some View {
    Group {
      if model.isNextAvailable {
        Text("Next")
          .font(.system(size: 15, weight: .medium))
          .padding()
          .padding()
          .background(ColorPalette.dark.accent)
          .frame(height: 36)
          .clipShape(Capsule())
          .pressableStyle {
            model.nextButtonTapped()
          }
      } else {
        Button {
          withAnimation(Animation.bouncy(duration: 0.15)) {
            model.logInByQrCodeButtonTapped()
          }
        } label: {
          Text("Log in by QR Code")
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(ColorPalette.dark.accent)
        }
        .buttonStyle(PlainButtonStyle())
      }
    }
    .padding(.top, 20)
  }
}

#Preview {
  AuthPhoneNumberView(model: AuthPhoneNumberModel())
    .frame(width: 380, height: 500)
}
