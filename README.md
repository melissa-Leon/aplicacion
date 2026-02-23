diff --git a/README.md b/README.md
index 4e3eb89745772e0b4d76f588fd164ce88fd84acf..c728fc69327c77719e48300e8befa48fe716c1ff 100644
--- a/README.md
+++ b/README.md
@@ -1 +1,28 @@
-# aplicacion
\ No newline at end of file
+# aplicacion
+
+Aplicación móvil en Flutter para mamás y familias que quieren encontrar lugares para niños en Washington (estado).
+
+## Funcionalidades incluidas
+
+- Mapa con marcadores de lugares familiares.
+- Ruta visual básica en el mapa desde una ubicación demo al lugar seleccionado.
+- Botón para abrir Google Maps con navegación real.
+- Ficha de cada lugar con:
+  - Horario.
+  - Imagen.
+  - Puntuación promedio.
+  - Lista de reseñas.
+- Formulario para que las personas agreguen reseñas y puntuación.
+
+## Ejecutar
+
+1. Instala Flutter.
+2. Configura la llave de Google Maps para Android/iOS.
+3. Ejecuta:
+
+```bash
+flutter pub get
+flutter run
+```
+
+> Nota: Este repositorio contiene una implementación demo con datos en memoria.
