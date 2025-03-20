function Get-Phonetics {
    [CmdletBinding()]

    param (
        # Word to output phonetics for
        # If more than one word is used, the words must be placed in quotes
        [Parameter(Mandatory = $true)]
        [String]$Word
    )
    
    # Assign the characters to a variable
    $characters = $Word.ToCharArray()

    # Declare the array for the phonetics
    $phonetics = @()

    # Loop through all characters in the provided word and add the associated phonetics for the word to $phonetics
    foreach ($char in $characters) {
        $letter = Switch ($char) {
            "a" {"alpha"}
            "b" {"bravo"}
            "c" {"charlie"}
            "d" {"delta"}
            "e" {"echo"}
            "f" {"foxtrot"}
            "g" {"golf"}
            "h" {"hotel"}
            "i" {"india"}
            "j" {"juliett"}
            "k" {"kilo"}
            "l" {"lima"}
            "m" {"mike"}
            "n" {"november"}
            "o" {"oscar"}
            "p" {"papa"}
            "q" {"quebec"}
            "r" {"romeo"}
            "s" {"sierra"}
            "t" {"tango"}
            "u" {"uniform"}
            "v" {"victor"}
            "w" {"whiskey"}
            "x" {"x-ray"}
            "y" {"yankee"}
            "z" {"zulu"}
            default {$char}
        }

        $phonetics += "$letter "
    }

    # Join the words together onto one readable line
    $endResult = $phonetics -join ""

    # Output the phonetics for the provided word
    Write-Output $Word.ToUpper()
    Write-Host $endResult -ForegroundColor Green
}