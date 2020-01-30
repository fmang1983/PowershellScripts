$table = New-Object system.Data.DataTable 



#Alpha,Num - to break the query by app names
$Account = @("a%25","b%25"
,"c%25","d%25","e%25","f%25","g%25","h%25","i%25","j%25","k%25","l%25","m%25","n%25","o%25","p%25","q%25","r%25","s%25","t%25","u%25","v%25","w%25","x%25","y%25","z%25","1%25","2%25","3%25","4%25","5%25","6%25","7%25","8%25","9%25","0%25")


$col1 = New-Object system.Data.DataColumn ("Account")
$col2 = New-Object system.Data.DataColumn ("CloudID")

$col3 = New-Object system.Data.DataColumn ("Compute")



$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)




#Loop thru Accounts



$AlphaCnt = 0

#Loop thru Apps

while($AlphaCnt -lt $Account.Length)
{

$AccountName = 'i-0' + $Account[$AlphaCnt]

try
{

$results = Invoke-WebRequest -Uri "https://insights-api.newrelic.com/v1/accounts/27873/query?nrql=SELECT average(infrastructureComputeUnits) from NrDailyUsage since 30 day ago%20%0A where consumingAccountName %3D 'Medidata PaaS Development' and productLine %3D 'Infrastructure'%20 and cloudInstanceId like '$AccountName' facet consumingAccountName, agentHostname" -Headers @{'X-Query-Key'=""} -ContentType "application/json" -Method GET    # Get Querykey
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
$row.Account = $data.facets[$FacetCnt].name[1]
$row.CloudID = $data.facets[$FacetCnt].name[0]
$row.Compute = $data.facets[$FacetCnt].results[0].average
$table.rows.Add($row)
$FacetCnt = $FacetCnt + 1

}

}
$AlphaCnt = $AlphaCnt + 1
}
