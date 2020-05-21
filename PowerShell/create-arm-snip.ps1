# Get clipboard contents
$inputClip = Get-Clipboard
$snipFileName = '.\.vscode\arm-authoring.code-snippets'
$snipFile = Get-Content $snipFileName

# Set variable 
$newSnippet = @()

Add-Type -AssemblyName Microsoft.VisualBasic
$snipName = [Microsoft.VisualBasic.Interaction]::InputBox('Enter a name for this Snippet', 'ARM to Snip', "vnet")

# Add snippet header
$newSnippet += '"ARM-' + $snipName + '": {'
$newSnippet += '"prefix": "' + $snipName + '",'
$newSnippet += '"body": ['

# Loop through clipboard contents
For ($i = 0; $i -lt $inputClip.Length; $i ++) {

    # If a line with a " is found start parsing"
    If ($inputClip[$i].Contains('"')) {

        # Split line into parts with a " delimiter
        $inputLine = $inputClip[$i].Split('"')

        # Loop through all elements in the " split and escape the "
        for ($part = 1; $part -lt $inputLine.Count; $part ++) {
            $inputLine[$part] = '\"' + $inputLine[$part]
        }

        # Remove trailing whitespace
        $inputLine = $inputLine -join ''

        # If string contains a $ add an extra
        if ($inputLine.IndexOf('$') -ge 0) { 
            $inputLine = $inputLine.Insert($inputLine.IndexOf('$'), '$')
        }
        
        # Add new line to global variable
        $newSnippet += '"' + $inputLine + '",'
    }

    else {
        # If there was no " add one at the begin and end of the line
        $newSnippet += '"'+ $inputClip[$i] + '",'    
    }

}

# Add snippet closing
$newSnippet += '],'
$newSnippet += '"description": ""'
$newSnippet += '}'
$newSnippet += '}'

# Add comma to end of previous object to support adding of new snippet
$snipFile[$snipFile.Length-2] = '},'
$snipFile[$snipFile.Length-1] = $newSnippet

# Add new snippet
Set-Content -Path $snipFileName -Value $snipFile