@echo off
setlocal EnableDelayedExpansion
title NetDiag - Diagnostico e Reparo de Rede
color 0A
set "REPORT=%~dp0NetDiag_%COMPUTERNAME%.txt"
:: ============================================================
:: VERIFICAR ADMINISTRADOR
:: ============================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] Este programa precisa ser executado como ADMINISTRADOR.
    echo.
    echo Clique com o botao direito no arquivo e escolha:
    echo "Executar como administrador"
    echo.
    pause
    exit /b
)
:: ============================================================
:: MENU PRINCIPAL
:: ============================================================
:MENU
cls
echo ============================================================
echo                    NETDIAG WINDOWS
echo ============================================================
echo.
echo  Diagnostico, descoberta de hosts e reparo de rede
echo.
echo ------------------------------------------------------------
echo  [1] Diagnostico completo
echo  [2] Descobrir hosts da rede local
echo  [3] Testar hosts encontrados
echo  [4] Testar portas TCP
echo ------------------------------------------------------------
echo  [5] Flush DNS
echo  [6] Renew DHCP
echo  [7] Release + Renew DHCP
echo  [8] Limpar cache ARP
echo  [9] Resetar Winsock
echo [10] Resetar TCP/IP
echo ------------------------------------------------------------
echo [11] Teste rapido de Internet
echo [12] Teste de DNS
echo [13] Ver conexoes e portas locais
echo [14] Gerar relatorio completo
echo ------------------------------------------------------------
echo  [0] Sair
echo ============================================================
echo.
set /p "OPTION=Escolha uma opcao: "
if "%OPTION%"=="1" goto FULL
if "%OPTION%"=="2" goto DISCOVER
if "%OPTION%"=="3" goto TESTHOSTS
if "%OPTION%"=="4" goto PORTSCAN
if "%OPTION%"=="5" goto FLUSHDNS
if "%OPTION%"=="6" goto RENEW
if "%OPTION%"=="7" goto RELEASE_RENEW
if "%OPTION%"=="8" goto FLUSHARP
if "%OPTION%"=="9" goto WINSOCK
if "%OPTION%"=="10" goto TCPRESET
if "%OPTION%"=="11" goto INTERNET
if "%OPTION%"=="12" goto DNS
if "%OPTION%"=="13" goto NETSTAT
if "%OPTION%"=="14" goto REPORT
if "%OPTION%"=="0" exit /b
echo.
echo Opcao invalida.
timeout /t 2 >nul
goto MENU
:: ============================================================
:: 1 - DIAGNOSTICO COMPLETO
:: ============================================================
:FULL
cls
echo ============================================================
echo                 DIAGNOSTICO COMPLETO
echo ============================================================
echo.
echo Computador : %COMPUTERNAME%
echo Usuario    : %USERNAME%
echo Data       : %DATE%
echo Hora       : %TIME%
echo.
echo ============================================================ > "%REPORT%"
echo NETDIAG WINDOWS >> "%REPORT%"
echo ============================================================ >> "%REPORT%"
echo Computador: %COMPUTERNAME% >> "%REPORT%"
echo Usuario: %USERNAME% >> "%REPORT%"
echo Data/Hora: %DATE% %TIME% >> "%REPORT%"
echo. >> "%REPORT%"
echo [1] CONFIGURACAO IP
echo ------------------------------------------------------------
ipconfig /all
echo [1] CONFIGURACAO IP >> "%REPORT%"
ipconfig /all >> "%REPORT%"
echo. >> "%REPORT%"
echo.
echo [2] LOOPBACK
echo ------------------------------------------------------------
ping -n 2 127.0.0.1
echo [2] LOOPBACK >> "%REPORT%"
ping -n 2 127.0.0.1 >> "%REPORT%"
echo. >> "%REPORT%"
echo.
echo [3] GATEWAY
echo ------------------------------------------------------------
for /f "tokens=2 delims=:" %%G in ('ipconfig ^| findstr /i "Gateway"') do (
    set "GATEWAY=%%G"
    set "GATEWAY=!GATEWAY: =!"
    if not "!GATEWAY!"=="" (
        echo Gateway: !GATEWAY!
        ping -n 2 -w 1500 !GATEWAY!
        echo Gateway: !GATEWAY! >> "%REPORT%"
        ping -n 2 -w 1500 !GATEWAY! >> "%REPORT%"
    )
)
echo.
echo [4] INTERNET
echo ------------------------------------------------------------
ping -n 3 -w 1500 1.1.1.1
echo [4] INTERNET >> "%REPORT%"
ping -n 3 -w 1500 1.1.1.1 >> "%REPORT%"
echo.
echo [5] DNS
echo ------------------------------------------------------------
ping -n 3 -w 1500 google.com
echo [5] DNS >> "%REPORT%"
ping -n 3 -w 1500 google.com >> "%REPORT%"
echo.
echo NSLOOKUP:
nslookup google.com
echo NSLOOKUP >> "%REPORT%"
nslookup google.com >> "%REPORT%"
echo.
echo [6] TABELA DE ROTAS
echo ------------------------------------------------------------
route print
echo [6] ROTAS >> "%REPORT%"
route print >> "%REPORT%"
echo.
echo [7] ARP
echo ------------------------------------------------------------
arp -a
echo [7] ARP >> "%REPORT%"
arp -a >> "%REPORT%"
echo.
echo [8] CONEXOES
echo ------------------------------------------------------------
netstat -ano
echo [8] NETSTAT >> "%REPORT%"
netstat -ano >> "%REPORT%"
echo.
echo [9] HTTPS
echo ------------------------------------------------------------
curl -I --connect-timeout 5 https://www.google.com
echo [9] HTTPS >> "%REPORT%"
curl -I --connect-timeout 5 https://www.google.com >> "%REPORT%" 2>&1
echo.
echo [10] DESCOBRINDO HOSTS
echo ------------------------------------------------------------
call :DISCOVER_FUNCTION
echo.
echo Diagnostico concluido.
echo Relatorio: %REPORT%
echo.
pause
goto MENU
:: ============================================================
:: 2 - DESCOBRIR HOSTS
:: ============================================================
:DISCOVER
cls
echo ============================================================
echo              DESCOBERTA DE HOSTS
echo ============================================================
echo.
call :DISCOVER_FUNCTION
echo.
pause
goto MENU
:: ============================================================
:: FUNCAO DE DESCOBERTA
:: ============================================================
:DISCOVER_FUNCTION
echo Obtendo configuracao da interface...
set "LOCAL_IP="
set "MASK="
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /i "IPv4"') do (
    set "LOCAL_IP=%%A"
    set "LOCAL_IP=!LOCAL_IP: =!"
    goto GOT_IP
)
:GOT_IP
echo IP local: !LOCAL_IP!
echo.
if "!LOCAL_IP!"=="" (
    echo [ERRO] Nao foi possivel obter o IPv4.
    exit /b
)
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /i "Mascara de Sub-rede"') do (
    set "MASK=%%A"
    set "MASK=!MASK: =!"
    goto GOT_MASK
)
:GOT_MASK
echo Mascara: !MASK!
echo.
:: ------------------------------------------------------------
:: Tenta descobrir a rede /24 a partir do IP.
:: Para redes domesticas comuns funciona muito bem.
:: ------------------------------------------------------------
for /f "tokens=1-4 delims=." %%A in ("!LOCAL_IP!") do (
    set "O1=%%A"
    set "O2=%%B"
    set "O3=%%C"
    set "O4=%%D"
)
set "NETWORK=!O1!.!O2!.!O3!"
echo Rede detectada: !NETWORK!.0/24
echo.
echo Fazendo varredura dos hosts...
echo Aguarde...
echo.
:: ------------------------------------------------------------
:: Ping sweep
:: ------------------------------------------------------------
for /L %%I in (1,1,254) do (
    ping -n 1 -w 80 !NETWORK!.%%I >nul
)
echo.
echo Tabela ARP atualizada:
echo ------------------------------------------------------------
arp -a
echo.
echo Hosts encontrados:
echo ------------------------------------------------------------
set /a COUNT=0
for /f "tokens=1,2,3" %%A in ('arp -a ^| findstr /r /c:"[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"') do (
    set "IP=%%A"
    set "MAC=%%B"
    set "TYPE=%%C"
    echo !IP!    !MAC!    !TYPE!
    set /a COUNT+=1
)
echo.
echo Hosts encontrados: !COUNT!
exit /b
:: ============================================================
:: 3 - TESTAR HOSTS
:: ============================================================
:TESTHOSTS
cls
echo ============================================================
echo                  TESTE DE HOSTS
echo ============================================================
echo.
for /f "tokens=1,2,3" %%A in ('arp -a ^| findstr /r /c:"[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"') do (
    set "IP=%%A"
    echo --------------------------------------------
    echo Testando !IP!
    echo --------------------------------------------
    ping -n 2 -w 1000 !IP!
    echo.
)
pause
goto MENU
:: ============================================================
:: 4 - TESTAR PORTAS
:: ============================================================
:PORTSCAN
cls
echo ============================================================
echo                    TESTE TCP
echo ============================================================
echo.
set /p "TARGET=Host/IP: "
set /p "PORT=Porta TCP: "
echo.
echo Testando !TARGET!:!PORT!
echo.
powershell -NoProfile -Command ^
"$r=Test-NetConnection -ComputerName '!TARGET!' -Port !PORT! -WarningAction SilentlyContinue; if($r.TcpTestSucceeded){Write-Host '[OPEN] Porta acessivel' -ForegroundColor Green}else{Write-Host '[CLOSED/FALHA] Porta inacessivel' -ForegroundColor Red}"
echo.
pause
goto MENU
:: ============================================================
:: 5 - FLUSH DNS
:: ============================================================
:FLUSHDNS
cls
echo ============================================================
echo                     FLUSH DNS
echo ============================================================
echo.
ipconfig /flushdns
echo.
echo Cache DNS limpo.
echo.
pause
goto MENU
:: ============================================================
:: 6 - RENEW DHCP
:: ============================================================
:RENEW
cls
echo ============================================================
echo                     RENEW DHCP
echo ============================================================
echo.
ipconfig /renew
echo.
echo DHCP renovado.
echo.
pause
goto MENU
:: ============================================================
:: 7 - RELEASE + RENEW
:: ============================================================
:RELEASE_RENEW
cls
echo ============================================================
echo                 RELEASE + RENEW DHCP
echo ============================================================
echo.
echo [1] Liberando endereco IP...
echo.
ipconfig /release
echo.
echo [2] Renovando endereco IP...
echo.
ipconfig /renew
echo.
echo Operacao concluida.
echo.
pause
goto MENU
:: ============================================================
:: 8 - LIMPAR ARP
:: ============================================================
:FLUSHARP
cls
echo ============================================================
echo                    LIMPAR ARP
echo ============================================================
echo.
arp -d *
echo.
echo Cache ARP limpo.
echo.
pause
goto MENU
:: ============================================================
:: 9 - WINSOCK
:: ============================================================
:WINSOCK
cls
echo ============================================================
echo                  RESET WINSOCK
echo ============================================================
echo.
echo Esta operacao pode exigir reinicializacao do Windows.
echo.
choice /c SN /n /m "Continuar? [S/N]: "
if errorlevel 2 goto MENU
netsh winsock reset
echo.
echo Winsock resetado.
echo Reinicie o computador para aplicar completamente.
echo.
pause
goto MENU
:: ============================================================
:: 10 - TCP/IP
:: ============================================================
:TCPRESET
cls
echo ============================================================
echo                   RESET TCP/IP
echo ============================================================
echo.
echo Esta operacao pode alterar a configuracao da rede.
echo.
choice /c SN /n /m "Continuar? [S/N]: "
if errorlevel 2 goto MENU
netsh int ip reset
echo.
echo TCP/IP resetado.
echo Reinicie o computador para aplicar completamente.
echo.
pause
goto MENU
:: ============================================================
:: 11 - INTERNET
:: ============================================================
:INTERNET
cls
echo ============================================================
echo                 TESTE DE INTERNET
echo ============================================================
echo.
echo [1] IP externo:
ping -n 3 1.1.1.1
echo.
echo [2] DNS:
ping -n 3 google.com
echo.
echo [3] HTTPS:
curl -I --connect-timeout 5 https://www.google.com
echo.
pause
goto MENU
:: ============================================================
:: 12 - DNS
:: ============================================================
:DNS
cls
echo ============================================================
echo                     TESTE DNS
echo ============================================================
echo.
set /p "DOMAIN=Dominio para testar: "
echo.
echo NSLOOKUP:
nslookup !DOMAIN!
echo.
echo PING:
ping -n 3 !DOMAIN!
echo.
pause
goto MENU
:: ============================================================
:: 13 - NETSTAT
:: ============================================================
:NETSTAT
cls
echo ============================================================
echo              CONEXOES E PORTAS LOCAIS
echo ============================================================
echo.
netstat -ano
echo.
echo ------------------------------------------------------------
echo Apenas portas em LISTENING:
echo ------------------------------------------------------------
netstat -ano | findstr LISTENING
echo.
pause
goto MENU
:: ============================================================
:: 14 - RELATORIO
:: ============================================================
:REPORT
cls
echo ============================================================
echo               GERANDO RELATORIO
echo ============================================================
echo.
echo Gerando %REPORT%...
echo.
echo ============================================================ > "%REPORT%"
echo NETDIAG WINDOWS >> "%REPORT%"
echo ============================================================ >> "%REPORT%"
echo Computador: %COMPUTERNAME% >> "%REPORT%"
echo Usuario: %USERNAME% >> "%REPORT%"
echo Data/Hora: %DATE% %TIME% >> "%REPORT%"
echo. >> "%REPORT%"
echo ===== IP CONFIG ===== >> "%REPORT%"
ipconfig /all >> "%REPORT%"
echo. >> "%REPORT%"
echo ===== ROUTE ===== >> "%REPORT%"
route print >> "%REPORT%"
echo. >> "%REPORT%"
echo ===== ARP ===== >> "%REPORT%"
arp -a >> "%REPORT%"
echo. >> "%REPORT%"
echo ===== NETSTAT ===== >> "%REPORT%"
netstat -ano >> "%REPORT%"
echo. >> "%REPORT%"
echo ===== DNS ===== >> "%REPORT%"
nslookup google.com >> "%REPORT%"
echo. >> "%REPORT%"
echo ===== INTERNET ===== >> "%REPORT%"
ping -n 3 1.1.1.1 >> "%REPORT%"
echo.
echo Relatorio criado:
echo %REPORT%
echo.
pause
goto MENU
