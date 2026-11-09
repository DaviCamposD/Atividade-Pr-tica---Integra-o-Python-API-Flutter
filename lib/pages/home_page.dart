import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Consumer/context.watch, adicionado com "flutter pub add provider"

import '../models/voo.dart';
import '../providers/voo_provider.dart';
import 'detalhes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controller do campo de texto onde o usuário digita o código ICAO.
  final TextEditingController _aeroportoController =
      TextEditingController(text: 'SBGR');

  @override
  void initState() {
    super.initState();
    // Assim que a tela abre, dispara a primeira busca.
    // "listen: false" porque aqui só estamos CHAMANDO um método,
    // não precisamos que este widget seja reconstruído por essa chamada.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VooProvider>().buscarVoos();
    });
  }

  @override
  void dispose() {
    _aeroportoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // context.watch reconstrói este widget sempre que o provider chama notifyListeners().
    final provider = context.watch<VooProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('RaspaVoo')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buscaAeroporto(context),
            const SizedBox(height: 8),
            _filtroTipo(context, provider),
            const SizedBox(height: 8),
            Expanded(child: _conteudo(context, provider)),
          ],
        ),
      ),
    );
  }

  // Campo de texto + botão para digitar o código ICAO (ex.: SBGR) e buscar.
  Widget _buscaAeroporto(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _aeroportoController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 4,
            decoration: const InputDecoration(
              labelText: 'Código ICAO (ex.: SBGR)',
              counterText: '',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            final codigo = _aeroportoController.text.trim().toUpperCase();
            if (codigo.length == 4) {
              context.read<VooProvider>().buscarVoos(aeroporto: codigo);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Digite um código ICAO de 4 letras')),
              );
            }
          },
          child: const Text('Buscar'),
        ),
      ],
    );
  }

  // Segmented control simples para escolher chegadas / partidas / todos.
  Widget _filtroTipo(BuildContext context, VooProvider provider) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'todos', label: Text('Todos')),
        ButtonSegment(value: 'chegadas', label: Text('Chegadas')),
        ButtonSegment(value: 'partidas', label: Text('Partidas')),
      ],
      selected: {provider.tipo},
      onSelectionChanged: (novoValor) {
        context.read<VooProvider>().buscarVoos(tipo: novoValor.first);
      },
    );
  }

  // Decide o que mostrar: carregando, erro, lista vazia ou lista de voos.
  Widget _conteudo(BuildContext context, VooProvider provider) {
    if (provider.carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                provider.erro!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.read<VooProvider>().buscarVoos(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.voos.isEmpty) {
      return const Center(child: Text('Nenhum voo encontrado.'));
    }

    return ListView.separated(
      itemCount: provider.voos.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final voo = provider.voos[index];
        return _cartaoVoo(context, voo);
      },
    );
  }

  // Um item da lista. Ao tocar, navega para a tela de detalhes daquele voo.
  Widget _cartaoVoo(BuildContext context, Voo voo) {
    return ListTile(
      leading: const Icon(Icons.flight),
      title: Text(voo.identificacao),
      subtitle: Text('${voo.categoria} • ${voo.local ?? '-'}'),
      trailing: Text(voo.partida ?? ''),
      onTap: () {
        // Navigator.push troca de tela, empilhando a nova tela por cima da atual.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalhesPage(voo: voo),
          ),
        );
      },
    );
  }
}
