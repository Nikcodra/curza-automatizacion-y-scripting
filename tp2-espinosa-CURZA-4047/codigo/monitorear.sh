#!/usr/bin/env bash

# Alumno: Ulises Espinosa
# Legajo: CURZA-4047
# Menú interactivo para consultar recursos del sistema.

mostrar_memoria() {
    echo ""
    echo "Memoria RAM en megabytes:"
    free -m
}

buscar_archivos_grandes() {
    local resultados

    echo ""
    echo "Cinco archivos mayores a 10 MB en $HOME:"
    resultados=$(find "$HOME" -type f -size +10M -printf '%s\t%p\n' 2>/dev/null \
        | sort -nr \
        | head -n 5)

    if [[ -z "$resultados" ]]; then
        echo "No se encontraron archivos mayores a 10 MB."
        return 0
    fi

    printf '%s\n' "$resultados" | awk -F '\t' '{printf "%.2f MB\t%s\n", $1 / 1048576, $2}'
}

mostrar_particiones() {
    echo ""
    echo "Uso de las particiones físicas montadas:"
    df -h -x tmpfs -x devtmpfs
}

PS3="Seleccione una opción (1-4): "
opciones=(
    "Monitorear memoria RAM"
    "Buscar archivos grandes"
    "Espacio en particiones"
    "Salir"
)

echo "Panel de monitoreo - CURZA-4047"

select opcion in "${opciones[@]}"; do
    case "$opcion" in
        "Monitorear memoria RAM")
            mostrar_memoria
            ;;
        "Buscar archivos grandes")
            buscar_archivos_grandes
            ;;
        "Espacio en particiones")
            mostrar_particiones
            ;;
        "Salir")
            echo "Hasta luego. Ulises Espinosa - CURZA-4047."
            break
            ;;
        *)
            echo "Opción inválida: $REPLY. Ingrese un número del 1 al 4."
            ;;
    esac

    if [[ "$opcion" != "Salir" ]]; then
        echo ""
        read -r -p "Presione Enter para volver al menú..." _
    fi
done

exit 0
