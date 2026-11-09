// O Provider fica "no meio" entre a Page e a Service.
// Ele guarda o ESTADO do app (o que já foi buscado, se está carregando,
// se deu erro) e avisa as telas quando esse estado muda, usando notifyListeners().
//
// ChangeNotifier é uma classe do Flutter que implementa esse "sistema de aviso":
// qualquer widget que "escuta" este provider é reconstruído automaticamente
// quando notifyListeners() é chamado.

import 'package:flutter/foundation.dart'; // dá acesso a ChangeNotifier

import '../models/voo.dart';
import '../services/voo_service.dart';

class VooProvider extends ChangeNotifier {
  final VooService _service = VooService();

  // Estado interno (privado, com "_"). As telas não alteram isso direto,
  // só leem através dos getters abaixo — isso evita que uma tela mude o
  // estado "por fora" sem o provider saber.
  ResultadoBusca? _resultado;
  bool _carregando = false;
  String? _erro;
  String _aeroporto = 'SBGR';
  String _tipo = 'todos';

  // Getters: forma somente-leitura de acessar o estado a partir das telas.
  List<Voo> get voos => _resultado?.voos ?? [];
  int get total => _resultado?.total ?? 0;
  bool get carregando => _carregando;
  String? get erro => _erro;
  String get aeroporto => _aeroporto;
  String get tipo => _tipo;

  // Chamado pela HomePage assim que ela é construída, e sempre que o
  // usuário troca o aeroporto ou o tipo de voo.
  Future<void> buscarVoos({String? aeroporto, String? tipo}) async {
    if (aeroporto != null) _aeroporto = aeroporto;
    if (tipo != null) _tipo = tipo;

    _carregando = true;
    _erro = null;
    notifyListeners(); // avisa a tela: "comece a mostrar o indicador de carregamento"

    try {
      _resultado = await _service.buscarVoos(aeroporto: _aeroporto, tipo: _tipo);
    } catch (e) {
      _erro = e.toString().replaceFirst('Exception: ', '');
      _resultado = null;
    } finally {
      _carregando = false;
      notifyListeners(); // avisa a tela: "dados novos (ou erro) chegaram, atualize"
    }
  }
}
