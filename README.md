# woff2
Script para termux, configurar binarios personalizados PATH exclusivo 
### Guía Rápida: Configurar .woff2 en Termux

![instalar de forma brusca woff2 termux](gif/woff2.gif)

1. Instalar curl (si no lo tienes, aunque actualmente esto viene en termux por defecto en versiones recientes):
   ```
   pkg install curl -y
   ```

2. Ejecutar el instalador en un solo paso:
   ```
   curl -sL https://raw.githubusercontent.com/cmbrdevmx/woff2/main/setup.sh | bash
   ```

3. Reiniciar Termux o aplicar cambios:
   ```
   source ~/.bashrc
   ```
   O si usas zsh:
   ```
   source ~/.zshrc
   ```

4. Listo, ahora puedes ejecutar los binarios de .woff2 directamente.

## Solución de problemas:
- Si los comandos no funcionan, verifica los permisos:
- `chmod +x ~/.woff2/*`
- Después cierra termux nuevamente y abrelo en dado caso de que se requiera para que detecte los cambios.
- Para actualizar: ejecuta el instalador nuevamente
