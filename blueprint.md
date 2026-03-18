# Blueprint: 3Way - Gestor de Finanzas Personales

## 1. Visión General

**3Way** es una aplicación móvil integral diseñada para empoderar a los usuarios en la gestión de sus finanzas personales, basándose en la popular regla 50/30/20. La app permite un seguimiento detallado de ingresos y gastos, los clasifica en Necesidades, Deseos y Ahorro/Inversión, y fomenta la educación financiera a través de módulos prácticos. La seguridad es un pilar fundamental, implementada a través de un sistema de autenticación por PIN.

## 2. Arquitectura y Componentes Clave

La aplicación está construida sobre una arquitectura moderna y escalable de Flutter.

*   **Base de Datos Local:** Se utiliza `sqflite` para persistir todos los datos del usuario (transacciones, PIN) de forma segura y local en el dispositivo.
*   **Gestión de Estado:** Se emplea el paquete `provider` para una gestión de estado centralizada y eficiente.
*   **Flujo de Autenticación por PIN:** Se asegura la app mediante un PIN de 4 dígitos.
*   **Sistema de Theming Avanzado:** La app cuenta con un diseño visual pulido y dos temas (claro y oscuro) completamente definidos.

## 3. Plan de Cambios Recientes

### 3.1. Rebranding a "3Way"

Se realizó un cambio completo de identidad de la marca, pasando de "Zero Deudas" a "3Way" para reflejar mejor el enfoque en el método de presupuestos 50/30/20.

### 3.2. Mejora de Seguridad y Diseño en Eliminación

Para prevenir la eliminación accidental de datos y mejorar la experiencia de usuario, se rediseñó el diálogo de confirmación en la `HomeScreen`.

*   **Confirmación de Borrado:** Al deslizar para eliminar una transacción, se muestra un `AlertDialog` que pide al usuario confirmar la acción.
*   **Eliminación Permanente:** Se eliminó la funcionalidad de "Deshacer". Una vez confirmada, la eliminación de la transacción es definitiva.
*   **Diseño Mejorado del Diálogo:** Se aplicaron mejoras visuales al `AlertDialog` para hacerlo más intuitivo y coherente con el estilo de la app:
    *   Se añadió un **icono de advertencia** para comunicar visualmente el riesgo.
    *   Se mejoró la **jerarquía del texto** con títulos en negrita.
    *   Se estilizaron los botones de acción, usando `ElevatedButton` para un look moderno y diferenciando claramente el botón "Eliminar" (con fondo rojo) del botón "Cancelar" (con estilo neutro y texto adaptativo al tema).

## 4. Características Implementadas

*   **Módulo de Seguridad y Bienvenida:**
    *   Configuración y autenticación por PIN.
*   **Pantalla Principal (Dashboard):**
    *   Resumen de balance, ingresos y gastos.
    *   Lista de transacciones recientes con un **diálogo de confirmación de borrado mejorado**, que previene eliminaciones accidentales.
*   **Gestión Completa de Transacciones:**
    *   Registro de ingresos y gastos.
*   **Seguimiento de Deudas e Inversiones.**
*   **Módulo de Educación Financiera con Cuestionario.**
*   **Notificaciones Inteligentes para registro diario.**

## 5. Estilo y Diseño

*   Interfaz de usuario moderna, limpia y centrada en la legibilidad.
*   Paleta de colores principal basada en verdes y tonos oscuros (`#122E2A`, `#30E182`).
*   Tipografía `Poppins` de Google Fonts para un aspecto profesional y fresco.
