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

  // Suma de los dígitos
  int sumaDigitos(int numero) {
    int n = numero.abs();
    int suma = 0;

    while (n > 0) {
      suma += n % 10;
      n ~/= 10;
    }

    return suma;
  }

  // Determina si un número es primo
  bool esPrimo(int numero) {
    if (numero < 2) {
      return false;
    }

    for (int i = 2; i <= sqrt(numero); i++) {
      if (numero % i == 0) {
        return false;
      }
    }

    return true;
  }

  // Determina si un número es cuadrado perfecto
  bool esCuadradoPerfecto(int numero) {
    if (numero < 0) {
      return false;
    }

    int raiz = sqrt(numero).toInt();

    return raiz * raiz == numero;
  }
}