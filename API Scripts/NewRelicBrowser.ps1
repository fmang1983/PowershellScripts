$table = New-Object system.Data.DataTable 

#Accounts - to break the query by accounts

$Account = @()   #Put in Account IDs

$Api = @()  #Put in list of API keys corresponding to the Account

$Name = @() #Account Names

#Alpha,Num - to break the query by app names

$Alpha = @("a%25","b%25"
,"c%25","d%25","e%25","f%25","g%25","h%25","i%25","j%25","k%25","l%25","m%25","n%25","o%25","p%25","q%25","r%25","s%25","t%25","u%25","v%25","w%25","x%25","y%25","z%25","1%25","2%25","3%25","4%25","5%25","6%25","7%25","8%25","9%25","0%25")

#Build Table Columns

$col1 = New-Object system.Data.DataColumn ("AppName")
$col2 = New-Object system.Data.DataColumn ("AppId")
$col3 = New-Object system.Data.DataColumn ("Account")

$col5 = New-Object System.Data.DataColumn ("PageView")


$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)
$table.Columns.add($col5)

$AccountCnt = 0


#Loop thru Accounts

while($AccountCnt -lt $Account.Length)
{

$AccountName = $Account[$AccountCnt]
$ApiName=$Api[$AccountCnt]

$AlphaCnt = 0

#Loop thru Apps

while($AlphaCnt -lt $Alpha.Length)
{

$AlphaName = $Alpha[$AlphaCnt]


try
{
#Write-Host $AlphaName
$results = Invoke-WebRequest -Uri "https://insights-api.newrelic.com/v1/accounts/$AccountName/query?nrql=SELECT count(*) from PageView facet appId,appName since 30 days ago where appName like '$AlphaName' limit 2000" -Headers @{'X-Query-Key'=$ApiName} -ContentType "application/json" -Method GET
$data = $results.Content|ConvertFrom-Json
}

catch
{

Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 

Write-Host "StatusMessage:" $_.Exception.Response.StatusDescription

}


if($data.facets.Count -gt 0)
{

$FacetCnt = 0

while($FacetCnt -lt $data.facets.Count)
{
$row = $table.NewRow()
$row.AppName = $data.facets[$FacetCnt].name[1]
$row.AppId = $data.facets[$FacetCnt].name[0]
$row.Account = $Name[$AccountCnt]
$row.PageView = $data.facets[$FacetCnt].results[0].count
$table.rows.Add($row)
$FacetCnt = $FacetCnt + 1
}

}
$AlphaCnt = $AlphaCnt + 1
}
$AccountCnt = $AccountCnt + 1

}

$table|format-table -AutoSize | out-file '.\Desktop\Browser.txt'
