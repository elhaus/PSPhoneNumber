# PSPhoneNumber ☎️

[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PSPhoneNumber.svg)](https://www.powershellgallery.com/packages/PSPhoneNumber/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PSPhoneNumber.svg)](https://www.powershellgallery.com/packages/PSPhoneNumber/)
[![License](https://img.shields.io/badge/license-apache%202.0-blue.svg)](LICENSE)

**PSPhoneNumber** is a PowerShell module for parsing, formatting, and validating international phone numbers. 

It acts as a PowerShell wrapper around the [libphonenumber-csharp](https://github.com/twcclegg/libphonenumber-csharp) library (a port of Google's [libphonenumber library](https://github.com/google/libphonenumber)). Because it is compiled against `.NET Standard 2.0`, it runs flawlessly on Windows PowerShell 5.1, as well as PowerShell Core 7+ on Windows, macOS, and Linux.

## ✨ Features
* **Validate** phone numbers against real-world routing rules and number lengths.
* **Format** strings instantly into `E.164`, `International`, `National`, or `RFC3966` (tel: URI) standards.
* **Geolocate** numbers to their country and city/state using the offline geocoder.
* **Identify** carrier names and line types (Mobile, Fixed-Line, Toll-Free).
* **Cross-Platform** support across Windows, macOS, and Linux.

---

## 🚀 Installation

Install directly from the [PowerShell Gallery](https://www.powershellgallery.com/) (Recommended):

```powershell
Install-Module -Name PSPhoneNumber
```

To import the module into your current session:

```powershell
Import-Module PSPhoneNumber
```

---

## 📖 Quick Start

### 1. Validate a Phone Number

Clean up data by checking if a string is actually a valid phone number. You can provide a default region code (ISO 3166-1 alpha-2) for local numbers that lack a `+` prefix.

```powershell
# International format auto-detects the region
Test-PhoneNumber -Number "+44 20 7946 1234"
# Output: True

# Local format requires a fallback region
Test-PhoneNumber -Number "123-fake-number" -DefaultRegion "GB"
# Output: False
```

### 2. Format / Standardize Numbers

Convert messy user inputs into standardized formats like E.164 (perfect for APIs/SMS gateways) or RFC3966 (perfect for HTML clickable links).

```powershell
Convert-PhoneNumber -Number "+49 171-39200 00"
# Output: +49 171 3920000

Convert-PhoneNumber -Number "020 79461234" -DefaultRegion "GB" -Format E164
# Output: +442079461234
```

### 3. Get Phone Number Details

Extract rich metadata from a number, including its geolocation, timezone, and carrier. You can pipe numbers directly into this command!

```powershell
Get-PhoneNumberDetail -Number "+442079461234"
```

**Output:**

```text
IsValid                   : True
IsPossible                : True
Type                      : FIXED_LINE
InternationalFormat       : +44 20 7946 1234
NationalFormat            : 020 7946 1234
E164Format                : +442079461234
RFC3966Format             : tel:+44-20-7946-1234
CountryCode               : GB
NationalSignificantNumber : 2079461234
TimeZone                  : Europe/London
Carrier                   : 
Location                  : London
```

---

## 🛠️ Available Commands

| Cmdlet | Description |
| --- | --- |
| `Test-PhoneNumber` | Returns `$true` or `$false` if the provided string is a valid phone number. |
| `Format-PhoneNumber` | Rewrites a raw phone string into a clean target format (E164, National, etc.). |
| `Get-PhoneNumberDetail` | Returns a customized PowerShell object with location, carrier, and formatting metadata. |

---

## 🤖 Automated Upgrades (CI/CD)

This repository utilizes GitHub Actions to automatically stay in sync with the upstream C# library.
When `libphonenumber-csharp` releases an update, Dependabot detects it and triggers a helper workflow that:

1. Recompiles the C# DLLs for `.NET Standard 2.0`.
2. Bumps the `ModuleVersion` in the manifest.

## 🤝 Contributing

Pull requests are welcome! If you want to build the module locally:

1. Clone this repository.
2. Ensure you have the [.NET](https://dotnet.microsoft.com/download) installed.
3. Run `dotnet publish -c Release -f netstandard2.0` inside the `build/` directory.
4. Copy the compiled DLLs into `src/lib/`.

## 📜 License

This project is licensed under the [MIT License](https://www.google.com/search?q=LICENSE).

* Powered by [libphonenumber-csharp](https://github.com/twcclegg/libphonenumber-csharp) (Apache License 2.0).
* Originally based on Google's [libphonenumber](https://github.com/google/libphonenumber).
