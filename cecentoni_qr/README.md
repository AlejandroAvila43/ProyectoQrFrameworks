# Cecentoni QR - Sistema de Verificación de Pedidos

Cecentoni QR es una aplicación móvil desarrollada en **Flutter** y conectada a **Firebase** diseñada para la verificación de pedidos en tiempo real a través del escaneo de códigos QR. Permite a los administradores y operarios crear pedidos, generar sus códigos QR correspondientes, escanear productos y confirmar que el producto físico coincida exactamente con lo solicitado.

---

##  Características Principales

* **Autenticación de Usuarios**: Conexión a Firebase Auth para inicio de sesión seguro con roles definidos (ej. Administrador).
* **Lista de Pedidos en Tiempo Real**: Visualización dinámica de los pedidos pendientes de entrega sincronizados directamente con Cloud Firestore.
* **Creación de Pedidos**: Formulario integrado dentro de la aplicación para registrar nuevos clientes, fechas de entrega y especificaciones detalladas del producto esperado (modelo, color, medida y lote).
* **Generación de QR Dinámico**: Cada pedido en la sección de detalle renderiza automáticamente su propio código QR en formato JSON estructurado:
  ```json
  {"modelo":"Porcelanato Blanco","color":"Blanco","medida":"60x120","lote":"LT3301"}
  ```
* **Verificación de Productos por Cámara**: Módulo de escaneo que utiliza la cámara trasera del dispositivo para leer el QR del producto físico.
* **Lógica de Validación Robusta**: Compara campo por campo (modelo, color, medida y lote) normalizando el texto para evitar errores por mayúsculas o espacios extra.
* **Historial de Verificaciones**: Almacenamiento y consulta de todas las validaciones exitosas o fallidas, detallando quién verificó, la fecha, hora y el resultado.

---

##  Requisitos Previos

Antes de correr el proyecto, asegúrate de tener instalado y configurado lo siguiente:

* **Flutter SDK**: Versión `>=3.3.0` instalada.
* **Dart SDK**: Configurado correctamente.
* **Java Development Kit (JDK)**: Requerido para la compilación de Android.
* **Entorno de Desarrollo**: VS Code o Android Studio con los plugins de Flutter y Dart.
* **Dispositivo de Pruebas**: 
  * Un emulador de Android/iOS configurado.
  * O un celular físico conectado en modo de depuración USB (muy recomendado para probar la funcionalidad de la cámara y escaneo de códigos QR).

---

##  Instalación y Configuración

Sigue estos pasos para ejecutar la aplicación en tu entorno local:

### 1. Clonar el repositorio
Navega a la carpeta de tu espacio de trabajo y clona el proyecto:
```bash
git clone <url-del-repositorio>
cd cecentoni_qr
```

### 2. Instalar las dependencias
Ejecuta el comando para descargar todas las librerías necesarias (como `firebase_core`, `flutter_riverpod`, `mobile_scanner`, `qr_flutter`, `intl`, etc.):
```bash
flutter pub get
```

### 3. Configuración de Firebase
El proyecto ya cuenta con la configuración por defecto de Firebase en `lib/firebase_options.dart`. Si deseas conectarlo a tu propio proyecto de Firebase:
1. Instala el CLI de Firebase y FlutterFire:
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```
2. Ejecuta la configuración interactiva en la raíz del proyecto:
   ```bash
   flutterfire configure
   ```
3. Esto generará o actualizará automáticamente el archivo `lib/firebase_options.dart` y descargará los archivos `google-services.json` (Android) y `GoogleService-Info.plist` (iOS).

### 4. Permisos de Dispositivo (Cámara e Internet)
* **Android**: Los permisos de cámara e internet necesarios para `mobile_scanner` y `firebase` ya están preconfigurados en `android/app/src/main/AndroidManifest.xml` y los perfiles de desarrollo.
* **iOS**: Si compilas para iOS, asegúrate de añadir la descripción de uso de la cámara (`NSCameraUsageDescription`) en tu archivo `ios/Runner/Info.plist` para que permita abrir el escáner de QR.

---

## 💻 Ejecución del Proyecto

Para arrancar el proyecto en modo de desarrollo:

1. Conecta tu dispositivo físico o arranca tu emulador.
2. Ejecuta el comando:
   ```bash
   flutter run
   ```
   * *Tip*: Si realizas cambios en la inicialización de idiomas locales del archivo `main.dart`, recuerda realizar un **Hot Restart** completo (tecla `R` en la consola) o volver a ejecutar `flutter run` para que tengan efecto.

---

## 🗄️ Estructura de la Base de Datos en Firestore

Para que el proyecto funcione correctamente con un nuevo backend de Firebase, debes crear las siguientes dos colecciones en **Cloud Firestore**:

### 1. Colección: `pedidos`
Esta colección contiene los pedidos a entregar.
* **ID de Documento**: `pedido_<docId>` (ej. `pedido_1001` o ID autogenerado).
* **Campos**:
  * `cliente`: `String` (Nombre del cliente).
  * `nombre`: `String` (Nombre del cliente, duplicado para compatibilidad).
  * `productoEsperado`: `String` (Modelo del producto esperado, ej. `"Porcelanato Blanco"`).
  * `color`: `String` (Color del producto).
  * `medida`: `String` (Medidas del producto, ej. `"60x120"`).
  * `lote`: `String` (Código del lote de fabricación, ej. `"LT3301"`).
  * `estatus`: `String` (Debe ser: `"pendiente"`, `"verificado"`, `"entregado"`, o `"error"`).
  * `fechaEntrega`: `Timestamp` (Fecha programada de entrega).

### 2. Colección: `verificaciones`
Esta colección almacena el historial de escaneos realizados.
* **ID de Documento**: Autogenerado por Firestore.
* **Campos**:
  * `empleadoEmail`: `String` (Correo del usuario que escaneó).
  * `empleadoNombre`: `String` (Nombre del usuario que escaneó).
  * `pedidoId`: `String` (ID del pedido asociado).
  * `numeroPedido`: `String` (Número visible del pedido).
  * `cliente`: `String` (Nombre del cliente).
  * `resultado`: `Boolean` (`true` si coincidieron los datos, `false` si no).
  * `fecha`: `Timestamp` (Fecha de la validación).
  * `hora`: `String` (Hora formateada en `"HH:mm:ss"`).
  * `productoEscaneado`: `Map` (Mapa que contiene `modelo`, `color`, `medida` y `lote` leídos del QR).

