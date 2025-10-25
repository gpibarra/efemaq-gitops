#!/bin/bash

## ./provision/setup.sh 


# Script de configuración inicial para Ansible

set -e
set -u
set -o pipefail

cd "$(dirname "$0")"

echo "==================================="
echo "Configuración Inicial de Ansible"
echo "==================================="
echo ""

# Verificar que Ansible esté instalado
if ! command -v ansible &> /dev/null; then
    echo "Error: Ansible no está instalado."
    echo "Por favor instala Ansible primero:"
    echo "  Ubuntu/Debian: sudo apt install ansible"
    echo "  macOS: brew install ansible"
    echo "  pip: pip install ansible"
    exit 1
fi

echo "✓ Ansible encontrado: $(ansible --version | head -1)"
echo ""

# Instalar colecciones requeridas
echo "Instalando colecciones de Ansible..."
ansible-galaxy collection install -r requirements.yml

echo ""
echo "✓ Colecciones instaladas correctamente"
echo ""

# Instalar paquetes Python necesarios
echo "Instalando paquetes Python necesarios..."

# Detectar si el sistema usa externally-managed-environment
if pip3 install --help 2>&1 | grep -q "break-system-packages"; then
    echo "Sistema con Python externally-managed detectado."
    echo "Instalando paquetes con --break-system-packages..."
    pip3 install --break-system-packages ansible-lint
else
    # Intentar instalación normal primero
    if ! pip3 install --user ansible-lint 2>/dev/null; then
        echo "Instalación normal falló, usando --break-system-packages..."
        pip3 install --break-system-packages ansible-lint
    fi
fi

echo ""
echo "✓ Paquetes Python instalados"
echo ""


# Verificar sintaxis del playbook principal
echo "Verificando sintaxis de playbooks..."
ansible-playbook site.yml --syntax-check

echo ""
echo "✓ Sintaxis verificada correctamente"
echo ""

echo "==================================="
echo "Configuración completada!"
echo "==================================="
echo ""
echo "Próximos pasos:"
echo "1. Edita inventories/test/hosts.yml con la IP de tu servidor de test"
echo "2. Edita inventories/production/hosts.yml con las IPs de producción"
echo "3. Configura las variables en group_vars/ según tus necesidades"
echo "4. Prueba la conectividad: ansible all -i inventories/test/hosts.yml -m ping"
echo "5. Despliega en test: ansible-playbook -i inventories/test/hosts.yml site.yml"
echo ""
echo "Para más información, lee el README.md"
echo ""

cd - > /dev/null
