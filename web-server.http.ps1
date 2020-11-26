$uri = (gc "C:\Users\Administrador\LionWebServerDataRecovery").split(",")[2]
$routes = @{
    "/" = { return '<html><body>Servidor web</body></html>' }
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($uri+"/")
$listener.Start()

Write-Host "Funcionando $uri..."

while ($listener.IsListening)
{
    $context = $listener.GetContext()
    $requestUrl = $context.Request.Url
    $con
    $response = $context.Response

    Write-Host ''
    Write-Host "Peticion: $requestUrl"

    $localPath = $requestUrl.LocalPath
    $route = $routes.Get_Item($requestUrl.LocalPath)

    if ($route -eq $null)
    {
        $response.StatusCode = 404
    }
    else
    {
        $content = & $route
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    }
    
    $response.Close()

    $responseStatus = $response.StatusCode
    Write-Host "Respuesta: $responseStatus"
}