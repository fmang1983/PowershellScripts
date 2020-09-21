$Script = {

Param([int]$Count,[string]$Proc,[int]$TID)

$GetValues = "Select "
$counter = 1
$prevalueList=''
$Call = ''

while($counter -le $Count)
{

$Value = "Para" + $counter + ","
$GetValues = $GetValues + $Value
$counter = $counter + 1

}

$GetValues =$GetValues.Substring(0,$GetValues.Length-1)
$GetValues = $GetValues + " from NUNittesting where TableId = " + $TID


Write-Host $GetValues

$Command = New-Object Data.Odbc.OdbcCommand($GetValues,$snowconn)

$result = $Command.ExecuteReader()


 
while ($result.Read()) 
        { 

        $prevalueList = ''

            for($i =1 ; $i -le $Count; $i++){
      
                $parameter="PARA" + $i  
                $valueList=$result[$parameter]

                if($i -eq 1){
                    $prevalueList = "'$valueList'"
            
                }else{
            
                $prevalueList = $prevalueList+ "," + "'$valueList'"
            
                }
}

$Call = "Call " + $Proc + " (" + $prevalueList + ")-" + $TID



}


return $Call


}



[xml]$Config = [xml] (Get-Content -Path C:\Users\franco.mang\Desktop\Config.xml)

$Calls = @()
$DsnName=$Config.ConfigValues.DsnNameRpt
$counter = 1
$GetValues = "Select "
$SqlName = $Config.ConfigValues.SqlDB

$snowconn = New-Object Data.Odbc.OdbcConnection
$sqlconn = New-Object System.Data.SqlClient.SqlConnection
$sqlconn.ConnectionString = $SqlName
$sqlconn.Open()

Write-Host $sqlconn.State

$snowconn.ConnectionString=$DsnName
$snowconn.Open()

$Query = "Select TableId,ProcName,(REGEXP_COUNT(PARAMETERS,',')+ 2 ) as count from NUNittesting where TableId in (63,67,68,69,70,71)"


$Command = New-Object Data.Odbc.OdbcCommand($Query,$snowconn)

$ds = New-Object system.Data.DataSet

(New-Object system.Data.odbc.odbcDataAdapter($Command)).fill($ds) | out-null


$ds.Tables[0]| ForEach-Object  -Process { $Calls += $(Invoke-Command -Scriptblock $Script -ArgumentList $_.Count, $_.ProcName, $_.TableId)}

Write-Host $Calls

$ScriptBlock = {

param ([string]$Call)

try
{
[xml]$Config = [xml] (Get-Content -Path C:\Users\franco.mang\Desktop\Config.xml)

$Sproc = $Call.Split('-')[0]

$TID = $Call.Split('-')[1]

$Sqlproc =$Call.Substring(0, $Call.LastIndexOf(',')) + ')'

$DsnName=$Config.ConfigValues.DsnNameRpt
$snowconn = New-Object Data.Odbc.OdbcConnection

$snowconn.ConnectionString=$DsnName
$snowconn.Open()

#Clear the cache

$Session = "alter session set USE_CACHED_RESULT = false"
$Comm = new-object System.Data.Odbc.OdbcCommand($Session,$snowconn) 

$Comm.ExecuteNonQuery()
$Comm1 = new-object System.Data.Odbc.OdbcCommand($Sproc,$snowconn)

#$SqlComm = new-object System.Data.SqlClient.SqlCommand($Sqlproc,$sqlconn)
$SnowTimeSecond =Measure-Command {
$Readersnow=$Comm1.ExecuteReader() } | Select-Object -Property TotalSeconds

#$SqlTimeSecond =Measure-Command {
#$Readersnow=$Comm1.ExecuteReader() } | Select-Object -Property TotalSeconds

Write-Output  $TID $SnowTimeSecond
}

catch{
Write-Host "Message : Error in opening Snowflake Connection : [$($_.Exception.Message)"] -ForegroundColor Red -BackgroundColor yellow
        break;


}
}


$MaxT = 3
$RunSpacePool = [RunspaceFactory]::CreateRunspacePool(1,$MaxT)
$RunSpacePool.

$runspaces = @()

$RunspacePool.Open()

Foreach($Call in $Calls){

$PS = [Powershell]::Create()
$PS.AddScript($ScriptBlock).AddArgument($Call)

$PS.RunSpacePool = $RunSpacePool
$runspaces += [PSCustomObject]@{ Pipe = $PS; Status = $PS.BeginInvoke() }
}

while ($runspaces.Status -ne $null)
{
    $completed = $runspaces | Where-Object { $_.Status.IsCompleted -eq $true }
 
 
    foreach ($runspace in $completed)
    {
        $runspace.Pipe.EndInvoke($runspace.Status)
        $runspace.Status = $null
        
    }
}





