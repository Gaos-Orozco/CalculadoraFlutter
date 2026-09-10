class Validators {
  // Determina si un número es par
  bool esPar(int numero) {
    return numero % 2 == 0;
  }

  // Determina si un número es impar
  bool esImpar(int numero) {
    return numero % 2 != 0;
  }

  // Determina la paridad
  String determinarParidad(int numero) {
    return esPar(numero) ? 'Par' : 'Impar';
  }

  // Verifica que el texto corresponda a un número
  bool esNumeroValido(String valor) {
    return double.tryParse(valor) != null;
  }

  // Verifica que el texto corresponda a un entero
  bool esEntero(String valor) {
    return int.tryParse(valor) != null;
  }
}