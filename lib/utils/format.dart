String formatRupiah(int number) {
  final str = number.toString();
  final buffer = StringBuffer();
  int counter = 0;

  for (int i = str.length - 1; i >= 0; i--) {
    buffer.write(str[i]);
    counter++;
    if (counter == 3 && i != 0) {
      buffer.write('.');
      counter = 0;
    }
  }

  return 'Rp ${buffer.toString().split('').reversed.join()}';
}
