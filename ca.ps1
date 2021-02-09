New-MgIdentityConditionalAccessPolicy -DisplayName ’NMSummit Policy' `
 -GrantControls @{ `
  BuiltInControls = @('mfa','compliantDevice'); `
   Operator = 'OR' `
 } `
 -State 'disabled' `
 -Conditions @{ `
 Applications = @{includeApplications = '797f4846-ba00-4fd7-ba43-dac1f8f63013'}; `
 Users = @{includeUsers = 'none'} `
 }

Update-MgIdentityConditionalAccessPolicy –ConditionalAccessPolicyId a48817cf-c2dc-45d3-9f33-a5797c527e92 -DisplayName ’NMSummit Policy' `
 -GrantControls @{ `
  BuiltInControls = @('mfa','compliantDevice'); `
   Operator = 'OR' `
 } `
 -State 'disabled' `
 -Conditions @{ `
 Applications = @{includeApplications = '797f4846-ba00-4fd7-ba43-dac1f8f63013'}; `
 Users = @{includeUsers = 'none'} `
 }
