#!/data/data/com.termux/files/usr/bin/bash

# ======================================================================
# Script profesional para configurar el directorio .woff2 como PATH en Termux
# Autor: cmbrdevmx
# Versión: 1.0.0
# ======================================================================

# === Definición de colores para mensajes informativos ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# === Variables de configuración ===
REPO_URL="https://github.com/cmbrdevmx/woff2.git"
WOFF2_DIR="$HOME/.woff2"
TEMP_DIR="$HOME/.woff2_temp"
SHELL_CONFIG=""

# === Función para imprimir mensajes con estilo ===
print_message() {
    local type=$1
    local message=$2
    
    case $type in
        "info")
            echo -e "${BLUE}${BOLD}[INFO]${RESET} ${message}"
            ;;
        "success")
            echo -e "${GREEN}${BOLD}[ÉXITO]${RESET} ${message}"
            ;;
        "warning")
            echo -e "${YELLOW}${BOLD}[ADVERTENCIA]${RESET} ${message}"
            ;;
        "error")
            echo -e "${RED}${BOLD}[ERROR]${RESET} ${message}"
            ;;
        "step")
            echo -e "\n${CYAN}${BOLD}=== ${message} ===${RESET}"
            ;;
        "progress")
            echo -e "${MAGENTA}${BOLD}-->${RESET} ${message}"
            ;;
    esac
}

# === Función para mostrar una animación de carga ===
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    
    echo -ne "${YELLOW}"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        echo -ne "\r"
        sleep $delay
    done
    echo -ne "${RESET}\r\033[K"
}

# === Función para verificar dependencias ===
check_dependencies() {
    print_message "step" "Verificando dependencias necesarias"
    
    if ! command -v git &> /dev/null; then
        print_message "warning" "Git no está instalado. Instalando git..."
        print_message "progress" "Ejecutando: pkg install git -y"
        
        # Instalamos git con respuesta automática "yes"
        yes | pkg install git > /dev/null 2>&1 &
        show_spinner $!
        
        if command -v git &> /dev/null; then
            print_message "success" "Git ha sido instalado correctamente"
        else
            print_message "error" "No se pudo instalar Git. Por favor, instálelo manualmente con 'pkg install git'"
            exit 1
        fi
    else
        print_message "success" "Git ya está instalado ✓"
    fi
}

# === Función para detectar el shell en uso ===
detect_shell() {
    print_message "step" "Detectando shell en uso"
    
    # Verificar qué shell está usando el usuario
    local current_shell=$(basename "$SHELL")
    print_message "info" "Shell actual: $current_shell"
    
    if [[ "$current_shell" == "zsh" ]]; then
        SHELL_CONFIG="$HOME/.zshrc"
        print_message "success" "Configuración de ZSH detectada ✓"
    else
        SHELL_CONFIG="$HOME/.bashrc"
        print_message "success" "Configuración de Bash detectada ✓"
    fi
    
    # Verificar si el archivo de configuración existe
    if [ ! -f "$SHELL_CONFIG" ]; then
        print_message "warning" "El archivo $SHELL_CONFIG no existe. Creándolo..."
        touch "$SHELL_CONFIG"
    fi
}

# === Función para clonar el repositorio ===
clone_repository() {
    print_message "step" "Clonando repositorio WOFF2"
    
    # Eliminar directorios temporales si existen
    if [ -d "$TEMP_DIR" ]; then
        print_message "warning" "Eliminando directorio temporal anterior..."
        rm -rf "$TEMP_DIR"
    fi
    
    print_message "progress" "Clonando desde: $REPO_URL"
    git clone "$REPO_URL" "$TEMP_DIR" > /dev/null 2>&1 &
    show_spinner $!
    
    if [ $? -eq 0 ]; then
        print_message "success" "Repositorio clonado exitosamente ✓"
    else
        print_message "error" "Error al clonar el repositorio. Verifique la URL y su conexión a internet."
        exit 1
    fi
}

# === Función para instalar binarios woff2 ===
install_woff2_binaries() {
    print_message "step" "Instalando binarios WOFF2"
    
    # Crear directorio .woff2 si no existe
    if [ ! -d "$WOFF2_DIR" ]; then
        print_message "progress" "Creando directorio $WOFF2_DIR"
        mkdir -p "$WOFF2_DIR"
    else
        print_message "warning" "El directorio $WOFF2_DIR ya existe. Haciendo copia de seguridad..."
        local backup_dir="$HOME/.woff2_backup_$(date +%Y%m%d%H%M%S)"
        mv "$WOFF2_DIR" "$backup_dir"
        print_message "info" "Copia de seguridad creada en: $backup_dir"
        mkdir -p "$WOFF2_DIR"
    fi
    
    # Copiar archivos del repositorio al directorio .woff2
    print_message "progress" "Copiando archivos al directorio $WOFF2_DIR"
    cp -r "$TEMP_DIR/.woff2/"* "$WOFF2_DIR/" 2>/dev/null || cp -r "$TEMP_DIR/"* "$WOFF2_DIR/" 2>/dev/null
    
    # Verificar si se copiaron los archivos
    if [ "$(ls -A "$WOFF2_DIR" 2>/dev/null)" ]; then
        print_message "success" "Archivos copiados exitosamente ✓"
    else
        print_message "warning" "No se encontraron archivos en el repositorio. Verificando estructura..."
        
        # Intenta encontrar los binarios en el repositorio
        find "$TEMP_DIR" -type f -exec cp {} "$WOFF2_DIR/" \;
        
        if [ "$(ls -A "$WOFF2_DIR" 2>/dev/null)" ]; then
            print_message "success" "Archivos copiados exitosamente después de búsqueda adicional ✓"
        else
            print_message "error" "No se encontraron archivos para copiar en el repositorio."
            exit 1
        fi
    fi
    
    # Dar permisos de ejecución a todos los archivos
    print_message "progress" "Asignando permisos de ejecución a los binarios"
    chmod +x "$WOFF2_DIR"/* &
    show_spinner $!
    print_message "success" "Permisos asignados correctamente ✓"
    
    # Eliminar directorio temporal
    rm -rf "$TEMP_DIR"
}

# === Función para configurar PATH en archivo de shell ===
configure_path() {
    print_message "step" "Configurando PATH en $SHELL_CONFIG"
    
    # Verificar si ya está configurado
    if grep -q "PATH=\"\$HOME/.woff2:\$PATH\"" "$SHELL_CONFIG"; then
        print_message "info" "La configuración de PATH ya existe en $SHELL_CONFIG"
    else
        print_message "progress" "Añadiendo .woff2 al PATH en $SHELL_CONFIG"
        
        cat >> "$SHELL_CONFIG" << EOF

# === Configuración de binarios WOFF2 ===
# Agregado automáticamente por el instalador WOFF2
if [ -d "\$HOME/.woff2" ] ; then
    export PATH="\$HOME/.woff2:\$PATH"
fi
EOF
        
        print_message "success" "PATH configurado exitosamente ✓"
    fi
}

# === Función para aplicar cambios ===
apply_changes() {
    print_message "step" "Aplicando cambios"
    
    print_message "progress" "Recargando configuración del shell"
    source "$SHELL_CONFIG" 2>/dev/null || . "$SHELL_CONFIG" 2>/dev/null
    
    # Verificar que .woff2 esté en el PATH
    if echo "$PATH" | grep -q "$HOME/.woff2"; then
        print_message "success" "¡Configuración aplicada correctamente! ✓"
    else
        print_message "warning" "La configuración se ha guardado pero no se ha podido aplicar automáticamente."
        print_message "info" "Para aplicar los cambios, ejecute: source $SHELL_CONFIG"
    fi
}

# === Función para mostrar información final ===
show_summary() {
    print_message "step" "Resumen de la instalación"
    
    echo -e "${BOLD}Directorio de binarios:${RESET} $WOFF2_DIR"
    echo -e "${BOLD}Archivo de configuración:${RESET} $SHELL_CONFIG"
    echo -e "${BOLD}Binarios instalados:${RESET} $(ls -1 "$WOFF2_DIR" | wc -l)"
    
    echo -e "\n${GREEN}${BOLD}¡Instalación completada exitosamente!${RESET}"
    echo -e "Ahora puede ejecutar los binarios de WOFF2 directamente desde cualquier ubicación."
    echo -e "Si tiene problemas, abra una nueva sesión de Termux o ejecute: ${CYAN}source $SHELL_CONFIG${RESET}\n"
}

# === Función principal ===
main() {
    # Mostrar banner
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║              INSTALADOR DE BINARIOS WOFF2                ║"
    echo "║                  para Termux v1.0.0                      ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    
    # Ejecutar funciones en secuencia
    check_dependencies
    detect_shell
    clone_repository
    install_woff2_binaries
    configure_path
    apply_changes
    show_summary
}

# === Iniciar la ejecución del script ===
main
