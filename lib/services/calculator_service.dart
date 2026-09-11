import 'dart:math';

class CalculatorService {
  // Suma
  double sumar(double a, double b) {
    return a + b;
  }

  // Resta
  double restar(double a, double b) {
    return a - b;
  }

  // Multiplicación
  double multiplicar(double a, double b) {
    return a * b;
  }

  // División
  double dividir(double a, double b) {
    if (b == 0) {
      throw Exception('No se puede dividir entre cero');
    }

    return a / b;
  }

  // Cociente de una división entera
  int cociente(int a, int b) {
    if (b == 0) {
      throw Exception('No se puede dividir entre cero');
    }

    return a ~/ b;
  }

  // Residuo de una división entera
  int residuo(int a, int b) {
    if (b == 0) {
      throw Exception('No se puede dividir entre cero');
    }

    return a % b;
  }

  // Potenciación
  double potencia(double a, double b) {
    return pow(a, b).toDouble();
  }

  // Radicación cuadrada
  double raiz(double a) {
    if (a < 0) {
      throw Exception(
        'No se puede calcular la raíz de un número negativo',
      );
    }

    return sqrt(a);
  }

  // Logaritmo base 10
  double logaritmo(double a) {
    if (a <= 0) {
      throw Exception(
        'El logaritmo solo está definido para números mayores que cero',
      );
    }

    return log(a) / ln10;
  }

}