#!/bin/bash
# instalar.sh — Configura el servidor SSA en Debian
# Ejecutar con: bash instalar.sh

GREEN='\033[92m'
CYAN='\033[96m'
YELLOW='\033[93m'
BOLD='\033[1m'
RESET='\033[0m'

echo ""
echo -e "${BOLD}================================================${RESET}"
echo -e "  ${GREEN}SSA — Instalador para Debian${RESET}"
echo -e "${BOLD}================================================${RESET}"

# 1. Actualizar e instalar Python y pip
echo -e "\n${CYAN}[1/3] Instalando dependencias del sistema...${RESET}"
sudo apt update -q && sudo apt install -y python3 python3-pip

# 2. Instalar Flask
echo -e "\n${CYAN}[2/3] Instalando Flask...${RESET}"
pip3 install flask werkzeug --break-system-packages

# 3. Verificar estructura
echo -e "\n${CYAN}[3/3] Verificando archivos...${RESET}"
FILES=("app.py" "templates/login.html" "templates/dashboard.html")
ALL_OK=true
for f in "${FILES[@]}"; do
  if [ -f "$f" ]; then
    echo -e "  ${GREEN}✓${RESET} $f"
  else
    echo -e "  ✗ FALTA: $f"
    ALL_OK=false
  fi
done

if [ "$ALL_OK" = false ]; then
  echo -e "\n${YELLOW}Faltan archivos. Asegúrate de copiar todos los archivos en el mismo directorio.${RESET}"
  exit 1
fi

# Obtener IP del servidor
IP=$(hostname -I | awk '{print $1}')

echo ""
echo -e "${BOLD}================================================${RESET}"
echo -e "  ${GREEN}Instalación completa.${RESET}"
echo -e "${BOLD}================================================${RESET}"
echo -e "  Iniciar servidor:"
echo -e "    ${CYAN}source venv/bin/activate${RESET}"
echo -e "    ${CYAN}python3 app.py${RESET}"
echo -e ""
echo -e "  Acceso Windows:  ${CYAN}http://${IP}:5000${RESET}"
echo -e ""
echo -e "  Usuarios de demo:"
echo -e "    alexander@ssa.umsa.bo  / umsa2024"
echo -e "    mquispe@ssa.umsa.bo    / infosecure"
echo -e "    cmamani@ssa.umsa.bo    / carrera123"
echo -e "${BOLD}================================================${RESET}"
echo ""