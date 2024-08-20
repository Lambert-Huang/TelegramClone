
import Dependencies
import DependenciesMacros
import Foundation

public struct CountryItem {
  public let shortName: String
  public let fullName: String
  public let smallName: String
  public let code: Int
  public init(shortName: String, fullName: String, smallName: String, code: Int) {
    self.shortName = shortName
    self.fullName = fullName
    self.smallName = smallName
    self.code = code
  }
}

public struct StringCodingKey: CodingKey, ExpressibleByStringLiteral {
  public var stringValue: String

  public init?(stringValue: String) {
    self.stringValue = stringValue
  }

  public init(_ stringValue: String) {
    self.stringValue = stringValue
  }

  public init(stringLiteral: String) {
    self.stringValue = stringLiteral
  }

  public var intValue: Int? {
    return nil
  }

  public init?(intValue: Int) {
    return nil
  }
}

public struct Country: Codable, Equatable {
  public static func == (lhs: Country, rhs: Country) -> Bool {
    return lhs.id == rhs.id && lhs.name == rhs.name && lhs.localizedName == rhs.localizedName && lhs.countryCodes == rhs.countryCodes && lhs.hidden == rhs.hidden
  }

  public struct CountryCode: Codable, Equatable {
    public let code: String
    public let prefixes: [String]
    public let patterns: [String]

    public init(code: String, prefixes: [String], patterns: [String]) {
      self.code = code
      self.prefixes = prefixes
      self.patterns = patterns
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: StringCodingKey.self)

      self.code = try container.decode(String.self, forKey: "c")
      self.prefixes = try container.decode([String].self, forKey: "pfx")
      self.patterns = try container.decode([String].self, forKey: "ptrn")
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: StringCodingKey.self)

      try container.encode(self.code, forKey: "c")
      try container.encode(self.prefixes, forKey: "pfx")
      try container.encode(self.patterns, forKey: "ptrn")
    }
  }

  public let id: String
  public let name: String
  public let localizedName: String?
  public let countryCodes: [CountryCode]
  public let hidden: Bool

  public init(id: String, name: String, localizedName: String?, countryCodes: [CountryCode], hidden: Bool) {
    self.id = id
    self.name = name
    self.localizedName = localizedName
    self.countryCodes = countryCodes
    self.hidden = hidden
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: StringCodingKey.self)

    self.id = try container.decode(String.self, forKey: "c")
    self.name = try container.decode(String.self, forKey: "n")
    self.localizedName = try container.decodeIfPresent(String.self, forKey: "ln")
    self.countryCodes = try container.decode([CountryCode].self, forKey: "cc")
    self.hidden = try container.decode(Bool.self, forKey: "h")
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: StringCodingKey.self)

    try container.encode(self.id, forKey: "c")
    try container.encode(self.name, forKey: "n")
    try container.encodeIfPresent(self.localizedName, forKey: "ln")
    try container.encode(self.countryCodes, forKey: "cc")
    try container.encode(self.hidden, forKey: "h")
  }
}

@DependencyClient
public struct CountryProvider: Sendable {
  public var itemByCodeNumber: @Sendable (_ codeNumber: String, _ prefix: String?) -> Country? = { _, _ in nil }
  public var itemByCodeNumberCheckAll: @Sendable (_ codeNumber: String, _ checkAll: Bool) -> [Country] = { _, _ in [] }
  public var itemBySmallCountryName: @Sendable (_ smallCountryName: String) -> Country? = { _ in nil }
  public var itemByFullCountryName: @Sendable (_ fullCountryName: String) -> Country? = { _ in nil }
  public var itemByShortCountryName: @Sendable (_ shortCountryName: String) -> Country? = { _ in nil }
  public var emojiFlagForISOCountryCode: @Sendable (_ countryCode: String) -> String = { _ in "" }
  public var formatNumber: @Sendable (_ number: String, _ country: Country) -> String = { _, _ in "" }
}

public let allCountryInfos: [Country] = {
  guard let filePath = Bundle.module.path(forResource: "PhoneCountries", ofType: "txt") else {
    return []
  }
  guard let stringData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
    return []
  }
  guard let data = String(data: stringData, encoding: .utf8) else {
    return []
  }
  let delimiter = ";"
  // 使用 CharacterSet.newlines 来匹配所有类型的换行符
  let newlineCharacterSet = CharacterSet.newlines
  
  var result: [Country] = []
  var countriesByPrefix: [String: (Country, Country.CountryCode)] = [:]
  
  let lines = data.components(separatedBy: newlineCharacterSet)
  let locale = Locale(identifier: "en-US")
  
  for line in lines where !line.isEmpty {
    let components = line.components(separatedBy: delimiter)
    guard components.count >= 3 else { continue }
    
    let countryCode = components[0]
    let countryId = components[1]
    let pattern = components.count > 3 ? components[2] : ""
    
    let countryName = locale.localizedString(forIdentifier: countryId) ?? ""
    if let _ = Int(countryCode) {
      let code = Country.CountryCode(code: countryCode, prefixes: [], patterns: !pattern.isEmpty ? [pattern] : [])
      let country = Country(id: countryId, name: countryName, localizedName: nil, countryCodes: [code], hidden: false)
      result.append(country)
      countriesByPrefix["\(code.code)"] = (country, code)
    }
  }
  return result
//  let delimiter = ";"
//  let endOfLine = "\n"
//
//  var result: [Country] = []
//  var countriesByPrefix: [String: (Country, Country.CountryCode)] = [:]
//
//  var currentLocation = data.startIndex
//
//  let locale = Locale(identifier: "en-US")
//
//  while true {
//    guard let codeRange = data.range(of: delimiter, options: [], range: currentLocation ..< data.endIndex) else {
//      break
//    }
//
//    let countryCode = String(data[currentLocation ..< codeRange.lowerBound])
//
//    guard let idRange = data.range(of: delimiter, options: [], range: codeRange.upperBound ..< data.endIndex) else {
//      break
//    }
//
//    let countryId = String(data[codeRange.upperBound ..< idRange.lowerBound])
//
//    guard let patternRange = data.range(of: delimiter, options: [], range: idRange.upperBound ..< data.endIndex) else {
//      break
//    }
//
//    let pattern = String(data[idRange.upperBound ..< patternRange.lowerBound])
//
//    let maybeNameRange = data.range(of: endOfLine, options: [], range: patternRange.upperBound ..< data.endIndex)
//
//    let countryName = locale.localizedString(forIdentifier: countryId) ?? ""
//    if let _ = Int(countryCode) {
//      let code = Country.CountryCode(code: countryCode, prefixes: [], patterns: !pattern.isEmpty ? [pattern] : [])
//      let country = Country(id: countryId, name: countryName, localizedName: nil, countryCodes: [code], hidden: false)
//      result.append(country)
//      countriesByPrefix["\(code.code)"] = (country, code)
//    }
//
//    if let maybeNameRange = maybeNameRange {
//      currentLocation = maybeNameRange.upperBound
//    } else {
//      break
//    }
//  }
//  return result
}()

public let allCountryItems: [CountryItem] = {
  var items: [CountryItem] = []
  if let resource = Bundle.module.path(forResource: "PhoneCountries", ofType: "txt"),
     let content = try? String(contentsOfFile: resource)
  {
    let list = content.components(separatedBy: .newlines)
    for country in list {
      let parameters = country.components(separatedBy: ";")
      if parameters.count == 3 {
        let fullName = "\(parameters[2]) +\(parameters[0])"
        let item = CountryItem(shortName: parameters[2], fullName: fullName, smallName: parameters[1], code: Int(parameters[0])!)
        items.append(item)
      }
    }
  }
  return items
}()

public let coded: [Int: CountryItem] = {
  var coded: [Int: CountryItem] = [:]
  for country in allCountryItems {
    coded[country.code] = country
  }
  return coded
}()

public let smalled: [String: CountryItem] = {
  var smalled: [String: CountryItem] = [:]
  for country in allCountryItems {
    smalled[country.smallName] = country
  }
  return smalled
}()

public let fulled: [String: CountryItem] = {
  var fulled: [String: CountryItem] = [:]
  for country in allCountryItems {
    fulled[country.fullName] = country
  }
  return fulled
}()

public let shorted: [String: CountryItem] = {
  var shorted: [String: CountryItem] = [:]
  for country in allCountryItems {
    shorted[country.shortName] = country
  }
  return shorted
}()

extension CountryProvider: DependencyKey {
  public static var liveValue = CountryProvider(
    itemByCodeNumber: { codeNumber, prefix in
      if codeNumber == "999" {
        return Country(id: "TG", name: "Test", localizedName: "Test", countryCodes: [Country.CountryCode(code: "999", prefixes: [], patterns: ["XXXX X XX"])], hidden: false)
      }
      let firstTrip = allCountryInfos.first(where: { value in
        for code in value.countryCodes {
          if code.code == codeNumber {
            if let prefix = prefix {
              return code.prefixes.contains(prefix)
            }
            return true
          }
        }
        return false
      })
      if firstTrip == nil {
        return allCountryInfos.first(where: { value in
          for code in value.countryCodes {
            if code.code == codeNumber, code.prefixes.isEmpty {
              return true
            }
          }
          return false
        })
      }
      return firstTrip
    },
    itemByCodeNumberCheckAll: { codeNumber, checkAll in
      var countries = allCountryInfos
      countries.append(Country(id: "TG", name: "Test", localizedName: "Test", countryCodes: [Country.CountryCode(code: "999", prefixes: [], patterns: ["XXXX X XX"])], hidden: false))
      return countries.filter { country in
        for code in country.countryCodes {
          if code.code == codeNumber {
            return true
          } else if checkAll {
            return code.code.hasPrefix(codeNumber)
          }
        }
        return false
      }
    },
    itemBySmallCountryName: { smallName in
      allCountryInfos.first(where: { $0.id == smallName })
    },
    itemByFullCountryName: { fullName in
      nil
    },
    itemByShortCountryName: { shortName in
      nil
    },
    emojiFlagForISOCountryCode: { countryCode in
      if countryCode == "FT" {
        return "🏴‍☠️"
      }

      if countryCode.count != 2 {
        return ""
      }

      if countryCode == "TG" {
        return "🛰️"
      }

      if countryCode == "XG" {
        return "🛰️"
      } else if countryCode == "XV" {
        return "🌍"
      }

      if ["YL"].contains(countryCode) {
        return "🌍"
      }

      let base: UInt32 = 127397
      var s = ""
      for v in countryCode.unicodeScalars {
        s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
      }
      return String(s)
    },
    formatNumber: { number, country in
      var formatted = ""

      var pattern: String?
      if number.isEmpty {
        pattern = country.countryCodes.first?.patterns.first(where: { value in
          value.trimmingCharacters(in: CharacterSet(charactersIn: "0987654321")).count == value.count
        })
      } else {
        pattern = country.countryCodes.first?.patterns.first(where: { value in
          value.first == number.first
        })
      }
      if pattern == nil {
        pattern = country.countryCodes.first?.patterns.last
      }
      
      guard let pattern = pattern else {
        return number
      }

      let numberChars = Array(number)
      let patternChars = Array(pattern)

      var patternIndex = 0
      for char in numberChars {
        if patternIndex < patternChars.count {
          let pattern = patternChars[patternIndex]
          if pattern == "X" {
            formatted.append(char)
          } else {
            formatted.append("\(pattern)")
            if pattern == " " {
              formatted.append(char)
              patternIndex += 1
            }
          }
          patternIndex += 1
        } else {
          formatted.append(char)
        }
      }
      if patternIndex < patternChars.count, patternChars[patternIndex] == " " {
        formatted.append(" ")
      }
      
      return formatted
    }
  )
}

public extension DependencyValues {
  var countryProvider: CountryProvider {
    get { self[CountryProvider.self] }
    set { self[CountryProvider.self] = newValue }
  }
}
