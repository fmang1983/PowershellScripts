#Create Player Table

$Playertable = New-Object System.Data.DataTable

#Create Table Columns
$col1 = New-Object system.Data.DataColumn("Id")
$col2 = New-Object system.Data.DataColumn("Title")
$col3 = New-Object system.Data.DataColumn("FirstName")
$col4 = New-Object system.Data.DataColumn("LastName")
$col5 = New-Object system.Data.DataColumn("Email")
$col6 = New-Object system.Data.DataColumn("Nationality")

#Add Table Columns
$Playertable.Columns.Add($col1)
$Playertable.Columns.Add($col2)
$Playertable.Columns.Add($col3)
$Playertable.Columns.Add($col4)
$Playertable.Columns.Add($col5)
$Playertable.Columns.Add($col6)


#Create GameTable
$GameTable = New-Object System.Data.DataTable

#Create Table Columns
$col1 = New-Object system.Data.DataColumn("Game_Id") 
$col2 = New-Object system.Data.DataColumn("Player_Id") 
$col3 = New-Object system.Data.DataColumn("Move_Number") 
$col4 = New-Object system.Data.DataColumn("Column") 
$col5 = New-Object system.Data.DataColumn("Result")


#Add Table Columns
$GameTable.Columns.Add($col1)
$GameTable.Columns.Add($col2)
$GameTable.Columns.Add($col3)
$GameTable.Columns.Add($col4)
$GameTable.Columns.Add($col5)

Function PutDataInTable
{
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [Object[]]
        $Records
    )
    Process
    {

    
    $Id = [Convert]::Toint32($Records[0].id,10)

$row = $Playertable.NewRow()
[int]$row.Id = $Id
$row.Title = $Records[0].data.name.title
$row.FirstName = $Records[0].data.name.first
$row.LastName = $Records[0].data.name.last
$row.Email = $Records[0].data.email
$row.Nationality = $Records[0].data.nat
$Playertable.rows.Add($row)




}

}


Function PutGameDataInTable
{
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [Object[]]
        $Records
    )
    Process
    {

    $Game_Id = [convert]::ToInt32($Records.Game_Id,10)
    $Player_Id = [convert]::ToInt32($Records.Player_Id,10)
    $Move_Number = [convert]::ToInt32($Records.move_number,10)
    $Column = [convert]::ToInt32($Records.column ,10)

    $row = $GameTable.NewRow()
[int]$row.Game_Id = $Game_Id
[int]$row.Player_Id = $Player_Id
[int]$row.Move_Number = $Move_Number
[int]$row.Column = $Column
$row.Result = $Records.result
$GameTable.rows.Add($row)


}

}




$pgcnt = 0

#GetCSV

$CsvFile = Invoke-WebRequest   -Uri https://s3-us-west-2.amazonaws.com/98point6-homework-assets/game_data.csv   -outfile "C:\Users\fmang\Desktop\game_data.csv"

$GameData = Import-Csv -Path .\Desktop\game_data.csv



$GameBatchCount = 0
$GameCnt = 0

while($GameBatchCount -lt $GameData.Count)
{

if(($GameData[$GameBatchCount].Game_Id.Length -gt 4)  -and ($GameData[$GameBatchCount].result.Length -gt 0))
{
  $GameData[$GameBatchCount].Game_Id = $GameCnt
  $GameData[$GameBatchCount] | PutGameDataInTable 
  $GameCnt = $GameCnt + 1
  $GameBatchCount = $GameBatchCount + 1
  
}

elseif (($GameData[$GameBatchCount].Game_Id.Length -gt 4)  -and ($GameData[$GameBatchCount].result.Length -eq 0))
{
$GameData[$GameBatchCount].Game_Id = $GameCnt
  $GameData[$GameBatchCount] | PutGameDataInTable 
  $GameBatchCount = $GameBatchCount + 1
  
}

elseif (($GameData[$GameBatchCount].Game_Id.Length -le 4) -and ($GameData[$GameBatchCount].result.Length -gt 0))
{

  $GameData[$GameBatchCount] | PutGameDataInTable 
  $GameBatchCount = $GameBatchCount + 1
  $GameCnt = $GameCnt + 1
}

else 
{

  $GameData[$GameBatchCount] | PutGameDataInTable 
  $GameBatchCount = $GameBatchCount + 1
  
}


}

do
{

try
{



$Cont = Invoke-WebRequest -Uri "https://x37sv76kth.execute-api.us-west-1.amazonaws.com/prod/users?page=$pgcnt"  -ContentType "application/json" -Method GET


$Data = $Cont | ConvertFrom-Json

$BatchCnt = 0

while ($BatchCnt -lt $Data.Count)

{

$Data[$BatchCnt] | PutDataInTable

$BatchCnt = $BatchCnt + 1


}

$pgcnt = $pgcnt + 1






}
catch
{

Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 

Write-Host "StatusMessage:" $_.Exception.Response.StatusDescription

} } while ($Data.count -ge 1)


#$table|format-table -AutoSize | out-file .\Desktop\Homework.txt


$connectionString = 'Data Source=DL9ZYL4H2;Initial Catalog=Homework;Integrated Security=True'
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
$sqlConnection.Open()

$SqlBulk = New-Object System.Data.SqlClient.SqlBulkCopy($connectionString)
$SqlBulk.DestinationTableName = "Player"
$SqlBulk.WriteToServer($Playertable)


$SqlBulk = New-Object System.Data.SqlClient.SqlBulkCopy($connectionString)
$SqlBulk.DestinationTableName = "Game_Data"
$SqlBulk.WriteToServer($GameTable)


$sqlConnection.Close()







