import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const ErrorScreen({
    super.key,
    required this.error,
    this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF122E2A),
        appBar: AppBar(
          title: const Text('Error Inesperado', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade900,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Ups! Ocurrió un error grave.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Por favor, envía una captura de este mensaje al desarrollador:',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((255 * 0.3).round()),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade400)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text(
                        'MENSAJE DE ERROR:',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                      ),
                      if (stackTrace != null) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'RASTRO DEL ERROR (STACK TRACE):',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stackTrace.toString(),
                          style: TextStyle( // SE HA QUITADO EL CONST DE AQUÍ
                            color: Colors.white.withAlpha((255 * 0.8).round()),
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
