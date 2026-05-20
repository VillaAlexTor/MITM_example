-----------------------------------------------------------
Practica 2 – Hacking Etico Ataque MITM (Man-in-the-Middle)
-----------------------------------------------------------
El objetivo de esta práctica es interceptar la comunicación entre un servidor y un usuario legítimo mediante un ataque Man-in-the-Middle (MITM), con el fin de capturar credenciales y acceder de forma no autorizada al sistema. Para ello, se utilizarán tres máquinas virtuales:
    - Kali Linux: Atacante
    - Windows: Víctima
    - Debian: Servidor
Esta práctica permitirá comprender el funcionamiento de un ataque MITM y las medidas necesarias para prevenirlo en entornos reales. En este escenario, el usuario legítimo envía una petición al servidor, pero sin saberlo, dicha petición también es interceptada por el atacante. De igual manera, la respuesta del servidor al cliente es capturada por el atacante, quien puede escuchar y manipular la comunicación entre ambos.

CONCEPTOS CLAVE:

• ARP Poisoning (Envenenamiento ARP): Es un ciberataque en una red local donde un atacante engaña a los dispositivos, asociando su propia dirección MAC con la dirección IP de otro equipo (por ejemplo, el servidor). Así, logra desviar, interceptar o bloquear el tráfico de datos.
 - Kali le informa a Debian que la solicitud proviene de la IP de Windows.
 - De igual manera, Kali le dice a Windows que la respuesta proviene de la IP del servidor.
De este modo, nadie se da cuenta del robo de información.

• Flask: Es un micro-framework web de código abierto escrito en Python. Es ligero y minimalista, ideal para construir aplicaciones web de manera sencilla.

• mitmproxy: Es una herramienta gratuita y de código abierto que actúa como proxy intermediario. Permite interceptar e inspeccionar conexiones HTTP en tiempo real.

PASOS:

    1. Preparar las maquinas virtuales:
        • Kali Linux -> Como atacante
        • Windows 10 -> Como victima
        • Debian 13 -> Como servidor
    2. Configurar la red:
        • Configurar adaptador de red como (Bridged (Puente)) para todas las maquinas.
        • Editar configuración de maquina virtual -> Adaptador de red -> y seleccionar Conexión en puente: Conectado directamente a la red física.
        • Asegurarse de que todas estén conectadas al mismo punto de red (WiFi o cableada).
    3. Verificar que las VM’s se comunican y que están en la misma red
        • Ifconfig -> 192.168.0.9 (KALI)
        • Ipconfig -> 192.168.0.11 (WINDOWS)
        • Ip a -> 192.168.0.8 (DEBIAN)
        • Hacer ping entre las maquinas para comprobar la comunicacion
    4. Instalar entorno virtual dentro de debian y descargar Flask
        • source venv/bin/actívate
        • pip install flask werkzeug
        • Verificamos versión -> python3 -m flask --version
    5. Descargar mitmproxy en kali
        • sudo apt install mitmproxy -y
        • verificar la descarga -> mitmproxy --version
        • verificamos -> mitmweb --listen-host 0.0.0.0 --listen-port 8080
    6. Seleccionar el proxy en Windows 
        • Configuración -> Internet y red -> Proxy 
        • Usar servidor proxy lo ACTIVAMOS
        • Con la IP de Kali y el puerto 8080
        • Y guardamos 
        • Cuando configuras un proxy en Windows, le estás diciendo al sistema operativo: "no te conectes directamente a internet, manda todo el tráfico a esta dirección primero".
    7. Instalar el certificado de mitmproxy en Windows navegamos a -> http://mitm.it
        • Seleccionamos equipo local 
        • No ponemos contraseña 
        • Y ponemos “Colocar todos los certificados en el siguiente almacén”
        • Clic en Examinar → seleccionar "Entidades de certificación raíz de confianza"
        • Y finalizar
    8. Levantamos el servicio en debian
        • source venv/bin/actívate
        • python app.py
    9.	Levantamos el servicio en Kali
        • sudo bash mitm_attack.sh
