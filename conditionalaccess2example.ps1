# New Conditional Access Policy with built-in controls for MFA OR compliant device against the Azure Management API

New-MgIdentityConditionalAccessPolicy -DisplayName ’NMSummit Policy' `
 -GrantControls @{ `
  BuiltInControls = @('mfa','compliantDevice'); `
   Operator = 'OR' `
 } `
 -State 'disabled' `
 -Conditions @{ `
 Applications = @{includeApplications = '797f4846-ba00-4fd7-ba43-dac1f8f63013'}; `
 Users = @{includeUsers = 'none'} `
 }
