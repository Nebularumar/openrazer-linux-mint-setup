# OpenRazer Linux Mint 21.3 Setup

Instalador automatizado para **OpenRazer v3.12.3** en Linux Mint 21.3 con configuración correcta de permisos y GUI Polychromatic.

## ¿Qué problema resuelve?

La instalación de OpenRazer en Linux Mint 21.3 es compleja porque requiere:
- Compilar módulos DKMS del kernel
- Configurar reglas udev correctamente
- Establecer permisos específicos en archivos virtuales `/sys/bus/hid/drivers/`
- Mantener estos permisos persistentes entre reinicios

Este script automatiza todo el proceso en un solo comando.

## Dispositivos soportados

✅ **Teclados Razer:**
- Huntsman Tournament Edition
- Huntsman V3
- DeathStalker V2
- Y otros modelos Razer soportados por OpenRazer

✅ **Ratones Razer:**
- Viper (wired y wireless)
- DeathAdder
- BasiliskV3
- Y otros modelos Razer

✅ **Otros periféricos:**
- Auriculares Kraken
- Accesorios Razer

## Requisitos

- **OS:** Linux Mint 21.3 (basada en Ubuntu 22.04)
- **Kernel:** 5.15 o superior
- **Permisos:** sudo
- **Conexión:** Acceso a internet para descargar paquetes

## Instalación rápida

```bash
curl -fsSL https://raw.githubusercontent.com/Nebularumar/openrazer-linux-mint-setup/main/install.sh | bash
```

O instalación manual:

```bash
git clone https://github.com/Nebularumar/openrazer-linux-mint-setup.git
cd openrazer-linux-mint-setup
chmod +x install.sh
./install.sh
```

## ¿Qué hace el script?

1. ✅ Remueve versiones antiguas de OpenRazer
2. ✅ Agrega PPA openrazer/stable
3. ✅ Instala OpenRazer v3.12.3
4. ✅ Compila módulos DKMS del kernel
5. ✅ Recarga reglas udev
6. ✅ **Corrige permisos en /sys/bus/hid/drivers/** (el paso crítico que falta en la mayoría de guías)
7. ✅ Crea servicio systemd para mantener permisos persistentes
8. ✅ Instala Polychromatic (GUI)
9. ✅ Agrega tu usuario al grupo plugdev

## Después de la instalación

### Lanzar Polychromatic (GUI)
```bash
polychromatic-controller
```

### Usar CLI
```bash
# Ver dispositivos
razer-cli --list-devices

# Controlar colores, DPI, etc.
openrazer-daemon
```

### Reiniciar el daemon
Si los dispositivos dejan de responder:
```bash
sudo systemctl restart openrazer-daemon
```

## Verificación

Después de instalar, verifica:

```bash
# Daemon corriendo
ps aux | grep openrazer-daemon

# Dispositivos detectados
lsusb | grep -i razer

# Permisos correctos
ls -la /sys/bus/hid/drivers/razerkbd/bind
# Debe mostrar: --w--w---- root:plugdev
```

## Solución de problemas

### "Device can be accessed using plugdev permissions is failing"
Este script ya lo soluciona. Si persiste después de instalar:
```bash
sudo systemctl restart openrazer-daemon
sudo systemctl restart openrazer-permissions.service
```

### Los dispositivos no se detectan
```bash
# 1. Replug el dispositivo (desconecta y reconecta)
# 2. Reinicia el daemon
sudo systemctl restart openrazer-daemon

# 3. Verifica que el kernel lo ve
lsusb | grep -i razer
```

### Polychromatic no abre
```bash
# Instala dependencias gráficas faltantes
sudo apt install libxcb-cursor0 libxcb-xkb1

# Reinicia Polychromatic
pkill polychromatic-controller
polychromatic-controller
```

## Desinstalación

Para remover OpenRazer:
```bash
sudo apt remove -y openrazer-daemon openrazer-driver-dkms openrazer-meta python3-openrazer polychromatic
sudo systemctl disable openrazer-permissions.service
sudo rm /etc/systemd/system/openrazer-permissions.service
sudo systemctl daemon-reload
```

## Notas técnicas

### ¿Por qué son necesarios los permisos especiales?
Los archivos en `/sys/bus/hid/drivers/razerkbd/bind` y similares son archivos virtuales del kernel que se generan dinámicamente cuando se carga el módulo. Las reglas udev estándar no pueden afectar su permisología, por lo que se necesita un servicio systemd que los corrija después de cada boot.

### Compatibilidad con otras distros
Este script está optimizado para **Linux Mint 21.3**. Para otras distros:
- **Ubuntu 22.04:** Debería funcionar sin cambios
- **Debian 12:** Posiblemente requiera ajustes
- **Fedora/RHEL:** Requiere cambios (apt → dnf, rutas udev diferentes)

## Contribuciones

Si encuentras problemas o quieres mejorar el script:
1. Abre un [Issue](https://github.com/Nebularumar/openrazer-linux-mint-setup/issues)
2. O un [Pull Request](https://github.com/Nebularumar/openrazer-linux-mint-setup/pulls)

## Licencia

MIT License - Libre para usar, modificar y distribuir

## Créditos

Basado en la documentación oficial de [OpenRazer](https://openrazer.github.io/) y experiencia de instalación en Linux Mint 21.3.

---

**¿Funcionó?** ⭐ Dale una estrella al repo si te fue útil!
