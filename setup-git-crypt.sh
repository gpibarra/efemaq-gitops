#!/bin/bash
# Script para configurar git-crypt en este repositorio

set -e  # Exit on error

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "🔐 Git-Crypt Setup Script"
echo "================================================"
echo ""

# Verificar que git-crypt está instalado
if ! command -v git-crypt &> /dev/null; then
    echo -e "${RED}❌ Error: git-crypt no está instalado${NC}"
    echo ""
    echo "Instala git-crypt:"
    echo "  Ubuntu/Debian: sudo apt-get install git-crypt"
    echo "  macOS: brew install git-crypt"
    echo "  Arch: sudo pacman -S git-crypt"
    exit 1
fi

echo -e "${GREEN}✅ git-crypt está instalado${NC}"
echo "   Versión: $(git-crypt --version)"
echo ""

# Verificar que estamos en un repo git
if [ ! -d .git ]; then
    echo -e "${RED}❌ Error: No estás en un repositorio Git${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Repositorio Git detectado${NC}"
echo ""

# Verificar si ya está inicializado
if [ -d .git/git-crypt ]; then
    echo -e "${YELLOW}⚠️  git-crypt ya está inicializado en este repo${NC}"
    echo ""
    read -p "¿Eres un nuevo usuario que necesita desbloquear? (s/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[SsYy]$ ]]; then
        echo ""
        echo "Para desbloquear el repositorio:"
        echo "1. Obtén el archivo 'git-crypt-key' del administrador"
        echo "2. Ejecuta: git-crypt unlock /path/to/git-crypt-key"
        echo ""
        exit 0
    else
        echo ""
        echo "El repositorio ya está configurado. No se requiere acción."
        exit 0
    fi
fi

# Inicializar git-crypt
echo "🔧 Inicializando git-crypt..."
git-crypt init
echo -e "${GREEN}✅ git-crypt inicializado${NC}"
echo ""

# Exportar key
KEY_FILE="$HOME/git-crypt-key-$(date +%Y%m%d)"
echo "🔑 Exportando key de encriptación..."
git-crypt export-key "$KEY_FILE"
echo -e "${GREEN}✅ Key exportada a: ${KEY_FILE}${NC}"
echo ""

# Verificar estado
echo "🔍 Verificando archivos encriptados..."
git-crypt status -e | head -n 10
echo ""

# Instrucciones finales
echo "================================================"
echo -e "${GREEN}✅ ¡Setup completado!${NC}"
echo "================================================"
echo ""
echo "⚠️  IMPORTANTE - Guarda la key de forma segura:"
echo "   Archivo: ${KEY_FILE}"
echo ""
echo "📝 Sugerencias para guardar la key:"
echo "   1. 1Password / LastPass"
echo "   2. USB encriptado"
echo "   3. Backup en la nube encriptado"
echo "   ❌ NO la subas a Git"
echo "   ❌ NO la envíes por email sin encriptar"
echo ""
echo "👥 Para compartir acceso con el equipo:"
echo "   1. Comparte el archivo: ${KEY_FILE}"
echo "   2. Ellos ejecutan: git-crypt unlock /path/to/key"
echo ""
echo "📖 Documentación completa: GIT-CRYPT-SETUP.md"
echo ""
echo "🎉 Ya puedes editar los archivos secrets.yml"
echo "   Se encriptarán automáticamente al hacer commit"
echo ""
