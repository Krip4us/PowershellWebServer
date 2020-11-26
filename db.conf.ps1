function acp{
    function validedset{
        if (((ping -n 1 8.8.8.8)[6])-eq "    (0% perdidos),") {
            $validedset = $true
        }
        else {
            $validedset = $false
        }
        $validedset
    }

    function table_apache{
        function get_uri {
            if ((test-path "$env:USERPROFILE\LionWebServerDataRecovery") -eq "$true") {
                (gc "$env:USERPROFILE\LionWebServerDataRecovery").split(",")[2]
            }
            else{
                write-host "$false"
            }
        }
        function get_user{
            if ((test-path "$env:USERPROFILE\LionWebServerDataRecovery") -eq "$true") {
                (gc "$env:USERPROFILE\LionWebServerDataRecovery").split(",")[1]
            }
            else{
                write-host "$false"
            }
        }

        [pscustomobject]@{
            uri = get_uri
            rootpath = "C:\inetpub\wwwroot"
            name = $env:COMPUTERNAME
            user = get_user
            domain = $env:USERDOMAIN
            connected = validedset
        }
    }
    function bsscommands{
        [pscustomobject]@{
            uri = "get url root page"
            rootpath = "get the root path directory config server"
            name = "my env:computername"
            user = "whoami"
            domain = "my domain (DNS)"
            connected = "check if the web server is connected"
            "exit" = "exit acp/bss"
        }
    }
    bsscommands
    while (1) {
        read-host "apache config console(acp/bss)" |foreach-object{
            if($_ -eq "uri"){
                table_apache | select-object uri
            }
            elseif ($_ -eq "rootpath") {
                table_apache | select-object rootpath
            }
            elseif ($_ -eq "name") {
                table_apache | select-object name
            }
            elseif($_ -eq "user"){
                table_apache | select-object user
            }
            elseif ($_ -eq "domain") {
                table_apache | select-object domain
            }
            elseif ($_ -eq "connected") {
                table_apache | select-object connected
            }
            elseif ($_ -eq "exit") {
                break ; 
            }
            else{
                write-host "error, BSS command not found" -foregroundcolor red
                bsscommands
            }
        }
    }
};
function errortypegettype{
    $errorcode = "0x-QWORD__" + (Get-Random -Maximum 999 -Minimum 5)
    $gettime = (get-date -format u)
    $errorcode + "/" + $gettime >> "$env:TEMP\LionWebServerError-Code"

    $geterrorHTML = ((Get-Error) | ConvertTo-Html)
        $geterrorHTML | Out-File "$env:USERPROFILE\LionWebServer.http-289.html" -Verbose
    
    Start-Process "$env:USERPROFILE\LionWebServer.http-289.html"
    Start-Process "$env:TEMP\LionWebServerError-Code"

    Write-Warning "server LION CANNOT START ; ErrorCode: $errorcode"
}

function cleancache{

    Start-Process powershell{
        function removetemp{
            (ls $env:TEMP | Select-Object FullName) | ForEach-Object{
                rm $_.FullName -Recurse -Force -Verbose:$true ;
            }
        }  
        if(!(test-path (gc "$env:USERPROFILE\LionWebServer.http-289.html")[0])-eq "False"){
            rm "$env:USERPROFILE\LionWebServer.http-289.html" -Force -Verbose:$true
        }
        else{
            "no errors in lion web server"
           }
        }
    }-verb runas ; 
     if( ( ls $env:TEMP | Select-Object FullName).count -gt 1 ){
        removetemp
    }
     else{
    Write-Host "el comando clear cache no esta funcionando. reinicia el script"
    }


function dbconf {
    param (
        [Parameter(Mandatory=$true)][string]$port,
        [string]$server = "http://localhost:$port",
        [Parameter(Mandatory=$true)][string]$username,
        [securestring]$password = $( Read-Host "Input password, please" -AsSecureString )
     )

    Write-Host "your web server url is in : " -ForegroundColor Green -NoNewline ; Write-Host $server -ForegroundColor Magenta
    Write-Host "the web server passwoord is : " -ForegroundColor Green -NoNewline ; Write-Host (ConvertFrom-SecureString $password -AsPlainText) -ForegroundColor Magenta
    Write-Host "the web server username is : " -ForegroundColor Green -NoNewline ; Write-Host $username -ForegroundColor Magenta
    Write-Host "the web server port is : " -ForegroundColor Green -NoNewline ; Write-Host $port -ForegroundColor Magenta

    function confirm {
        Write-Host "confirmar los datos" -ForegroundColor Green
        $port = Read-Host "port"
        $server = "http://localhost:$port"
        $username = Read-Host "username"
        $password = Read-Host "repeat password"

            "$port,$username,$server,$password" | Out-File $env:USERPROFILE\LionWebServerDataRecovery -Verbose
    }
    confirm
   
    function dbstart{
        start-sleep -seconds 2
        Start-Process powershell{
            Start-Process (gc "$env:USERPROFILE\LionWebServerDataRecovery").split(",")[2]
            Invoke-Expression "F:\DB_web-server\web-server.http.ps1"
        }
        if( ((invoke-webrequest -uri "http://localhost:$port")-notlike $null)-eq "True" ){
            Write-Host "DATA BASE OF LION WEB SERVICES IS: " -ForegroundColor Yellow -NoNewline ; Write-Host "[running]" -ForegroundColor Green
        }
        elseif (((invoke-webrequest -uri "$server")-notlike $null)-eq "False") {
            Write-Host "DATA BASE OF LION WEB SERVICES IS ON: " -ForegroundColor Yellow -NoNewline ; Write-Host "[error]" -ForegroundColor Red
            errortypegettype
        }
        else {
            errortypegettype ; gc $env:TEMP\LionWebServerError-Code | Out-GridView
        }
    }
    (Read-Host "start lion web server ? (y/n) >") | ForEach-Object{
        if ($_ -eq "y") {
            dbstart
           Write-Host "[ok] ==> " -NoNewline -ForegroundColor Green ; Write-Host "Lion Web Service lws/BSS"  -ForegroundColor Magenta -NoNewline ; Write-Host " [start]" -ForegroundColor Green
        }
        elseif ($_ -eq "n") {    
            Write-Host "
            [break] ==> " -NoNewline -ForegroundColor Red ; Write-Host "Lion Web Service lws/BSD 
            "  -ForegroundColor Magenta
            break;
        }
        else {
            errortypegettype
        }
    }
}

function mastercommanders{
        [PSCustomObject]@{
            "acp" = "view all your config set"
            "table_apache" = "view all config set as table "
            "cleancache" = "remove all your data config set"
            "dbconf" = "start settings of LionWebServer BasicServiceSites (lws/bss)"
            "confirm" = "reconfigure out-file data"
            "dbstart" = "view server on browser"
        }
    }
    mastercommanders
