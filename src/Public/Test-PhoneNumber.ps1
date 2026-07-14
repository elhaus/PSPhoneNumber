<#
.SYNOPSIS
    Validates whether a string represents a valid phone number.
.DESCRIPTION
    Uses the underlying libphonenumber library to parse and validate a phone number string.
    It checks both the structure and length of the number against known carrier rules for the specified region.

    The function handles parsing errors safely; if a string is completely malformed or missing a critical
    country prefix, it will suppress the exception and cleanly return $false, making it ideal for data filtering.
.PARAMETER Number
    The phone number string you want to validate. This parameter accepts input directly from the pipeline.
.PARAMETER DefaultRegion
    The ISO 3166-1 alpha-2 two-letter country code (e.g., 'US', 'GB', 'NL') used to evaluate the number
    if it is provided in a local/national format instead of full international E.164 format.
.OUTPUTS
    System.Boolean. Returns $true if the number is valid; otherwise $false.
.EXAMPLE
    Test-PhoneNumber -Number "+49 171-39200 00"

    Returns $true. The international prefix (+) allows the library to auto-detect the region.
.EXAMPLE
    Test-PhoneNumber -Number "020 7946 1234" -DefaultRegion "GB"

    Returns $true. The local UK format is successfully validated using the 'GB' fallback region.
.EXAMPLE
    "123-fake-number", "+491713920000" | Test-PhoneNumber

    Processes multiple numbers from the pipeline, returning $false and then $true.
#>
function Test-PhoneNumber {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Number,

        [Parameter(Mandatory = $false)]
        [string]$DefaultRegion
    )
    process {
        $util = [PhoneNumbers.PhoneNumberUtil]::GetInstance()

        try {
            $region = if ([string]::IsNullOrWhiteSpace($DefaultRegion)) { $null } else { $DefaultRegion }
            $parsedNumber = $util.Parse($Number, $region)
            return $util.IsValidNumber($parsedNumber)
        }
        catch {
            return $false
        }
    }
}