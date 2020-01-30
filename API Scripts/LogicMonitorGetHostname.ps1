$Scr = ConvertTo-SecureString "" -AsPlainText -Force    # Get API & encrypt

$table =New-Object system.data.datatable

$col1 = New-Object System.Data.DataColumn ("Server")
$col2 = New-Object System.Data.DataColumn ("Ip")
$col3 = New-Object system.Data.DataColumn ("SysName")
$col4 = New-Object system.Data.DataColumn ("Domain")
$col5 = New-Object system.Data.DataColumn ("Site")

$table.Columns.Add($col1)
$table.columns.add($col2)
$table.columns.add($col3)
$table.Columns.add($col4)
$table.Columns.add($col5)

$ServerCnt = 0


$Server = Get-LogicMonitorDevices -AccessID '' -AccessKey $Scr -AccountName ''   # Give AccessID & AccountName

while ($ServerCnt -lt $Server.Count)

{

$Row= $table.NewRow()

$Row.Server = $Server[$ServerCnt].displayName
$SysName = $Server[$ServerCnt].systemProperties| Where-Object {$_.name -eq "system.sysname"} |Select-Object -Property value
$Row.SysName = $SysName.value
$Domain= $Server[$ServerCnt].systemProperties | Where-Object {$_.name -eq "system.domain"} |Select-Object -Property value
$Row.Domain = $Domain.value
$Ip = $Server[$ServerCnt].systemProperties| Where-Object {$_.name -eq "system.ips"} |Select-Object -Property value
$Row.Ip = $Ip.value

if(($SysName -ne $null) -and ($Domain -ne $null))
{

$Internal = $SysName.value + '.' + $Domain.value + '*'

$Site =  Get-LogicMonitorWebsite -AccessID '' -AccessKey $Scr -AccountName '' | Where-Object {$_.description -like $Internal}    # Give AccessID & AccountName

if($Site -ne $null)
{

if($Site.Count -eq $null)
{

$Row.Site = $Site.Domain

}

else
{

$Row.Site = $Site[0].Domain

}

}

}

$table.rows.add($Row)

$ServerCnt = $ServerCnt + 1

}





$table | format-table -AutoSize | out-file '.\Desktop\GetHostName.txt'