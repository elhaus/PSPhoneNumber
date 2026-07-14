<#
.SYNOPSIS
    Converts and standardizes a raw phone number string into a specified phone number format.
.DESCRIPTION
    Parses an input phone number string and rewrites it into one of four industry-standard
    formats (E.164, International, National, or RFC3966).

    This is highly useful for cleaning up user-submitted forms, preparing data for SMS gateways
    (which usually require E.164), or generating clickable HTML "tel:" links.
.PARAMETER Number
    The raw phone number string to convert. This parameter accepts input directly from the pipeline.
.PARAMETER DefaultRegion
    The ISO 3166-1 alpha-2 two-letter country code (e.g., 'US', 'GB', 'DE') used as a fallback
    to interpret local/national numbers that lack an international country dial code prefix (+).
.PARAMETER Format
    The target output format. Supported standards are:
      - 'E164': Clean, globally unique format with no spaces or symbols except a leading '+' (e.g., +12024561111).
      - 'INTERNATIONAL': Spaced format with country code, ideal for global readability (e.g., +1 202-456-1111).
      - 'NATIONAL': The standard format used when dialing the number from within its own country (e.g., (202) 456-1111).
      - 'RFC3966': Visual URI format designed for hyperlinks (e.g., tel:+1-202-456-1111).
    Defaults to 'INTERNATIONAL'.
.OUTPUTS
    System.String. The formatted phone number.
.EXAMPLE
    Convert-PhoneNumber -Number "+49 171-39200 00"

    Converts a phone number to the international format: "+49 171 3920000".
.EXAMPLE
    Convert-PhoneNumber -Number "02079461234" -DefaultRegion "GB" -Format E164

    Converts a local UK landline number to the standardized E.164 format: "+442079461234".
.EXAMPLE
    "0171-39200 00", "+49 221-4710 000" | Convert-PhoneNumber -DefaultRegion "DE" -Format RFC3966

    Pipes multiple US numbers through the command and outputs them as RFC3966 'tel:' URIs.
#>

function Convert-PhoneNumber {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Number,

        [Parameter(Mandatory = $false)]
        [string]$DefaultRegion,

        [ValidateSet('E164', 'INTERNATIONAL', 'NATIONAL', 'RFC3966')]
        [string]$Format = 'INTERNATIONAL'
    )
    process {
        $util = [PhoneNumbers.PhoneNumberUtil]::GetInstance()
        try {
            $region = if ([string]::IsNullOrWhiteSpace($DefaultRegion)) { $null } else { $DefaultRegion }
            $PhoneNumber = $util.Parse($Number, $region)
            $formatEnum = [PhoneNumbers.PhoneNumberFormat]::$Format

            return $util.Format($PhoneNumber, $formatEnum)
        }
        catch {
            Write-Error "Failed to convert phone number: $_"
        }
    }
}