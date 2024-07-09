
# Executar power shell como administrador.
param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

# LOADER FUNCTION
function loader {
    $i = 0
Write-Host "`n`n --- | $($funcName) | ---" -ForegroundColor Yellow
    while ($i -lt 35) {
        Write-Host " " -NoNewline -ForegroundColor Green -BackgroundColor Green
        $i += 1
        Start-Sleep -Milliseconds 50
    }
}

<# ------------------------------------------------------------------------ #>
# Limpar cookies e cache do chrome
function chromeClear {

    Clear-Host
    
    # MATANDO PROCESSO
    Write-Host "`n    ------------------------------------------------------"
    Write-Host "--- |O Chrome sera fechado, precione" -NoNewline
    Write-Host " ENTER" -ForegroundColor Blue -NoNewline
    Write-Host " para continuar| ---" -NoNewline
    Write-Host "`n    ------------------------------------------------------"
    $tmo = timeout /T 50020
    taskkill /IM chrome.exe /F
    
    $i = 0
    Write-Host "`n--- |FECHANDO CHROME| ---" -ForegroundColor Yellow
    while ($i -lt 30) {
        Write-Host "." -NoNewline -ForegroundColor Red
        $i += 1
        Start-Sleep -Milliseconds 10
    }

    # Pegando o Usuário corrente
    $currentUser = [Environment]::UserName
    
    # REMOVENDO COOKIES
    Remove-Item C:\Users\$currentUser\AppData\Local\Google\Chrome\'User Data'\Default\Network\Cookies -Force -ErrorAction SilentlyContinue
    Remove-Item C:\Users\$currentUser\AppData\Local\Google\Chrome\'User Data'\Default\Network\Cookies-journal -Force -ErrorAction SilentlyContinue
    
    $funcName = "REMOVENDO COOKIES"
    loader($funcName)
    
    # REMOVENDO CACHE
    Remove-Item C:\Users\$currentUser\AppData\Local\Google\Chrome\'User Data'\Default\cache\Cache_Data -Force -Recurse -ErrorAction SilentlyContinue
    
    $funcName = "REMOVENDO CACHE"
    loader($funcName)
    
    # REMOVENDO HISTORICO
    Remove-Item C:\Users\$currentUser\AppData\Local\Google\Chrome\'User Data'\Default\History -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item C:\Users\$currentUser\AppData\Local\Google\Chrome\'User Data'\Default\History-journel -Force -Recurse -ErrorAction SilentlyContinue
    
    $funcName = "REMOVENDO HISTORICO"
    loader($funcName)
    
    Write-Host "`n`n--- | CACHE E COOKIES REMOVIDOS | ---" -BackgroundColor Black -ForegroundColor Green
    Write-Host "`n`n Voltando para a tela inicial "
    timeout.exe /T 5

    Clear-Host
    chooseOption
}

<# ---------------------------------------------------------------------- #>
# REMOVER ARQUIVOS TEMPORÁRIOS DO WINDOWS - "TEMP", "%TEMP%" e "PREFETCH"
function tempRemove {

    Clear-Host
    
    Write-Host "`n    -----------------------------------------------------------------"
    Write-Host "--- |Antes, feche todos os programas que estao abertos no Computador| ---"
    Write-Host "         --- |Apos fechar os programas, precione" -NoNewline
    Write-Host " ENTER" -ForegroundColor Blue -NoNewline
    Write-Host "| ---" -NoNewline
    Write-Host "`n             ------------------------------------------"
    
    $tmo = timeout /T 50000 
    
    $TEMP1 = Remove-Item $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue
    $TEMP2 = Remove-Item C:\Windows\Temp\* -Recurse -Force -ErrorAction SilentlyContinue
    $TEMP3 = Remove-Item C:\Windows\Prefetch\* -Recurse -Force -ErrorAction SilentlyContinue
    
    $funcName = "REMOVENDO TEMP FILES"
    loader($funcName)
    
    Write-Output "`n"
    
    try {
        $TEMP1
        $TEMP2
        $TEMP3
    }   
    catch {
        Write-Host 'TEMP files não encontrados.'
    }
    Write-Host -ForegroundColor Green -BackgroundColor Black "--- |TEMP FILES REMOVIDOS| ---`n"
    
    Write-Host "`n Voltando para a tela inicial "
    timeout.exe /T 5

    Clear-Host
    chooseOption
    
}

<# ---------------------------------------------------------------------- #>
# Excluir arquivos Spool
function spoolClear {

    Clear-Host

    Stop-Service Spooler
    Remove-Item -Path C:\Windows\System32\spool\PRINTERS\* -Force -Recurse

    #loader
    $funcName = "LIMPANDO FILA"
    loader($funcName)

    Start-Service Spooler

    Write-Host "`n`n--- | FILA DE IMPRESSAO REMOVIDA | ---" -ForegroundColor Green -BackgroundColor Black
    Write-Host "`n`n Voltando para a tela inicial "
    timeout.exe /T 5

    Clear-Host
    chooseOption
}

<# ------------------------------------------------------------------------- #>
# Erro ao Compartilhar impressora

# Função para modificar registros 
function registryModify {

    Clear-Host
    
    function regeditModify {
         param (
            [string]$registryPath,
            [string]$nameProperty,
            [string]$valueProperty
         )
         if (!(Test-Path $registryPath)) {
             New-Item -Path $registryPath -Force | Out-Null
         }
         New-ItemProperty -Path $registryPath -Name $nameProperty -Value $valueProperty -PropertyType DWORD -Force | Out-Null
    }
    
    $funcName = "CORRIGINDO ERROR 011b"
    loader($funcName)
    # ERROR_011b
    regeditModify -registryPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers' -nameProperty 'RpcAuthnLevelPrivacyEnabled' -valueProperty '0'
    regeditModify -registryPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers' -nameProperty "CopyFilesPolicy" -valueProperty "1"
    
    $funcName = "CORRIGINDO ERROR 0709"
    loader($funcName)
    # ERROR_0709
    regeditModify -registryPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC' -nameProperty "RpcOverNamedPipes" -valueProperty "1"
    regeditModify -registryPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC' -nameProperty "RpcOverTcp" -valueProperty "0"
    regeditModify -registryPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC' -nameProperty "RpcUserNamedPipeProtocol" -valueProperty "1"
    regeditModify -registryPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Print' -nameProperty "RpcAuthnLevelPrivacyEnabled" -valueProperty "0"
    
    $funcName = "REINICIANDO SPOOLER"
    # Reiniciar Spooler de Impressão
    Stop-Service Spooler
    Start-Service Spooler

    Write-Host "`n`n--- | ERROS CORRIGIDOS | ---" -BackgroundColor Black -ForegroundColor Green
    Write-Host "`n`nTente instalar a impressora, caso o erro persistir `n
    faca o mesmo no outro PC e reinicie ambos`n"

    timeout /T 10

    Clear-Host
    chooseOption
}

<# ------------------------------------------------------------------------- #>
# DESABILITAR WINDOWS UPDATE

function disableWinUpdate {

    Clear-Host

    Stop-Service wuauserv -Force
    $funcName = "DESABILITANDO UPDATE"
    loader($funcName)
    Set-Service wuauserv -StartupType Disabled
    
    function regeditModify {
        param (
           [string]$registryPath,
           [string]$nameProperty,
           [string]$valueProperty
        )
        if (!(Test-Path $registryPath)) {
            New-Item -Path $registryPath -Force | Out-Null
        }
        New-ItemProperty -Path $registryPath -Name $nameProperty -Value $valueProperty -PropertyType DWORD -Force | Out-Null
    }

    $funcName = "DESABILITANDO REGISTRY"
    loader($funcName)
    
    regeditModify -registryPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -nameProperty "NoAutoUpdate" -valueProperty "1"
    regeditModify -registryPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -nameProperty "NoAutoUpdate" -valueProperty "1"

    Write-Host "`n`n--- | WINDOWS UPDATE DESABILITADO | ---" -BackgroundColor Black -ForegroundColor Green
    Write-Host "`n`n Voltando para a tela inicial "
    timeout /T 5

    Clear-Host
    chooseOption
}
<# ------------------------------------------------------------------------- #>

# HABILITAR WINDOWS UPDATE
function enableWinUpdate {
    
    Clear-Host

    Set-Service wuauserv -StartupType Manual
    $funcName = "HABILITANDO UPDATE"
    loader($funcName)
    Start-Service wuauserv

    $funcName = "HABILITANDO REGISTRY"
    loader($funcName)
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name "NoAutoUpdate" -ErrorAction Ignore
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name "NoAutoUpdate" -ErrorAction Ignore

    Write-Host "`n`n--- | WINDOWS UPDATE HABILITADO | ---" -BackgroundColor Black -ForegroundColor Green
    Write-Host "`n`n Voltando para a tela inicial "
    timeout /T 5

    Clear-Host
    chooseOption
}

<# ---------------------------------------------------------------------- #>
# APRESENTAÇÃO
function chooseOption {

    Write-Host "`n"
$j = 0
$welCome = "        BEM VINDO AO IT SCRIPS `n       created by Alan Oliveira"

while ($j -lt $welCome.Length) {
    if ($j -gt 49) {
        Write-Host "$($welCome[$j])" -NoNewline -ForegroundColor Cyan
        $j += 1
    }
    if ($j -lt 50) {
        Write-Host "$($welCome[$j])" -NoNewline -ForegroundColor Green
        $j += 1
    }
    Start-Sleep -Milliseconds 10
        
}

    # Escolhas de funções
    $userEntry = $(Write-Host "`n`n    -------------------------------- `n`n 
    Escolha um numero correspondente a funcao e aperte ENTER: `n`n") +
$(Write-Host "    ( 1 ) - Limpar cookies e cache do Chrome `n" -ForegroundColor Yellow) +
$(Write-Host "    ( 2 ) - Limpar arquivos temporarios do Windows `n" -ForegroundColor Yellow) + 
$(Write-Host "    ( 3 ) - Remover arquivos da Fila de Impressao `n" -ForegroundColor Yellow) + 
$(Write-Host "    ( 4 ) - Corrigir erro ao compartilhar impressora `n" -ForegroundColor Yellow) + 
$(Write-Host "    ( 5 ) - Desabilitar Windows Update `n" -ForegroundColor Yellow) +
$(Write-Host "    ( 6 ) - Habilitar Windows Update" -ForegroundColor Yellow) +
    $(Write-Host "`n`n    -------------------------------- `n`n
    Pressione somente " -NoNewline) + $(Write-Host "ENTER" -NoNewline -ForegroundColor Red) + $(Write-Host " para sair do programa `n 
    Pressione a tecla " -NoNewline) + $(Write-Host "A" -NoNewline -ForegroundColor Green) + $(Write-Host " para visitar o github da aplicacao `n`n"; Read-Host)
    
    switch ($userEntry) {
        1 { chromeClear }
        2 { tempRemove }
        3 { spoolClear }
        4 { registryModify }
        5 { disableWinUpdate }
        6 { enableWinUpdate }
        "a" { Start-Process msedge.exe "https://github.com/truelanz/it_app"; clear; chooseOption}
        Default { exit }
    }
    
}

chooseOption