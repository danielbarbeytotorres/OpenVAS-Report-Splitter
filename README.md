# OpenVAS-Report-Splitter

**OpenVAS Report Splitter** es una herramienta de automatización para el post-procesado de informes generados en **OpenVAS (GVM)**.

La herramienta esta diseñada para extraer el **último** informe de un escaneo configurado, parsear el XML a un JSON estructurado y, finalmente, dividir cada vulnerabilidad individual en su propio archivo JSON para facilitar su análisis y tratamiento posterior.

## Requisitos 🛠️
- El servicio de **Greenbone Vulnerability Manager (GVM)** debe estar correctamente configurado en el equipo, y debe estar en ejecución (`sudo gvm-start`).
  - Si tienes problemas en la configuración de GVM, puedes consultar su guía [aquí](https://www.greenbone.net/en/documents/).
- La dependencia **gum**.
  - Para instalarla, realiza en una terminal lo siguiente: `sudo apt install gum`.
- **Python 3** y las librerías `xml.etree.ElementTree` y `json`.

## Uso de la herramienta 🚀
1. Asegúrate de que OpenVAS está en ejecución:
```bash
sudo gvm-start
```
2. Clona este repositorio:
```bash
git clone [https://github.com/danielbarbeytotorres/OpenVAS-Report-Splitter.git](https://github.com/danielbarbeytotorres/OpenVAS-Report-Splitter.git)
cd OpenVAS-Report-Splitter
```
3. **Ajusta la configuración** en el archivo `pipeline.sh` con tus IDs y rutas (si tienes problemas, consulta la última sección "Configuración").
4. Ajusta los permisos del script:
```bash
chmod +x pipeline.sh
```
4. Ejecuta!:
```bash
./pipeline.sh
```

El proceso creará una carpeta en el directorio base que hayas configurado con la fecha de hoy, el cuál contendrá:
* `report_AAAA-MM-DD.xml`: El informe bruto descargado de OpenVAS.
* `report_AAAA-MM-DD.json`: El JSON limpio y consolidado.
* `split_AAAA-MM-DD/`: Una carpeta con un JSON individual por cada vulnerabilidad encontrada.

## Configuración ⚙️
Debes editar las siguientes variables al inicio del script `pipeline.sh`:

| Variable | Descripción | Valor de Ejemplo |
| :--- | :--- | :--- |
| `TASK_ID` | El ID de la Task de escaneo que quieres procesar. | `"12345678-1234-1234-1234-123456789012"` |
| `FORMAT_ID` | El ID del Formato del Reporte (XML). | `"5057e5cc-b825-11e4-9d0e-28d24461215b"` |
| `BASE_DIR` | Directorio raíz donde se guardarán los reports. | `"reports"` |
| `GMP_USER` | Usuario de GMP que configuraste durante la instalación. | `"admin"` |
| `GMP_PASSWORD` | Contraseña de GMP que configuraste durante la instalación. | `"P4ssw0rd_$p"` |

*(**¡Ojo!:** Se recomienda usar un archivo conf separado para credenciales GMP en un entorno real. Aquí están *hardcodeadas* por simplicidad.)*

## Salida esperada

![Salida esperada](output.png)

Hecho por Daniel Barbeyto Torres. 
