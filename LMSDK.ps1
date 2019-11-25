$table = New-Object System.Data.DataTable
#$col1 = New-Object System.Data.DataColumn("Description")
$col3 = New-Object System.Data.DataColumn("Name")
$col4 = New-Object System.Data.DataColumn("CollectInterval")
$col5 = New-Object System.Data.DataColumn("CollectMethod")
$col6 = New-Object System.Data.DataColumn("DataPoint")
$col7 = New-Object System.Data.DataColumn("AlertForNoData")
$col8 = New-Object System.Data.DataColumn("AlertExpr")


#$table.Columns.Add($col1)
$table.Columns.Add($col3)
$table.Columns.Add($col4)
$table.Columns.Add($col5)
$table.Columns.Add($col6)
$table.Columns.Add($col7)
$table.Columns.Add($col8)


#put your pwd
$Scr = ConvertTo-SecureString  -AsPlainText -Force


#put your ID & accountname

try
{

$DataSource = Get-LogicMonitorDataSource -AccessID  -AccessKey $Scr -AccountName

#Loop thru DataSource

$cnt = 0

while($cnt -lt $DataSource.Length)
{





$datacnt = 0

while($datacnt -lt $DataSource[$cnt].DataPoints.Length)

{
$row = $table.NewRow()
#$row.Description = $DataSource[$cnt].description
$row.Name = $DataSource[$cnt].name
$row.CollectInterval = $DataSource[$cnt].CollectInterval
$row.CollectMethod = $DataSource[$cnt].CollectMethod
$row.DataPoint = $DataSource[$cnt].dataPoints[$datacnt].DataPoint.name
$row.AlertForNoData = $DataSource[$cnt].dataPoints[$datacnt].AlertForNoData
$row.AlertExpr = $DataSource[$cnt].dataPoints[$datacnt].AlertExpr



$table.rows.Add($row)
$datacnt = $datacnt + 1

}

$cnt = $cnt + 1

}
}

catch
{

Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 

Write-Host "StatusMessage:" $_.Exception.Response.StatusDescription

}