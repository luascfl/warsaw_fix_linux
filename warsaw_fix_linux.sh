#!/bin/bash

# ---
# título: correção de compatibilidade do warsaw (lubuntu 25.10)
# descrição: instala o execstack, aplica o ajuste no binário e reinicia o serviço.
# ---

set -e

# cores para feedback
verde='\033[0;32m'
azul='\033[0;34m'
nc='\033[0m'

echo -e "${azul}iniciando o processo de correção do warsaw...${nc}"

# 1. verificação e instalação do execstack
if ! command -v execstack &> /dev/null; then
    echo "instalando o utilitário execstack..."
    # baixa a versão compatível do repositório da versão 24.04
    wget -q --show-progress http://mirrors.kernel.org/ubuntu/pool/universe/p/prelink/execstack_0.0.20131005-1.1_amd64.deb
    sudo apt install -y ./execstack_0.0.20131005-1.1_amd64.deb
    rm execstack_0.0.20131005-1.1_amd64.deb
else
    echo "o execstack já está instalado."
fi

# 2. aplicação da correção no binário core
echo "aplicando ajuste de memória no arquivo core..."
if [ -f /usr/local/bin/warsaw/core ]; then
    sudo execstack -s /usr/local/bin/warsaw/core
    echo -e "${verde}ajuste aplicado com sucesso.${nc}"
else
    echo "erro: arquivo /usr/local/bin/warsaw/core não encontrado."
    exit 1
fi

# 3. reinicialização do serviço
echo "reiniciando o serviço warsaw..."
sudo systemctl restart warsaw

# 4. verificação final
echo -e "\n${azul}verificando o status do serviço:${nc}"
systemctl status warsaw --no-pager

echo -e "\n===================================================="
echo -e "${verde}processo concluído!${nc}"
echo "agora você pode abrir o chromium e acessar o site do banco."
echo "lembre-se de configurar a flag se o problema persistir:"
echo "chrome://flags/#block-insecure-private-network-requests -> disabled"
echo "===================================================="
