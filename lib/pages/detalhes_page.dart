import 'package:flutter/material.dart';

import '../models/voo.dart';

// Essa tela é "burra" de propósito: ela só recebe o Voo já pronto
// (via construtor) e mostra os dados. Ela não fala com o Provider nem
// com a Service — os dados já chegaram prontos da HomePage.
class DetalhesPage extends StatelessWidget {
  final Voo voo;

  const DetalhesPage({super.key, required this.voo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voo ${voo.identificacao}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _linha('Identificação', voo.identificacao),
          _linha('Categoria', voo.categoria),
          _linha('Tipo de aeronave', voo.tipoAeronave ?? '-'),
          _linha('Local', voo.local ?? '-'),
          _linha('Partida', voo.partida ?? '-'),
          _linha('Chegada', voo.chegada ?? '-'),
        ],
      ),
    );
  }

  Widget _linha(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(valor, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
