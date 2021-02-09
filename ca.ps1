New-MgIdentityConditionalAccessPolicy -DisplayName ’Example Policy' `
 -GrantControls @{ `
  BuiltInControls = @('mfa'); `
   Operator = 'OR' `
 } `
 -State 'disabled' `
 -Conditions @{ `
 Applications = @{includeApplications = 'none'}; `
 Users = @{includeUsers = 'none'} `
 }