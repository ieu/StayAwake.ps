## Inspired by https://gist.github.com/CMCDragonkai/bf8e8b7553c48e4f65124bc6f41769eb

Add-Type -Name Kernel32 -Namespace Win32 -MemberDefinition @'
[DllImport("kernel32.dll")]
public static extern uint SetThreadExecutionState(uint esFlags);
'@

enum ExecutionState : uint32
{
    AWAYMODE_REQUIRED = [uint32]"0x00000040"
    CONTINUOUS        = [uint32]"0x80000000"
    DISPLAY_REQUIRED  = [uint32]"0x00000002"
    SYSTEM_REQUIRED   = [uint32]"0x00000001"
    USER_PRESENT      = [uint32]"0x00000004"
}

<#
 .SYNOPSIS
 Prevent the system from entering sleep or turning off the display while the application is running.

 .DESCRIPTION
 See https://learn.microsoft.com/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate for more details.

 .PARAMETER awayMode
 Enables away mode.
 See https://blogs.msdn.microsoft.com/david_fleischman/2005/10/21/what-does-away-mode-do-anyway for more details.

 .PARAMETER Discontinuous
 Reset the idle timer.
 By default, continuous flag is set, which informs the system that the state being set should remain in effect.

 .PARAMETER Display
 Forces the display to be on.

 .PARAMETER System
 Forces the system to be in the working state.

 .PARAMETER User
 This switch is not supported.

 .EXAMPLE
 # Prevent the system going into sleep or hibernation.
 Stay-Awake -System

 .EXAMPLE
 # Keep the display on.
 Stay-Awake -Display

 .EXAMPLE
 # Prevent the system going into sleep or hibernation while building with Gradle.
 Stay-Awake -System gralde build

 .EXAMPLE
 # Reset the system idle timer.
 Stay-Awake -Discontinuous -System

 .EXAMPLE
 # Reset the display idle timer.
 Stay-Awake --Discontinuous -Display

#>
function Stay-Awake {

    param
    (
        [Parameter(Mandatory = $false)]
        [switch]$AwayMode,

        [Parameter(Mandatory = $false)]
        [switch]$Discontinuous,

        [Parameter(Mandatory = $false)]
        [switch]$Display,

        [Parameter(Mandatory = $false)]
        [switch]$System,

        [Parameter(Mandatory = $false)]
        [switch]$User,
        
        [Parameter(Mandatory = $false)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    $esFlags = [uint32]"0x00000000"

    if ($AwayMode) {
        Write-Verbose "ES_AWAYMODE_REQUIRED is set."
        $esFlags = $esFlags -bor [ExecutionState]::AWAYMODE_REQUIRED
    }

    if (!$Discontinuous) {
        Write-Verbose "ES_CONTINUOUS is set."
        $esFlags = $esFlags -bor [ExecutionState]::CONTINUOUS
    }

    if ($Display) {
        Write-Verbose "ES_DISPLAY_REQUIRED is set."
        $esFlags = $esFlags -bor [ExecutionState]::DISPLAY_REQUIRED
    }

    if ($System) {
        Write-Verbose "ES_SYSTEM_REQUIRED is set."
        $esFlags = $esFlags -bor [ExecutionState]::SYSTEM_REQUIRED
    }

    if ($User) {
        Write-Verbose "ES_USER_PRESENT is set."
        $esFlags = $esFlags -bor [ExecutionState]::USER_PRESENT
    }

    $pFlags = [Win32.Kernel32]::SetThreadExecutionState($esFlags)

    if ($pFlags) {
        Write-Verbose "Execution state is set to ${esFlags}, replacing ${pFlags}."

        if ($Command) {
            Write-Verbose "Executing command ${Command} with arguments: ${Arguments}"
            & $Command @Arguments
        }
        elseif (!$Discontinuous) {
            [void](Read-Host "Press Enter to exit")
        }

        Write-Verbose "Execution state is reset to ${pFlags}."
        [void][Win32.Kernel32]::SetThreadExecutionState($pFlags)
    }
    else {
        Write-Error "Failed to set execution state."
    }

}

Export-ModuleMember -Function Stay-Awake
