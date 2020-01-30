Set-AWSCredentials -AccessKey  -SecretKey              # Get AcessKey & SecretKey
$arn = ""                  # Get arn string

$mon_creds = (Use-STSRole -Region us-west-1 -RoleArn $arn -RoleSessionName "").Credentials     # put in RoleSessionName

write-host "Establishing Connection..."


write-host "Getting EC2 data..."



$EC2_reservations = Get-EC2Instance -Region us-west-1 -Credential $mon_creds 



$Ec2 = @()


$x = $EC2_reservations.Instances | Where-Object {$_.state.code -eq 16}  |Select-Object InstanceId,PrivateIpAddress

$x| Out-File '.\Desktop\CurrentEC2East2.txt'
 