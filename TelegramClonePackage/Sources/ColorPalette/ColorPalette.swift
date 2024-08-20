import SwiftUI
import SwiftUIX

public struct ColorPalette {
  public let name: String
  public let basicAccent: Color
  public let background: Color
  public let text: Color
  public let grayText: Color
  public let link: Color
  public let accent: Color
  public let grayBackground: Color
  public let border: Color
  
  public init(name: String, basicAccent: Color, background: Color, text: Color, grayText: Color, link: Color, accent: Color, grayBackground: Color, border: Color) {
    self.name = name
    self.basicAccent = basicAccent
    self.background = background
    self.text = text
    self.grayText = grayText
    self.link = link
    self.accent = accent
    self.grayBackground = grayBackground
    self.border = border
  }
  
  public static let dark = ColorPalette(
    name: "dark",
    basicAccent: Color(hexadecimal6: 0x04afc8),
    background: Color(hexadecimal6: 0x292b36),
    text: Color(hexadecimal6: 0xe9e9e9),
    grayText: Color(hexadecimal6: 0x8699a3),
    link: Color(hexadecimal6: 0x04afc8),
    accent: Color(hexadecimal6: 0x2481cc),
    grayBackground: Color(hexadecimal6: 0x464a57),
    border: Color(hexadecimal6: 0x3d474f)
  )
}
