## Guía rápida para iniciar las máquinas y servicios

### 1. Iniciar el servidor (Debian)
En la terminal de Debian, ejecuta:
```bash
cd /home/villa/Escritorio/banco
source venv/bin/activate
python app.py
```

### 2. Iniciar el ataque (Kali)
En la terminal de Kali, ejecuta:
```bash
sudo bash mitm_attack.sh
```

### 3. Probar acceso desde la víctima (Windows)
En el navegador de Windows, accede a:
```
http://192.168.0.8:5000/login
```

