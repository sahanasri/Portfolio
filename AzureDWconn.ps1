$sqlScriptDirectory = "C:\Users\ssrivats\test_sql\schema\drop_schema" # e.g. "~/sql_test"
$localDirectory = "/Users/ssrivats/scripts"
$userName =  "********"
$secret = Get-AzKeyVaultSecret -VaultName 'Sahana-vault' -Name 'DataWarehousePassword'
$userPassword = $secret.SecretValueText
#$userPassword =  "***********"

$QueryTimeout = 120
$ConnectionTimeout = 30

$server = "*************"
$database = "************"

#mkdir $sqlScriptDirectory
#cd
# TO DO LATER: commented out log file. Tee was throwing errors.
# $log_file = $(join-path $sqlScriptDirectory "ddlout_$(Get-Date -Format "MMdd_hhmm")_$(get-random).out")
# New-Item -path $log_file -type "file" #-ErrorAction Continue

# This line will get sql files in $sqlScriptDirectory and submit them to sqlcmd
$conn=New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};User ID=qpr_warehouse_usr;Password=codm-123*^#;Integrated Security=False;Connect Timeout={2}" -f $server,$database,$ConnectionTimeout,$UserName,$Password
$conn.ConnectionString=$ConnectionString
$conn.Open()

write-host "connection open"
# Get-ChildItem -Recurse -Filter "*.sql" $sqlScriptDirectory | % { sqlcmd -S $server -d $database -U $userName -P $userPassword -I -i $($_.fullname)  }
Get-ChildItem -Filter "*.sql" $sqlScriptDirectory | % {
    $sql_file = $($_.fullname)
    $Query = get-content -Path $sql_file

    write-host "$Query"

    $cmd=New-Object system.Data.SqlClient.SqlCommand($Query,$conn)
    $cmd.CommandTimeout=$QueryTimeout
    write-host "object created"

    try {
        $cmd.ExecuteNonQuery()
        write-host "query executed"
    } catch {
        Write-Error "ERROR: $($PSItem.Exception.Message)`nFile: $($sql_file)`nQuery: $($Query)"
    }

}

$conn.Close()
