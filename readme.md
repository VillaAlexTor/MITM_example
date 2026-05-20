-----------------------------------------------------------
Practica 2 – Hacking Etico Ataque MITM (Man-in-the-Middle)
-----------------------------------------------------------
Se quiere lograr intervenir la conexion de un servidor con un usuario normal, lo que se conoce como Man-in-the-Middle, asi poder robar credenciales para ingresar al dicho sistema de manera maliciosa. Para esto, tendremos 3 maquinas virtuales
    - Kali Linux -> Atacante
    - Windows -> Victima
    - Debian -> Servidor 
CONCEPTOS CLAVES:
• El ARP Poisoning (o Envenenamiento ARP) es un ciberataque en una red de área local, donde un hacker engaña a los dispositivos. Su objetivo es asociar su propia dirección física (MAC) con la dirección IP de otro equipo (como el servidor), logrando desviar, interceptar o bloquear todo el tráfico de datos. Entonces Kali le dice a debian que la solicitad es parte de la Ip de Windows, y asi también Kali le dice a Windows que es respuesta es de la ip del servidor.
• Flask es un micro-framework web de código abierto escrito en Python. Es ligero y minimalista, que nos ayuda a construir una aplicacion web.
• Mimtproxy es una herramienta gratuita y de código abierto que actúa como un proxy intermediario. Permite interceptar, inspeccionar conexiones en este caso HTTP en tiempo real.
1.	Primer paso tener lista dos maquinas 
•	Kali Linux -> Como atacante
•	Windows 10 -> Como victima
•	Debian 13 -> Como servidor
2.	Configurar adaptador de red como (Bridged (Puente)), y que estén conectados las dos bajo el mismo punto wifi.
•	Editar configuración de maquina virtual -> Adaptador de red -> y seleccionar Conexión en puente: Conectado directamente a la red física
3.	Verificar que las VM’s se comunican y que están en la misma red
•	Ifconfig -> 192.168.0.9 (KALI)
•	Ipconfig -> 192.168.0.11 (WINDOWS)
•	Ip a -> 192.168.0.8 (DEBIAN)
•	Hacer ping desde Windows a kali (Para verificar conexiones)
4.	Instalar entorno virtual dentro de debian y descargar Flask
•	source venv/bin/actívate
•	pip install flask werkzeug
•	Verificamos versión -> python3 -m flask --version
5.	Descargar mitmproxy en kali
•	sudo apt install mitmproxy -y
•	verificar la descarga -> mitmproxy --version
•	verificamos -> mitmweb --listen-host 0.0.0.0 --listen-port 8080
6.	Seleccionar el proxy en Windows 
•	Configuración -> Internet y red -> Proxy 
•	Usar servidor proxy lo ACTIVAMOS
•	Con la IP de Kali y el puerto 8080
•	Y guardamos 
•	Cuando configuras un proxy en Windows, le estás diciendo al sistema operativo: "no te conectes directamente a internet, manda todo el tráfico a esta dirección primero".
7.	Instalar el certificado de mit en Windows navegamos a -> http://mitm.it
•	Seleccionamos equipo local 
•	No ponemos contraseña 
•	Y ponemos “Colocar todos los certificados en el siguiente almacén”
•	Clic en Examinar → seleccionar "Entidades de certificación raíz de confianza"
•	Y finalizar
8.	Levantamos el servicio en debian
•	source venv/bin/actívate
•	python app.py
9.	Levantamos el servicio en Kali
•	sudo bash mitm_attack.sh
