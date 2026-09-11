class Validators {
  bool esPar(int numero) => numero % 2 == 0;

  String determinarParidad(int numero) {
    return esPar(numero) ? 'Par' : 'Impar';
  }
}