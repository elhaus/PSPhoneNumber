<#
.SYNOPSIS
    Retrieves comprehensive metadata, formatting, and geographic details for a phone number.
.DESCRIPTION
    Parses a phone number string using Google's libphonenumber library and aggregates its
    underlying properties into a single PowerShell custom object.

    It fetches:
      - Validation checks (IsValid, IsPossible)
      - Line type classification (e.g., Mobile, Fixed-line, Toll-free)
      - Four standard formatting patterns (E.164, National, International, RFC3966)
      - Regional details (Country ISO code, National Significant Number)
      - Map data (Time Zones, Carrier name, and localized geographic description)
.PARAMETER Number
    The raw phone number string to analyze. This parameter accepts input from the pipeline.
.PARAMETER DefaultRegion
    The ISO 3166-1 alpha-2 two-letter country code (e.g., 'US', 'GB', 'DE') used as a fallback
    to parse local/national number formats that lack an international country dial code prefix (+).
.PARAMETER OutputLanguage
    Specifies the locale language for the geocoded 'Location' and 'Carrier' fields.
    Supported values are: 'English', 'French', 'German', 'Italian', 'Korean', and 'SimplifiedChinese'.
    Defaults to 'English'.
.OUTPUTS
    [PSCustomObject] containing parsed validation, formatting, regional, carrier, and timezone information.
.EXAMPLE
    Get-PhoneNumberDetail -Number "+442079461234"

    Validates and resolves a UK landline, returning its English location ("London"),
    timezones, and standard formatting variations.
.EXAMPLE
    "0171-39200 00", "+49 221-4710 000" | Get-PhoneNumberDetail -DefaultRegion "DE" -OutputLanguage "German"

    Processes German phone numbers via the pipeline, resolving localized German names
    for locations and mobile carriers.
#>

function Get-PhoneNumberDetail {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Number,

        [Parameter(Mandatory = $false)]
        [string]$DefaultRegion,

        [Parameter(Mandatory = $false)]
        [ValidateSet('English', 'French', 'German', 'Italian', 'Korean', 'SimplifiedChinese')]
        [string]$OutputLanguage = "English"
    )
    process {
        $util = [PhoneNumbers.PhoneNumberUtil]::GetInstance()
        $geocoder = [PhoneNumbers.PhoneNumberOfflineGeocoder]::GetInstance()
        $timeZonesMapper = [PhoneNumbers.PhoneNumberToTimeZonesMapper]::GetInstance();
        $carrierMapper = [PhoneNumbers.PhoneNumberToCarrierMapper]::GetInstance();
        $Language = [PhoneNumbers.Locale]::$OutputLanguage
        try {
            $region = if ([string]::IsNullOrWhiteSpace($DefaultRegion)) { $null } else { $DefaultRegion }
            $PhoneNumber = $util.Parse($Number, $region)

            return [PSCustomObject]@{
                IsValid = $util.IsValidNumber($PhoneNumber)
                IsPossible = $util.IsPossibleNumber($PhoneNumber)
                Type = [string] $util.GetNumberType($PhoneNumber)
                InternationalFormat = $util.Format($PhoneNumber, [PhoneNumbers.PhoneNumberFormat]::INTERNATIONAL)
                NationalFormat = $util.Format($PhoneNumber, [PhoneNumbers.PhoneNumberFormat]::NATIONAL)
                E164Format = $util.Format($PhoneNumber, [PhoneNumbers.PhoneNumberFormat]::E164)
                RFC3966Format = $util.Format($PhoneNumber, [PhoneNumbers.PhoneNumberFormat]::RFC3966)
                CountryCode = $util.GetRegionCodeForNumber($PhoneNumber)
                NationalSignificantNumber = $util.GetNationalSignificantNumber($PhoneNumber)
                TimeZone = $timeZonesMapper.GetTimeZonesForNumber($PhoneNumber) -join ","
                Carrier = $carrierMapper.GetNameForNumber($PhoneNumber, $Language)
                Location = $geocoder.GetDescriptionForNumber($PhoneNumber, $Language)
            }
        }
        catch {
            Write-Error "Failed to parse phone number: $_"
        }
    }
}