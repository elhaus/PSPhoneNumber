<#
    The phone numbers in this test should not be real phone numbers.
    Therefore fictitious telephone numbers are used: https://en.wikipedia.org/wiki/Fictitious_telephone_number
#>

BeforeAll {
    Import-Module "./PSPhoneNumber/PSPhoneNumber.psd1" -Force
}


Describe 'Convert-PhoneNumber' {
    It 'Formatting DE (0)152 28895456' {
        Convert-PhoneNumber -Number "(0)152 28895456" -DefaultRegion "DE" | Should-BeString "+49 1522 8895456"
    }
    It 'Formatting DE 040-66969 123' {
        Convert-PhoneNumber -Number "040-66969 123" -DefaultRegion "DE" | Should-BeString "+49 40 66969123"
    }
}

Describe 'Get-PhoneNumberDetail' {
    It 'Checking Details for DE (0)152 28895456' {
        $Details = Get-PhoneNumberDetail -Number "(0)152 28895456" -DefaultRegion "DE"
        $Details.InternationalFormat | Should-BeString "+49 1522 8895456"
        $Details.Carrier | Should-BeString "Vodafone"
        $Details.Location | Should-BeString "Germany"
        $Details.Type | Should-BeString "MOBILE"
    }
    It 'Checking Details for DE 040-66969 123' {
        $Details = Get-PhoneNumberDetail -Number "040-66969 123" -DefaultRegion "DE"
        $Details.InternationalFormat | Should-BeString "+49 40 66969123"
        $Details.Location | Should-BeString "Hamburg"
        $Details.Type | Should-BeString "FIXED_LINE"
    }
    It 'Checking Details for FR +33 6 39 98 12 34' {
        $Details = Get-PhoneNumberDetail -Number "+33 2 61 91 12 34" -DefaultRegion "FR" -OutputLanguage German
        $Details.InternationalFormat | Should-BeString "+33 2 61 91 12 34"
        $Details.Location | Should-BeString "Frankreich"
        $Details.TimeZone | Should-BeString "Europe/Paris"
        $Details.Type | Should-BeString "FIXED_LINE"
    }
    It 'Checking Details for SE 070-1740605' {
        $Details = Get-PhoneNumberDetail -Number "070-1740605" -DefaultRegion "SE"
        $Details.InternationalFormat | Should-BeString "+46 70 174 06 05"
        $Details.Location | Should-BeString "Sweden"
        $Details.TimeZone | Should-BeString "Europe/Stockholm"
        $Details.Type | Should-BeString "MOBILE"
    }
    It 'Checking Details for GB 020 7946 1234' {
        $Details = Get-PhoneNumberDetail -Number "020 7946 1234" -DefaultRegion "GB"
        $Details.InternationalFormat | Should-BeString "+44 20 7946 1234"
        $Details.Location | Should-BeString "London"
        $Details.TimeZone | Should-BeString "Europe/London"
        $Details.Type | Should-BeString "FIXED_LINE"
    }
}

Describe 'Test-PhoneNumber' {
    It 'Test DE (0)152 28895456' {
        Test-PhoneNumber -Number "(0)152 28895456" -DefaultRegion "DE" | Should-BeTrue
    }
    It 'Test DE 040-66969 123' {
        Test-PhoneNumber -Number "040-66969 123" -DefaultRegion "DE" | Should-BeTrue
    }
    It 'Test Invalid +5456545451515544' {
        Test-PhoneNumber -Number "+5456545451515544" -DefaultRegion "DE" | Should-BeFalse
    }
    It 'Test Invalid +31fgf6464w54' {
        Test-PhoneNumber -Number "+31fgf6464w54" -DefaultRegion "US" | Should-BeFalse
    }
}