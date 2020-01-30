$connectionString = ''   #Get Connection String
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
$sqlConnection.Open()

try
{

$cmd = new-object system.data.sqlclient.sqlcommand("select count(*) from cmdb.[Database]",$sqlConnection)
$rows = [Int32]$cmd.ExecuteScalar()
$table = $cmd.CommandText.Substring($cmd.CommandText.IndexOf('[')+1,$cmd.CommandText.IndexOf(']')-($cmd.CommandText.IndexOf('[')+1))
Write-Host $table "has" $rows "rows"

}

catch [System.Data.SqlClient.SqlException]
{

Write-Host $_.Exception.Message
}

finally
{

$sqlConnection.Close()

}
