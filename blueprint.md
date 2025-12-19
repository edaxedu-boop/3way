# Blueprint: App de Finanzas Personales con Presupuesto 50/30/20

## 1. Visión General

Esta aplicación es una herramienta de finanzas personales diseñada para ayudar a los usuarios a gestionar su dinero de forma proactiva utilizando la **regla de presupuesto 50/30/20**. El sistema clasifica automáticamente los ingresos y guía al usuario para que gaste de forma inteligente, asegurando que se mantenga dentro de sus límites y trabaje para alcanzar sus metas de ahorro.

## 2. Lógica y Arquitectura del Presupuesto

El núcleo de la aplicación es un sistema de "sobres" digitales que representa la regla 50/30/20.

*   **Distribución Automática de Ingresos:** Cada vez que se registra un ingreso, el monto se distribuye automáticamente en tres sobres principales:
    *   **50% para Necesidades:** Gastos esenciales como vivienda, comida, servicios.
    *   **30% para Deseos:** Gastos no esenciales como entretenimiento, hobbies, etc.
    *   **20% para Ahorro:** Dinero destinado a pagar deudas, invertir o guardar para el futuro.
*   **Validación de Saldo:** El sistema no permite registrar un gasto, pago de deuda o inversión si no hay fondos suficientes en el sobre correspondiente. Esto evita que el usuario gaste más de lo que ha presupuestado.

## 3. Características Implementadas

### Flujo de Bienvenida y Personalización
*   **Nombre de Usuario Obligatorio:** En el primer uso, la aplicación solicita al usuario su nombre a través de una pantalla dedicada. El botón para continuar permanece desactivado hasta que se introduce un nombre, asegurando la personalización desde el inicio.
*   **Bienvenida Personalizada:** La pantalla principal saluda al usuario por su nombre real, obtenido de las preferencias guardadas (Ej: "Hola, [Nombre]"). Se eliminó el nombre estático "Alejandro".
*   **Icono de Usuario Actualizado:** Se reemplazó el `CircleAvatar` por un icono de usuario genérico (`Icons.account_circle_outlined`) más limpio y coherente con el diseño.

### Pantalla Principal (Home)
*   **Diseño Moderno Basado en Tarjetas:** La pantalla de inicio fue rediseñada para mostrar tres tarjetas prominentes y claras que representan los saldos actuales de los sobres **"Necesidades"**, **"Deseos"** y **"Ahorro"**.
*   **Resumen General:** Se mantienen los resúmenes de ingresos y gastos totales.
*   **Transacciones Recientes:** Una lista muestra los últimos movimientos realizados.
*   **Navegación Intuitiva:** Un `FloatingActionButton` central despliega opciones para registrar rápidamente ingresos, gastos, deudas o inversiones.

### Flujo de Transacciones, Deudas e Inversiones
*   **Registro de Ingresos y Gastos:**
    *   Los ingresos se distribuyen automáticamente en los tres sobres.
    *   Los gastos se descuentan del sobre de "Necesidades" o "Deseos" seleccionado.
*   **Gestión de Deudas (Mejorado):**
    *   La adquisición de una deuda solo la registra para seguimiento, sin afectar los sobres.
    *   El pago de deudas se procesa como un gasto, permitiendo seleccionar el sobre de origen ("Necesidades", "Deseos" o "Ahorro") y descontando el saldo correspondiente.
    *   **Interfaz de Pago Moderna:** Se rediseñó el diálogo de pago de deudas con una interfaz más intuitiva, validación mejorada y notificaciones flotantes.
*   **Gestión de Inversiones (Reestructurado y Corregido):**
    *   **Vínculo Transaccional:** Cada inversión está ahora **directa y permanentemente vinculada** a la transacción de gasto de la cual se originó. Esto se logra a través de una columna `transactionId` en la base de datos.
    *   **Registro Confiable:** Al registrar una inversión, el sistema primero crea una transacción de tipo "gasto" (descontando el dinero del sobre seleccionado) y luego guarda la inversión, asociándola con el ID de esa transacción. 
    *   **Reversión Precisa:** Al eliminar una inversión, el sistema utiliza el `transactionId` para encontrar la transacción de gasto original y revertirla, devolviendo el monto exacto al sobre del que provino.

### Sistema de Notificaciones
*   **Recordatorios Diarios Automáticos:** La aplicación programa dos notificaciones locales recurrentes para fomentar el hábito de registrar transacciones:
    *   **Recordatorio Matutino (8:00 AM):** "¡Buen día! ¿Registraste todo lo de ayer? Mantén tus finanzas al día."
    *   **Recordatorio Nocturno (9:00 PM):** "No olvides registrar tus gastos. ¡Cada pequeño paso cuenta para alcanzar tu meta!"
*   **Gestión de Permisos:** La aplicación solicita los permisos necesarios para enviar notificaciones en Android y iOS al iniciarse por primera vez.
*   **Lógica Centralizada:** Toda la funcionalidad de notificaciones se gestiona a través de un `NotificationHelper` dedicado.


## 4. Estilo y Diseño
*   **Consistencia Visual y Soporte para Modo Oscuro/Claro.**
*   **Paleta de Colores Intuitiva y Tipografía Moderna.**

## 5. Correcciones de Bugs Anteriores
*   **Lógica de Cierre de Pantalla:** Corregido el orden de operaciones para mostrar mensajes y cerrar la pantalla de forma segura.
*   **Bloqueo de Base de Datos:** Solucionado el error `database has been locked` al unificar las operaciones de base de datos en una sola transacción atómica.
*   **Desbordamiento Visual:** Eliminado el error `RenderFlex overflowed` en la pantalla de inversión mediante el uso de `SingleChildScrollView`.
