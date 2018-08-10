<#
===========================================================================
 AUTHOR  : Andrew Shen  
 DATE    : 2018-03-08 
 VERSION : 1.1
===========================================================================

.SYNOPSIS
    Sets the Remote Desktop Services Profile and Sessions settings

.DESCRIPTION
    Sets the Remote Desktop Services Profile and Sessions settings
    
.PARAMETER SamAccountName
    The SamAccountName of the user who needs the RDS settings updated
    
.EXAMPLE
    Set-PWRemoteDesktop -SamAccountName "ashen"

    # Sets RDS an Sessions settings for the user

#>

function Set-RemoteDestkopSettings {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline,
            Mandatory=$true,
            HelpMessage="Enter SamAccountName for user who needs RDS settings updated")]
        [String] $SamAccountName
    )
    PROCESS {
        Try {
            Write-Verbose "Setting $SamAccountName Remote Desktop settings..."
            $User = Get-ADUser $SamAccountName -Properties DistinguishedName,HomeDirectory
            $ADSIObject = [adsi]"LDAP://$($User.DistinguishedName)"

            ### Set Sessions settings ###
            $ADSIObject.PSBase.InvokeSet("BrokenConnectionAction", 1)

            ### Set Remote Desktop Services Profile settings ###
            $ADSIObject.PSBase.InvokeSet("TerminalServicesProfilePath", "C:\profiles\user")
            $ADSIObject.PSBase.InvokeSet("TerminalServicesHomeDrive", "H:")
            $ADSIObject.PSBase.InvokeSet("TerminalServicesHomeDirectory", $($User.HomeDirectory))
            $ADSIObject.CommitChanges()
            Write-Verbose "Setting $SamAccountName Remote Desktop settings... COMPLETE"
        } Catch {
            Write-Error $_
        }
    }
}