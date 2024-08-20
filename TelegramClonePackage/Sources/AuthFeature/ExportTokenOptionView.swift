//
//  File.swift
//  
//
//  Created by lambert on 2024/8/15.
//

import SwiftUI
import ColorPalette

public struct ExportTokenOption: Identifiable {
  public let option: String
  public let title: String
  public init(option: String, title: String) {
    self.option = option
    self.title = title
  }
  public var id: String {
    option
  }
  
  public static let tokenOptions: [ExportTokenOption] = [
    ExportTokenOption(option: "1", title: "Open Telegram on your phone"),
    ExportTokenOption(option: "2", title: "Go to Settings -> Devices -> Link Desktop Device"),
    ExportTokenOption(option: "3", title: "Point your phone at this screen to confirm login")
  ]
}

public struct ExportTokenOptionView: View {
  public let tokenOption: ExportTokenOption
  public init(tokenOption: ExportTokenOption) {
    self.tokenOption = tokenOption
  }
  public var body: some View {
    HStack(spacing: 10) {
      Circle()
        .foregroundColor(ColorPalette.dark.accent)
        .frame(width: 20, height: 20)
        .overlay {
          Text(tokenOption.option)
            .fontWeight(.medium)
        }
      Text(tokenOption.title)
        .font(.body)
        .fontWeight(.medium)
      Spacer()
    }
  }
}

#Preview {
  VStack(alignment: .leading) {
    ForEach(ExportTokenOption.tokenOptions) { tokenOption in
      ExportTokenOptionView(tokenOption: tokenOption)
    }
  }
}
