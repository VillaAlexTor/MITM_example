## Práctica 2 – Hacking Ético: Ataque MITM (Man-in-the-Middle)

### Introducción
Esta práctica tiene como objetivo interceptar la comunicación entre un servidor y un usuario legítimo mediante un ataque Man-in-the-Middle (MITM), con el fin de capturar credenciales y acceder de forma no autorizada al sistema. Para ello, se utilizarán tres máquinas virtuales:

- **Kali Linux:** Atacante
- **Windows:** Víctima
- **Debian:** Servidor

Este laboratorio permitirá comprender el funcionamiento de un ataque MITM y las medidas necesarias para prevenirlo en entornos reales. En este escenario
- El usuario legítimo envía una petición al servidor, pero sin saberlo, dicha petición también es interceptada por el atacante. 
- De igual manera, la respuesta del servidor al cliente es capturada por el atacante, quien puede escuchar y manipular la comunicación entre ambos.


---

### Conceptos Clave

- **¿Por qué usar modo Bridge y no NAT?**
    - En modo NAT, las máquinas virtuales están en una red interna separada y no pueden interactuar directamente con otros dispositivos de la red física, lo que dificulta realizar ataques de red como MITM. En cambio, el modo Bridge conecta las máquinas virtuales directamente a la red física, permitiendo que todas tengan direcciones IP en el mismo segmento y puedan comunicarse entre sí como si fueran dispositivos reales de la red. Esto es fundamental para que el atacante pueda interceptar el tráfico entre la víctima y el servidor.

- **ARP Poisoning (Envenenamiento ARP):** Ciberataque en una red local donde un atacante engaña a los dispositivos, asociando su propia dirección MAC con la dirección IP de otro equipo (por ejemplo, el servidor), logrando desviar, interceptar o bloquear el tráfico de datos.
    - Kali le informa a Debian que la solicitud proviene de la IP de Windows.
    - De igual manera, Kali le dice a Windows que la respuesta proviene de la IP del servidor.
    - Así, nadie se da cuenta del robo de información.

- **Flask:** Micro-framework web de código abierto escrito en Python. Es ligero y minimalista, ideal para construir aplicaciones web de manera sencilla.

- **mitmproxy:** Herramienta gratuita y de código abierto que actúa como proxy intermediario. Permite interceptar e inspeccionar conexiones HTTP en tiempo real.


---
### Pasos para realizar el ataque MITM

1. **Preparar las máquinas virtuales:**
     - Kali Linux (Atacante)
     - Windows 10 (Víctima)
     - Debian 13 (Servidor)

2. **Configurar la red:**
     - Establecer el adaptador de red en modo "Bridged (Puente)" para todas las máquinas.
     - Editar configuración de maquina virtual -> Adaptador de red -> y seleccionar Conexión en puente: Conectado directamente a la red física.
     - Asegurarse de que todas estén conectadas al mismo punto de red (WiFi o cableada).

3. **Verificar la conectividad:**
     - Obtener las IPs de cada máquina:
         - Kali: `ifconfig` `192.168.0.9`
         - Windows: `ipconfig` `192.168.0.11`
         - Debian: `ip a` `192.168.0.8`
     - Hacer ping entre las máquinas para comprobar la comunicación.

4. **Configurar el servidor (Debian):**
     - Crear y activar un entorno virtual:
         ```bash
         source venv/bin/activate
         ```
     - Instalar Flask y Werkzeug:
         ```bash
         pip install flask werkzeug
         ```
     - Verificar la instalación:
         ```bash
         python3 -m flask --version
         ```

5. **Configurar el atacante (Kali):**
     - Instalar mitmproxy:
         ```bash
         sudo apt install mitmproxy -y
         ```
     - Verificar la instalación:
         ```bash
         mitmproxy --version
         ```
     - Probar la interfaz web:
         ```bash
         mitmweb --listen-host 0.0.0.0 --listen-port 8080
         ```

6. **Configurar el proxy en Windows:**
     - Ir a Configuración → Red e Internet → Proxy.
     - Activar "Usar servidor proxy".
     - Introducir la IP de Kali y el puerto 8080.
     - Guardar los cambios.

7. **Instalar el certificado de mitmproxy en Windows:**
     - Navegar a [http://mitm.it](http://mitm.it) desde Windows.
     - Descargar e instalar el certificado para el equipo local.
     - Seleccionar "Colocar todos los certificados en el siguiente almacén" y elegir "Entidades de certificación raíz de confianza".

8. **Iniciar los servicios:**
     - En Debian:
         ```bash
         source venv/bin/activate
         python app.py
         ```
     - En Kali:
         ```bash
         sudo bash mitm_attack.sh
         ```
     - En Windows:
        - Ingresar el URL dada por el servidor

---
### Conclusión

Esta práctica demuestra cómo un atacante puede interceptar y manipular la comunicación entre un cliente y un servidor mediante un ataque MITM. Es fundamental implementar medidas de seguridad como el uso de HTTPS, segmentación de red y monitoreo constante para prevenir este tipo de ataques en entornos reales.