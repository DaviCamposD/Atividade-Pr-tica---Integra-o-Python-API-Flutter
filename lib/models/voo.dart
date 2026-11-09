// Representa UM voo dentro da lista "voos" que a API Python devolve.
// Ter essa classe evita ficar lendo Map<String, dynamic>["chave"] espalhado
// pelo código — você converte o JSON uma vez aqui e usa objetos Dart no resto do app.
class Voo {
  final String categoria;       // ex: "chegadas", "partidas", "em_rota"
  final String identificacao;   // ex: "GLO1234" (o "voo" em si)
  final String? tipoAeronave;   // pode vir null da API
  final String? local;          // origem/destino, depende da categoria
  final String? partida;        // horário de partida (texto)
  final String? chegada;        // horário de chegada (texto)

  Voo({
    required this.categoria,
    required this.identificacao,
    this.tipoAeronave,
    this.local,
    this.partida,
    this.chegada,
  });

  // factory = um construtor nomeado que sabe "fabricar" um Voo a partir
  // de um Map (que é o que o pacote json vira quando decodifica o texto da API).
  factory Voo.fromJson(Map<String, dynamic> json) {
    return Voo(
      categoria: json['categoria'] as String? ?? '',
      identificacao: json['identificacao'] as String? ?? '',
      tipoAeronave: json['tipo_aeronave'] as String?,
      local: json['local'] as String?,
      partida: json['partida'] as String?,
      chegada: json['chegada'] as String?,
    );
  }
}

// Representa a RESPOSTA COMPLETA de GET /api/voos, que tem metadados
// (aeroporto, total, etc.) além da lista de voos.
class ResultadoBusca {
  final String fonte;
  final String aeroporto;
  final String tipoBusca;
  final int total;
  final List<Voo> voos;

  ResultadoBusca({
    required this.fonte,
    required this.aeroporto,
    required this.tipoBusca,
    required this.total,
    required this.voos,
  });

  factory ResultadoBusca.fromJson(Map<String, dynamic> json) {
    // json['voos'] chega como List<dynamic>; cada item é um Map<String, dynamic>.
    // O .map(...) transforma cada Map em um objeto Voo, e o .toList() fecha a lista.
    final listaVoos = (json['voos'] as List<dynamic>? ?? [])
        .map((item) => Voo.fromJson(item as Map<String, dynamic>))
        .toList();

    return ResultadoBusca(
      fonte: json['fonte'] as String? ?? '',
      aeroporto: json['aeroporto'] as String? ?? '',
      tipoBusca: json['tipo_busca'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      voos: listaVoos,
    );
  }
}
