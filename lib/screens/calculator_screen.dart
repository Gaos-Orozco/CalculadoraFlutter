import 'package:flutter/material.dart';

import '../services/calculator_service.dart';
import '../services/sound_service.dart';
import '../utils/validators.dart';

enum GaosStatus { ready, success, error }

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorService calculator = CalculatorService();
  final Validators validators = Validators();
  final SoundService sound = SoundService();

  String display = '0';
  String expression = '';
  String parityInfo = '';

  double? firstNumber;
  String? currentOperator;
  bool waitingForSecondNumber = false;

  GaosStatus status = GaosStatus.ready;

  final List<String> history = [];

  Color get statusColor {
    switch (status) {
      case GaosStatus.success:
        return const Color(0xFF39FF14);
      case GaosStatus.error:
        return const Color(0xFFFF304F);
      case GaosStatus.ready:
        return const Color(0xFF39FF14);
    }
  }

  String get statusText {
    switch (status) {
      case GaosStatus.success:
        return 'SUCCESS // OPERATION COMPLETE';
      case GaosStatus.error:
        return 'ERROR // OPERATION FAILED';
      case GaosStatus.ready:
        return 'SYSTEM READY // GAOS MOBILE';
    }
  }

  @override
  void dispose() {
    sound.dispose();
    super.dispose();
  }

  // Estado visual de una operación exitosa.
  void setSuccess() {
    setState(() {
      status = GaosStatus.success;
    });

    sound.playSuccess();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      setState(() {
        status = GaosStatus.ready;
      });
    });
  }

  // Entrada de números.
  void pressNumber(String number) {
    sound.playTap();

    setState(() {
      if (display == '0' || waitingForSecondNumber) {
        display = number;
        waitingForSecondNumber = false;
      } else {
        display += number;
      }

      status = GaosStatus.ready;
      _updateParityRadar();
    });
  }

  void pressDecimal() {
    sound.playTap();

    setState(() {
      if (waitingForSecondNumber) {
        display = '0.';
        waitingForSecondNumber = false;
      } else if (!display.contains('.')) {
        display += '.';
      }

      status = GaosStatus.ready;
      _updateParityRadar();
    });
  }

  // Control de la calculadora.
  void clearCalculator() {
    sound.playTap();

    setState(() {
      display = '0';
      expression = '';
      parityInfo = '';
      firstNumber = null;
      currentOperator = null;
      waitingForSecondNumber = false;
      status = GaosStatus.ready;
    });
  }

  void deleteLast() {
    sound.playTap();

    setState(() {
      if (display.length <= 1 ||
          (display.length == 2 && display.startsWith('-'))) {
        display = '0';
      } else {
        display = display.substring(0, display.length - 1);
      }

      status = GaosStatus.ready;
      _updateParityRadar();
    });
  }

  void changeSign() {
    sound.playTap();

    setState(() {
      if (display == '0') return;

      display = display.startsWith('-')
          ? display.substring(1)
          : '-$display';

      status = GaosStatus.ready;
      _updateParityRadar();
    });
  }

  // Selección de operaciones básicas.
  void pressOperator(String newOperator) {
    sound.playTap();

    final value = double.tryParse(display);

    if (value == null) {
      showError('Número inválido.');
      return;
    }

    if (firstNumber != null && currentOperator != null) {
      final success = calculateBasic();

      if (!success) return;
    }

    setState(() {
      firstNumber = value;
      currentOperator = newOperator;
      expression = '${formatNumber(value)} $newOperator';
      parityInfo = _singleParity(value);
      waitingForSecondNumber = true;
      status = GaosStatus.ready;
    });
  }

  void pressEquals() {
    calculateBasic();
  }

  // Ejecuta suma, resta, multiplicación y división.
  bool calculateBasic() {
    final secondNumber = double.tryParse(display);

    if (firstNumber == null ||
        currentOperator == null ||
        secondNumber == null ||
        waitingForSecondNumber) {
      showError('Completa la operación.');
      return false;
    }

    try {
      final first = firstNumber!;
      final operator = currentOperator!;

      late double result;

      switch (operator) {
        case '+':
          result = calculator.sumar(first, secondNumber);
          break;

        case '−':
          result = calculator.restar(first, secondNumber);
          break;

        case '×':
          result = calculator.multiplicar(first, secondNumber);
          break;

        case '÷':
          result = calculator.dividir(first, secondNumber);
          break;

        default:
          return false;
      }

      final operation =
          '${formatNumber(first)} $operator '
          '${formatNumber(secondNumber)} = '
          '${formatNumber(result)}';

      setState(() {
        display = formatNumber(result);
        expression = operation;

        history.insert(0, operation);

        firstNumber = null;
        currentOperator = null;
        waitingForSecondNumber = true;

        parityInfo = _twoNumberParity(first, secondNumber);
      });

      setSuccess();

      return true;
    } catch (e) {
      showError(cleanError(e.toString()));
      return false;
    }
  }

  // Potencia con exponente introducido por el usuario.
  void power() {
    final base = double.tryParse(display);

    if (base == null) {
      showError('Número inválido.');
      return;
    }

    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return _GaosDialog(
          title: 'POTENCIA',
          child: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              hintText: 'Ingresa el exponente',
              hintStyle: TextStyle(
                color: Colors.white38,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFF29442F),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFF39FF14),
                ),
              ),
            ),
          ),
          onCancel: () {
            controller.dispose();
            Navigator.pop(dialogContext);
          },
          onConfirm: () {
            final exponent = double.tryParse(controller.text);

            if (exponent == null) {
              controller.dispose();
              Navigator.pop(dialogContext);

              showError('Exponente inválido.');
              return;
            }

            Navigator.pop(dialogContext);
            controller.dispose();

            try {
              final result = calculator.potencia(
                base,
                exponent,
              );

              final operation =
                  '${formatNumber(base)} ^ '
                  '${formatNumber(exponent)} = '
                  '${formatNumber(result)}';

              setState(() {
                display = formatNumber(result);
                expression = operation;

                history.insert(0, operation);

                parityInfo = _singleParity(result);
                waitingForSecondNumber = true;
              });

              setSuccess();
            } catch (e) {
              showError(cleanError(e.toString()));
            }
          },
        );
      },
    );
  }

  // Raíz cuadrada.
  void squareRoot() {
    final number = double.tryParse(display);

    if (number == null) {
      showError('Número inválido.');
      return;
    }

    try {
      final result = calculator.raiz(number);

      final operation =
          '√${formatNumber(number)} = '
          '${formatNumber(result)}';

      setState(() {
        display = formatNumber(result);
        expression = operation;

        history.insert(0, operation);

        parityInfo = _singleParity(result);
        waitingForSecondNumber = true;
      });

      setSuccess();
    } catch (e) {
      showError(cleanError(e.toString()));
    }
  }

  // Logaritmo base 10.
  void logarithm() {
    final number = double.tryParse(display);

    if (number == null) {
      showError('Número inválido.');
      return;
    }

    try {
      final result = calculator.logaritmo(number);

      final operation =
          'log₁₀(${formatNumber(number)}) = '
          '${formatNumber(result)}';

      setState(() {
        display = formatNumber(result);
        expression = operation;

        history.insert(0, operation);

        parityInfo = _singleParity(result);
        waitingForSecondNumber = true;
      });

      setSuccess();
    } catch (e) {
      showError(cleanError(e.toString()));
    }
  }

  // Cociente y residuo trabajan exclusivamente con enteros.
  void integerOperation(String type) {
    final first = int.tryParse(display);

    if (first == null) {
      showError(
        'Esta operación requiere un número entero.',
      );
      return;
    }

    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final title =
            type == 'cociente' ? 'COCIENTE' : 'RESIDUO';

        return _GaosDialog(
          title: title,
          child: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              hintText: 'Segundo número entero',
              hintStyle: TextStyle(
                color: Colors.white38,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFF29442F),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFF39FF14),
                ),
              ),
            ),
          ),
          onCancel: () {
            controller.dispose();
            Navigator.pop(dialogContext);
          },
          onConfirm: () {
            final second = int.tryParse(controller.text);

            if (second == null) {
              controller.dispose();
              Navigator.pop(dialogContext);

              showError(
                'Debes ingresar un número entero.',
              );
              return;
            }

            if (second == 0) {
              controller.dispose();
              Navigator.pop(dialogContext);

              showError(
                'No se puede dividir entre cero.',
              );
              return;
            }

            Navigator.pop(dialogContext);
            controller.dispose();

            try {
              final result = type == 'cociente'
                  ? calculator.cociente(first, second)
                  : calculator.residuo(first, second);

              final operation = type == 'cociente'
                  ? '$first ÷ $second → Cociente = $result'
                  : '$first % $second → Residuo = $result';

              setState(() {
                display = result.toString();
                expression = operation;

                history.insert(0, operation);

                parityInfo = _twoNumberParity(
                  first.toDouble(),
                  second.toDouble(),
                );

                waitingForSecondNumber = true;
              });

              setSuccess();
            } catch (e) {
              showError(cleanError(e.toString()));
            }
          },
        );
      },
    );
  }

  // Muestra errores y reproduce el sonido correspondiente.
  void showError(String message) {
    sound.playError();

    setState(() {
      status = GaosStatus.error;
      expression = 'ERROR // $message';
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;

      setState(() {
        status = GaosStatus.ready;
      });
    });

    showDialog(
      context: context,
      builder: (context) {
        return _GaosMessageDialog(
          title: 'ERROR',
          message: message,
          error: true,
        );
      },
    );
  }

  String cleanError(String error) {
    return error.replaceFirst(
      'Exception: ',
      '',
    );
  }

  // Formato limpio para evitar .0 innecesarios.
  String formatNumber(double number) {
    if (!number.isFinite) {
      return number.toString();
    }

    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number
        .toStringAsFixed(8)
        .replaceFirst(
          RegExp(r'0+$'),
          '',
        )
        .replaceFirst(
          RegExp(r'\.$'),
          '',
        );
  }

  // Paridad automática de un número.
  String _singleParity(double number) {
    if (!number.isFinite ||
        number != number.roundToDouble()) {
      return 'PARITY // DECIMAL';
    }

    final value = number.toInt();

    final parity =
        validators.determinarParidad(value).toUpperCase();

    return 'PARITY // $value: $parity';
  }

  // Paridad automática de los dos operandos.
  String _twoNumberParity(
    double first,
    double second,
  ) {
    if (first != first.roundToDouble() ||
        second != second.roundToDouble()) {
      return 'PARITY // ENTEROS REQUERIDOS';
    }

    final firstInt = first.toInt();
    final secondInt = second.toInt();

    final firstParity =
        validators.determinarParidad(firstInt).toUpperCase();

    final secondParity =
        validators.determinarParidad(secondInt).toUpperCase();

    return 'PARITY // $firstInt: $firstParity   '
        '$secondInt: $secondParity';
  }

  void _updateParityRadar() {
    final current = double.tryParse(display);

    if (firstNumber != null &&
        current != null &&
        !waitingForSecondNumber) {
      parityInfo = _twoNumberParity(
        firstNumber!,
        current,
      );
    } else if (current != null) {
      parityInfo = _singleParity(current);
    } else {
      parityInfo = '';
    }
  }

  // Historial de operaciones.
  void showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF080B0A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: 500,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: Color(0xFF39FF14),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'GAOS // HISTORY',
                        style: TextStyle(
                          fontFamily: 'Pricedown',
                          color: Color(0xFF39FF14),
                          fontSize: 23,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: history.isEmpty
                        ? const Center(
                            child: Text(
                              'SIN OPERACIONES',
                              style: TextStyle(
                                color: Colors.white38,
                                letterSpacing: 2,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: history.length,
                            itemBuilder:
                                (context, index) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.calculate_outlined,
                                  color: Color(0xFF39FF14),
                                ),
                                title: Text(
                                  history[index],
                                  style: const TextStyle(
                                    fontFamily: 'Pricedown',
                                    color: Colors.white,
                                    fontSize: 19,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height;

    final phoneHeight =
        screenHeight < 850
            ? screenHeight - 20
            : 850.0;

    return Scaffold(
      backgroundColor: const Color(0xFF020403),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 430,
            height: phoneHeight,
            margin:
                const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF080B0A),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: const Color(0xFF343A36),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xAA000000),
                  blurRadius: 35,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildStatusBar(),
                _buildHeader(),
                _buildDisplay(),
                Expanded(
                  child: _buildKeypad(),
                ),
                _buildAdvancedPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(22, 12, 22, 0),
      child: Row(
        children: [
          const Text(
            'GAOS',
            style: TextStyle(
              fontFamily: 'Pricedown',
              color: Color(0xFF39FF14),
              fontSize: 19,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          Text(
            _currentTime(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.signal_cellular_alt,
            size: 16,
            color: Colors.white70,
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.wifi,
            size: 16,
            color: Colors.white70,
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.battery_full,
            size: 18,
            color: Color(0xFF39FF14),
          ),
        ],
      ),
    );
  }

  String _currentTime() {
    final now = DateTime.now();

    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildHeader() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(20, 12, 12, 4),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF111613),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF39FF14),
              ),
            ),
            child: const Icon(
              Icons.calculate_outlined,
              color: Color(0xFF39FF14),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'CALCULATOR',
                style: TextStyle(
                  fontFamily: 'Pricedown',
                  color: Colors.white,
                  fontSize: 27,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'LS-01 // GAOS MOBILE',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _headerStar(true),
              _headerStar(true),
              _headerStar(true),
              _headerStar(true),
              _headerStar(false),
            ],
          ),
          IconButton(
            onPressed: showHistory,
            icon: const Icon(
              Icons.history,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStar(bool active) {
    return Icon(
      active ? Icons.star : Icons.star_border,
      size: 12,
      color: active
          ? const Color(0xFF39FF14)
          : Colors.white38,
    );
  }

  Widget _buildDisplay() {
    final isSuccess =
        status == GaosStatus.success;

    final isError =
        status == GaosStatus.error;

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 220),
      margin:
          const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding:
          const EdgeInsets.fromLTRB(18, 10, 18, 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFF150608)
            : isSuccess
                ? const Color(0xFF071407)
                : const Color(0xFF030504),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: statusColor,
          width:
              isSuccess || isError ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(
              alpha:
                  isSuccess || isError
                      ? 0.35
                      : 0.12,
            ),
            blurRadius:
                isSuccess || isError
                    ? 22
                    : 12,
            spreadRadius:
                isSuccess || isError
                    ? 2
                    : 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor,
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  statusText,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          SizedBox(
            height: 19,
            child: Align(
              alignment:
                  Alignment.centerRight,
              child: Text(
                expression,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 72,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment:
                  Alignment.centerRight,
              child: AnimatedSwitcher(
                duration:
                    const Duration(
                  milliseconds: 180,
                ),
                transitionBuilder:
                    (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Text(
                  display,
                  key: ValueKey(display),
                  style: const TextStyle(
                    fontFamily: 'Pricedown',
                    color:
                        Color(0xFFB8FF9F),
                    fontSize: 72,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color:
                            Color(0x6639FF14),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (parityInfo.isNotEmpty)
            Align(
              alignment:
                  Alignment.centerRight,
              child: Text(
                parityInfo,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  color:
                      Color(0xFF39FF14),
                  fontSize: 9,
                  fontWeight:
                      FontWeight.bold,
                  letterSpacing: 0.7,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Column(
        children: [
          _buttonRow([
            _button(
              'C',
              clearCalculator,
            ),
            _button(
              '±',
              changeSign,
            ),
            _button(
              'DEL',
              deleteLast,
            ),
            _operatorButton(
              '÷',
              () => pressOperator('÷'),
            ),
          ]),
          _buttonRow([
            _button(
              '7',
              () => pressNumber('7'),
            ),
            _button(
              '8',
              () => pressNumber('8'),
            ),
            _button(
              '9',
              () => pressNumber('9'),
            ),
            _operatorButton(
              '×',
              () => pressOperator('×'),
            ),
          ]),
          _buttonRow([
            _button(
              '4',
              () => pressNumber('4'),
            ),
            _button(
              '5',
              () => pressNumber('5'),
            ),
            _button(
              '6',
              () => pressNumber('6'),
            ),
            _operatorButton(
              '−',
              () => pressOperator('−'),
            ),
          ]),
          _buttonRow([
            _button(
              '1',
              () => pressNumber('1'),
            ),
            _button(
              '2',
              () => pressNumber('2'),
            ),
            _button(
              '3',
              () => pressNumber('3'),
            ),
            _operatorButton(
              '+',
              () => pressOperator('+'),
            ),
          ]),
          _buttonRow([
            _button(
              '0',
              () => pressNumber('0'),
            ),
            _button(
              '.',
              pressDecimal,
            ),
            _equalsButton(),
          ]),
        ],
      ),
    );
  }

  Widget _buttonRow(List<Widget> buttons) {
    return Expanded(
      child: Row(
        children: buttons,
      ),
    );
  }

  Widget _button(
    String text,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Padding(
        padding:
            const EdgeInsets.all(4),
        child: _AnimatedCalcButton(
          text: text,
          onPressed: onPressed,
          isNumber:
              RegExp(r'^\d+$')
                  .hasMatch(text),
        ),
      ),
    );
  }

  Widget _operatorButton(
    String text,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Padding(
        padding:
            const EdgeInsets.all(4),
        child: _AnimatedCalcButton(
          text: text,
          onPressed: onPressed,
          isOperator: true,
        ),
      ),
    );
  }

  Widget _equalsButton() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding:
            const EdgeInsets.all(4),
        child: _AnimatedCalcButton(
          text: '=',
          onPressed: pressEquals,
          isEquals: true,
          fontSize: 34,
        ),
      ),
    );
  }

  Widget _buildAdvancedPanel() {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        12,
        4,
        12,
        12,
      ),
      padding:
          const EdgeInsets.fromLTRB(
        8,
        7,
        8,
        7,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFF101412),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFF202823),
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.radar,
                size: 15,
                color:
                    Color(0xFF39FF14),
              ),
              SizedBox(width: 6),
              Text(
                'RADAR MATEMÁTICO',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _advancedButton(
                'xʸ',
                power,
              ),
              _advancedButton(
                '√',
                squareRoot,
              ),
              _advancedButton(
                'log',
                logarithm,
              ),
              _advancedButton(
                'C/Q',
                () => integerOperation(
                  'cociente',
                ),
              ),
              _advancedButton(
                '%',
                () => integerOperation(
                  'residuo',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _advancedButton(
    String text,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 2,
        ),
        child: SizedBox(
          height: 34,
          child: OutlinedButton(
            onPressed: () {
              sound.playTap();
              onPressed();
            },
            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  const Color(
                0xFF39FF14,
              ),
              side:
                  const BorderSide(
                color:
                    Color(0xFF29442F),
              ),
              padding: EdgeInsets.zero,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),
            child: Text(
              text,
              style:
                  const TextStyle(
                fontFamily:
                    'Pricedown',
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedCalcButton
    extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isNumber;
  final bool isOperator;
  final bool isEquals;
  final double fontSize;

  const _AnimatedCalcButton({
    required this.text,
    required this.onPressed,
    this.isNumber = false,
    this.isOperator = false,
    this.isEquals = false,
    this.fontSize = 21,
  });

  @override
  State<_AnimatedCalcButton> createState() =>
      _AnimatedCalcButtonState();
}

class _AnimatedCalcButtonState
    extends State<_AnimatedCalcButton> {
  bool pressed = false;

  void handlePress() {
    setState(() {
      pressed = true;
    });

    widget.onPressed();

    Future.delayed(
      const Duration(
        milliseconds: 90,
      ),
      () {
        if (!mounted) return;

        setState(() {
          pressed = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;

    if (widget.isEquals) {
      background =
          const Color(0xFF39FF14);
      foreground = Colors.black;
    } else if (widget.isOperator) {
      background =
          const Color(0xFF16331D);
      foreground =
          const Color(0xFF39FF14);
    } else {
      background =
          const Color(0xFF151918);
      foreground = Colors.white;
    }

    return AnimatedScale(
      scale: pressed ? 0.91 : 1,
      duration:
          const Duration(milliseconds: 80),
      child: Material(
        color: background,
        borderRadius:
            BorderRadius.circular(17),
        child: InkWell(
          onTap: handlePress,
          borderRadius:
              BorderRadius.circular(17),
          splashColor:
              const Color(0x5539FF14),
          highlightColor:
              const Color(0x2239FF14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(17),
              border: Border.all(
                color: widget.isEquals
                    ? const Color(
                        0xFF5EFF43,
                      )
                    : const Color(
                        0xFF2A332E,
                      ),
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isEquals
                      ? const Color(
                          0x6639FF14,
                        )
                      : background.withValues(
                          alpha: 0.30,
                        ),
                  blurRadius:
                      widget.isEquals
                          ? 14
                          : 7,
                  offset:
                      const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              widget.text,
              style: TextStyle(
                fontFamily:
                    widget.isNumber
                        ? 'Pricedown'
                        : 'Arial',
                color: foreground,
                fontSize:
                    widget.isNumber
                        ? 34
                        : widget.fontSize,
                fontWeight:
                    widget.isNumber
                        ? FontWeight.normal
                        : FontWeight.bold,
                letterSpacing:
                    widget.isNumber
                        ? 1.5
                        : 0.5,
                shadows:
                    widget.isNumber
                        ? [
                            Shadow(
                              color: foreground
                                  .withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 3,
                            ),
                          ]
                        : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GaosDialog
    extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _GaosDialog({
    required this.title,
    required this.child,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          const Color(0xFF0D110F),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
        side:
            const BorderSide(
          color: Color(0xFF29442F),
        ),
      ),
      title: Text(
        title,
        style:
            const TextStyle(
          fontFamily: 'Pricedown',
          color:
              Color(0xFF39FF14),
          fontSize: 25,
        ),
      ),
      content: child,
      actions: [
        TextButton(
          onPressed: onCancel,
          child:
              const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(
              0xFF39FF14,
            ),
            foregroundColor:
                Colors.black,
          ),
          child:
              const Text('CALCULAR'),
        ),
      ],
    );
  }
}

class _GaosMessageDialog
    extends StatelessWidget {
  final String title;
  final String message;
  final bool error;

  const _GaosMessageDialog({
    required this.title,
    required this.message,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = error
        ? Colors.redAccent
        : const Color(
            0xFF39FF14,
          );

    return AlertDialog(
      backgroundColor: error
          ? const Color(0xFF170707)
          : const Color(0xFF0D110F),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
        side:
            BorderSide(color: color),
      ),
      title: Row(
        children: [
          Icon(
            error
                ? Icons.warning_rounded
                : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily:
                    'Pricedown',
                color: color,
                fontSize: 23,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style:
            const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child:
              const Text('ACEPTAR'),
        ),
      ],
    );
  }
}