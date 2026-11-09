// A Service é a ÚNICA camada que sabe fazer requisição HTTP.
// Nenhuma tela (page) e nenhum provider deveriam usar o pacote http diretamente —
// eles sempre passam por aqui. Isso é o que a atividade chama de
// "separação de responsabilidades".

import 'dart:convert'; // jsonDecode: transforma texto JSON em Map/List do Dart
import 'package:http/http.dart' as http; // pacote http, adicionado com "flutter pub add http"

import '../models/voo.dart';

class VooService {
  // Endereço base da API Flask. Como o app.py roda com port=5001,
  // usamos 5001 aqui (confira sempre o que aparece no terminal do Python).
  //
  // Se você rodar o Flutter Web no navegador do mesmo computador, "localhost"
  // funciona. Se testar em emulador Android, troque para 10.0.2.2 no lugar
  // de localhost (o emulador não enxerga "localhost" como a sua máquina).
  static const String _baseUrl = 'http://127.0.0.1:5001';

  // Busca os voos de um aeroporto na API.
  // aeroporto: código ICAO de 4 letras, ex.: "SBGR".
  // tipo: "chegadas" | "partidas" | "todos".
  Future<ResultadoBusca> buscarVoos({
    required String aeroporto,
    required String tipo,
  }) async {
    // Uri.parse monta a URL com query params de forma segura
    // (evita erro de concatenar strings manualmente com "?" e "&").
    final uri = Uri.parse('$_baseUrl/api/voos').replace(
      queryParameters: {
        'aeroporto': aeroporto,
        'tipo': tipo,
      },
    );

    late final http.Response resposta;
    try {
      // await pausa a execução até a resposta chegar, sem travar a UI do app.
      resposta = await http.get(uri).timeout(const Duration(seconds: 20));
    } catch (e) {
      // Erro de rede (API fora do ar, sem internet, CORS bloqueado, etc.)
      throw Exception('Não foi possível conectar à API Python: $e');
    }

    if (resposta.statusCode != 200) {
      // A API Python devolve {"erro": "..."} com status 400/502 em caso de problema.
      // Tentamos ler essa mensagem para mostrar algo útil ao usuário.
      try {
        final corpoErro = jsonDecode(resposta.body) as Map<String, dynamic>;
        throw Exception(corpoErro['erro'] ?? 'Erro ${resposta.statusCode} na API');
      } catch (_) {
        throw Exception('Erro ${resposta.statusCode} ao consultar a API');
      }
    }

    // resposta.body é uma String JSON; jsonDecode transforma em Map<String, dynamic>.
    final Map<String, dynamic> dados = jsonDecode(resposta.body) as Map<String, dynamic>;

    // Converte o Map cru em um objeto ResultadoBusca (ver models/voo.dart).
    return ResultadoBusca.fromJson(dados);
  }
}
