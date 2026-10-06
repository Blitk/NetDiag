NetDiag Windows

Ferramenta de diagnóstico, descoberta e manutenção de rede para Windows desenvolvida em Batch Script (.bat).

O NetDiag reúne em um único utilitário diversos comandos nativos do Windows para investigar problemas de conectividade, identificar hosts na rede local, testar portas TCP e executar procedimentos comuns de manutenção da rede.

Funcionalidades

Diagnóstico

* Informações completas de IP e adaptadores com ipconfig
* Teste de loopback (127.0.0.1)
* Identificação e teste do gateway
* Teste de conectividade com a Internet
* Teste de resolução DNS
* Consulta DNS com nslookup
* Visualização da tabela de roteamento
* Visualização da tabela ARP
* Visualização de conexões com netstat
* Teste HTTP/HTTPS com curl
* Geração de relatório .txt

Descoberta de hosts

O NetDiag pode utilizar a tabela ARP para identificar dispositivos presentes na rede local.

O processo de descoberta é:

IP local
   ↓
Identificação da rede
   ↓
Ping sweep
   ↓
Tabela ARP
   ↓
Hosts encontrados
   ↓
Teste de conectividade

São exibidas informações como:

IP              MAC Address          Tipo
192.168.1.1     AA-BB-CC-DD-EE-01    dynamic
192.168.1.10    AA-BB-CC-DD-EE-02    dynamic
192.168.1.20    AA-BB-CC-DD-EE-03    dynamic

A descoberta baseada em ARP não garante que todos os dispositivos da rede sejam encontrados. Um dispositivo pode não aparecer na tabela ARP até que exista comunicação com ele.

Teste de portas TCP

É possível testar uma porta TCP específica utilizando Test-NetConnection do PowerShell.

Exemplo:

Host/IP: 192.168.1.20
Porta: 8080
[OPEN] Porta acessivel

Ou:

[CLOSED/FALHA] Porta inacessivel

Isso é diferente de um simples ping.

Um host pode bloquear ICMP e ainda possuir serviços TCP acessíveis.

Ferramentas de manutenção

O menu também disponibiliza algumas ferramentas nativas do Windows:

Flush DNS

ipconfig /flushdns

Limpa o cache local de resolução DNS.

Renovar DHCP

ipconfig /renew

Solicita uma nova configuração de rede ao servidor DHCP.

Release + Renew

ipconfig /release
ipconfig /renew

Libera o endereço DHCP atual e solicita outro.

Limpar ARP

arp -d *

Remove as entradas da tabela ARP.

Reset Winsock

netsh winsock reset

Pode ajudar em problemas relacionados à camada Winsock.

Pode ser necessário reiniciar o Windows após executar esse comando.

Reset TCP/IP

netsh int ip reset

Reinicializa componentes da configuração TCP/IP.

Pode ser necessário reiniciar o Windows após executar esse comando.

Menu

Ao executar o programa:

============================================================
                    NETDIAG WINDOWS
============================================================
 [1] Diagnostico completo
 [2] Descobrir hosts da rede local
 [3] Testar hosts encontrados
 [4] Testar portas TCP
------------------------------------------------------------
 [5] Flush DNS
 [6] Renew DHCP
 [7] Release + Renew DHCP
 [8] Limpar cache ARP
 [9] Resetar Winsock
[10] Resetar TCP/IP
------------------------------------------------------------
[11] Teste rapido de Internet
[12] Teste de DNS
[13] Ver conexoes e portas locais
[14] Gerar relatorio completo
------------------------------------------------------------
 [0] Sair
============================================================

Requisitos

* Windows 10 ou superior
* Prompt de Comando (cmd.exe)
* PowerShell
* Privilégios de administrador

Algumas funcionalidades utilizam ferramentas nativas:

ipconfig
ping
arp
route
netstat
nslookup
curl
netsh
PowerShell
Test-NetConnection

Não é necessário instalar bibliotecas externas.

Execução

Baixe ou clone o projeto.

Execute:

NetDiag.bat

Para utilizar todas as funcionalidades, principalmente as relacionadas à manutenção da rede, execute o arquivo como Administrador.

Pelo CMD

NetDiag.bat

Como administrador

Clique com o botão direito no arquivo:

NetDiag.bat
    ↓
Executar como administrador

Relatórios

O diagnóstico pode gerar automaticamente um relatório:

NetDiag_NOME-DO-PC.txt

O relatório pode conter:

* Configuração dos adaptadores
* Endereços IP
* Gateway
* DNS
* Rotas
* ARP
* Conexões TCP/UDP
* Resolução DNS
* Teste de Internet

O arquivo é salvo no mesmo diretório do .bat.

Exemplo de uso

Imagine que a Internet esteja lenta ou que uma aplicação não consiga se conectar.

Uma sequência de diagnóstico pode ser:

1. Diagnóstico completo
        ↓
2. Verificar gateway
        ↓
3. Testar 1.1.1.1
        ↓
4. Testar DNS
        ↓
5. Descobrir hosts
        ↓
6. Testar a porta da aplicação
        ↓
7. Flush DNS / Renew DHCP
        ↓
8. Repetir os testes

Isso permite diferenciar problemas como:

Computador
    │
    ├── TCP/IP local
    │
    ├── Gateway
    │
    ├── Rede local
    │
    ├── DNS
    │
    └── Internet

Limitações

O NetDiag foi desenvolvido para diagnóstico e manutenção, não como substituto de ferramentas especializadas como Nmap, Wireshark ou ferramentas profissionais de gerenciamento de rede.

A descoberta automática atualmente trabalha principalmente com redes locais IPv4 e utiliza ARP/ping para encontrar hosts.

Dispositivos que bloqueiam ICMP podem não responder ao ping mesmo estando ativos.

Segurança

O NetDiag não realiza exploração de vulnerabilidades.

Os testes de portas devem ser utilizados somente em redes e sistemas nos quais você possui autorização para realizar diagnóstico.

Os comandos de reset de rede podem alterar temporariamente a conectividade do computador.

Estrutura

NetDiag/
│
├── NetDiag.bat
├── README.md
└── reports/
    └── NetDiag_NOME-DO-PC.txt

Objetivo

O projeto tem como objetivo criar uma ferramenta simples, portátil e transparente para troubleshooting de redes no Windows, utilizando ferramentas que já fazem parte do sistema operacional.

A ideia é transformar vários comandos normalmente executados manualmente em uma única interface de diagnóstico.

Tecnologias

* Batch Script
* Windows CMD
* PowerShell
* TCP/IP
* DNS
* DHCP
* ARP
* ICMP
* TCP

Autor

Raphael Rodrigues Oliveira

Desenvolvedor de Software

GitHub: Blitk

⸻

NetDiag — Diagnose first. Fix second.
