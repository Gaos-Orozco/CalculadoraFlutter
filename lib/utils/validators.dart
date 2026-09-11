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

 
}