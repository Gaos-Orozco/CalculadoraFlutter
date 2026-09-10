import 'package:flutter/material.dart';

import '../services/sound_service.dart';
import 'calculator_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() =>
      _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  final SoundService sound = SoundService();

  bool loading = false;

  Future<void> enterApp() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    // Sonido de inicio
    await sound.playStartup();

    // Pequeña pausa para que se sienta como una carga real
    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 650),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const CalculatorScreen();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF020403),
      body: Center(
        child: Container(
          width: 430,
          height: 850,
          decoration: BoxDecoration(
            color:
                const Color(0xFF050706),
            borderRadius:
                BorderRadius.circular(42),
            border: Border.all(
              color:
                  const Color(0xFF343A36),
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                color:
                    Color(0xDD000000),
                blurRadius: 45,
                spreadRadius: 8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(39),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ==================================================
                // IMAGEN PRINCIPAL
                // ==================================================

                Image.asset(
                  'assets/images/gaos_startup.png',
                  fit: BoxFit.cover,
                ),

                // ==================================================
                // CAPA OSCURA MUY SUTIL
                // ==================================================

                Container(
                  decoration: const BoxDecoration(
                    gradient:
                        LinearGradient(
                      begin:
                          Alignment.topCenter,
                      end:
                          Alignment.bottomCenter,
                      colors: [
                        Color(0x15000000),
                        Color(0x00000000),
                        Color(0x22000000),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // BOTÓN INTERACTIVO
                // ==================================================
                // El botón ya está dibujado en la imagen.
                // Flutter solamente coloca una zona táctil invisible
                // encima de él.

                  Positioned(
                    left: 70,
                    right: 70,
                    bottom: 135,
                    child: SizedBox(
                      height: 50,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: loading ? null : enterApp,
                          borderRadius:
                              BorderRadius.circular(18),
                          splashColor:
                              const Color(0x5539FF14),
                          highlightColor:
                              const Color(0x2239FF14),
                        ),
                      ),
                    ),
                  ),

                // ==================================================
                // INDICADOR DE SISTEMA
                // ==================================================

                Positioned(
                  top: 20,
                  left: 24,
                  right: 24,
                  child: SafeArea(
                    child: Row(
                      children: [
                        const Text(
                          'GAOS',
                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF39FF14,
                            ),
                            fontSize: 15,
                            fontWeight:
                                FontWeight.bold,
                            letterSpacing:
                                1.5,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons
                              .signal_cellular_alt,
                          size: 15,
                          color:
                              Colors.white70,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        const Icon(
                          Icons.wifi,
                          size: 15,
                          color:
                              Colors.white70,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        const Icon(
                          Icons.battery_full,
                          size: 17,
                          color:
                              Color(
                            0xFF39FF14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // TEXTO DE CARGA
                // ==================================================

                if (loading)
                  Positioned.fill(
                    child: Container(
                      color:
                          const Color(
                        0x66000000,
                      ),
                      alignment:
                          Alignment.center,
                      child: Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 25,
                          vertical: 14,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xEE080B0A,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                          border:
                              Border.all(
                            color:
                                const Color(
                              0xFF39FF14,
                            ),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color:
                                  Color(
                                0x6639FF14,
                              ),
                              blurRadius:
                                  20,
                            ),
                          ],
                        ),
                        child: const Text(
                          'LOADING GAOS...',
                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF39FF14,
                            ),
                            fontWeight:
                                FontWeight.bold,
                            letterSpacing:
                                2,
                          ),
                        ),
                      ),
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