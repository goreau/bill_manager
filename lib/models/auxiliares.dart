

class ResumoDivida {
  final String devedor;
  final String credor;
  final double valor;

  ResumoDivida(this.devedor, this.credor, this.valor);


  @override
  String toString() {
    return '$devedor deve R\$ $valor para $credor';
  }
}


