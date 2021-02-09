## Create a new CA rule disabled using MFA

New-MgIdentityConditionalAccessPolicy -DisplayName 'Minimum required Parameters' `
>>      -GrantControls @{ `
>>         BuiltInControls = @('mfa'); `
>>         Operator = 'OR' `
>>      } `
>>      -State 'disabled' `
>>      -Conditions @{ `
>>         Applications = @{includeApplications = 'none'}; `
>>         Users = @{includeUsers = 'none'} `
>>      }
