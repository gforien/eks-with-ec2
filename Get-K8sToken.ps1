# If script is dot-sourced (like this '. .\Get-K8sToken')
# -> Export the function Get-K8sToken
function Get-K8sToken {
    $a = -join (((48..57) + (97..122))*100 | Get-Random -Count 6 | % {[char]$_})
    $b = -join (((48..57) + (97..122))*100 | Get-Random -Count 16 | % {[char]$_})
    $c = "$a.$b"
    return $c
}

# If script is invoked from path (like this '.\Get-K8sToken')
# -> Return a token
$providerPath = (Resolve-Path -Path $MyInvocation.InvocationName).ProviderPath
If ($providerPath -eq $MyInvocation.MyCommand.Path) {
    Get-K8sToken
}
