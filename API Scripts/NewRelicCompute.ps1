$table = New-Object system.Data.DataTable 



#Alpha,Num - to break the query by app names

$Account = @()  #Put in Account Names

$col1 = New-Object system.Data.DataColumn ("CloudID")
$col2 = New-Object system.Data.DataColumn ("Account")
$col3 = New-Object system.Data.DataColumn ("Compute")



$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)




#Loop thru Accounts



$AlphaCnt = 0

#Loop thru Apps

while($AlphaCnt -lt $Account.Length)
{

$AccountName = $Account[$AlphaCnt]

try
{

$results = Invoke-WebRequest -Uri "https://insights-api.newrelic.com/v1/accounts/27873/query?nrql=SELECT average(infrastructureComputeUnits) from NrDailyUsage facet agentHostname, consumingAccountName where consumingAccountName %3D '$AccountName' since 30 day ago limit 2000" -Headers @{'X-Query-Key'=""} -ContentType "application/json" -Method GET  #Put in Querykey within quotes
$data = $results.Content|ConvertFrom-Json

}

catch
{

Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 

Write-Host "StatusMessage:" $_.Exception.Response.StatusDescription

}

if($data.facets.Length -eq 2000)
{

Write-Host $AccountName

}

else
{
$FacetCnt = 0

while($FacetCnt -lt $data.facets.Length)
{


$row = $table.NewRow()
$row.CloudID = $data.facets[$FacetCnt].name[0]
$row.Account = $data.facets[$FacetCnt].name[1]
$row.Compute = $data.facets[$FacetCnt].results[0].average
$table.rows.Add($row)
$FacetCnt = $FacetCnt + 1

}

}
$AlphaCnt = $AlphaCnt + 1
}

$table|format-table -AutoSize | out-file '.\Desktop\New Relic Infra.txt'
