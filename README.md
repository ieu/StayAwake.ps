A simple PowerShell module that provides the ability to prevent Windows going into sleep or hibernation.

## Installation

Save `StayAwake.psm1` to directory with the same name that located in the `$env:PSModulePath` and restart PowerShell.

For example, to install this module for current user, save `StayAwake.psm1` to `%USERPROFILE%\Documents\PowerShell\Modules\StayAwake`.

There may be an error states that command was found but can not be run due to the fact that this module is not digitally signed.

It's because that PowerShell is by default configured to block remote downloaded script to be executed for security reasons, and could be easily resolved by executing `Unblock-File` or checking "Unblock" in the File Properties.

## Usage

To prevent the system going into sleep or hibernation:

```PowerShell
Stay-Awake -System
```

To keep the display on:

```PowerShell
Stay-Awake -Display
```

To keep the system awake while executing command:

```PowerShell
Stay-Awake -System gradle build
```

Get help for more usages:

```PowerShell
Get-Help Stay-Awake
```
