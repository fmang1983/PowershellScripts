#Get Incidents


#Supply account specific token
try
{

$Pd = Invoke-WebRequest -Uri https://api.pagerduty.com/incidents -Headers @{Authorization = "Token token= "} -ContentType "application/json" -Method GET


}

catch
{

Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 

Write-Host "StatusMessage:" $_.Exception.Response.StatusDescription

}



#Get Teams

try
{

$Tm = Invoke-WebRequest -Uri https://api.pagerduty.com/teams  -Headers @{Authorization = "Token token="} -ContentType "application/json" -Method GET   # Supply token
 
}

catch
{

Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 

Write-Host "StatusMessage:" $_.Exception.Response.StatusDescription

}



$Team = $Tm | ConvertFrom-Json

$Team.teams

$cnt =0 

while ($cnt -lt $Incident.incidents.Length)

{


$Incident.incidents[$cnt]

$cnt = $cnt + 1

}