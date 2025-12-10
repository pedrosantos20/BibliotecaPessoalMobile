import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Modelo de Livro
class Livro {
  String id;
  String titulo;
  String autor;
  StatusLivro status;

  Livro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'autor': autor,
    'status': status.toString(),
  };

  factory Livro.fromJson(Map<String, dynamic> json) => Livro(
    id: json['id'],
    titulo: json['titulo'],
    autor: json['autor'],
    status: StatusLivro.values.firstWhere(
      (e) => e.toString() == json['status'],
    ),
  );
}

enum StatusLivro { queroLer, lendo, lido }

extension StatusLivroExt on StatusLivro {
  String get nome {
    switch (this) {
      case StatusLivro.queroLer:
        return 'Quero Ler';
      case StatusLivro.lendo:
        return 'Lendo';
      case StatusLivro.lido:
        return 'Lido';
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('livros');
  runApp(const BibliotecaPessoalApp());
}

class BibliotecaPessoalApp extends StatelessWidget {
  const BibliotecaPessoalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca Pessoal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF2C2C2C),
      ),
      home: const LoadingPage(),
    );
  }
}

// Loading Page
class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MinhaLista()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/books.png',
                width: 120,
                height: 120,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.book,
                  size: 120,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Biblioteca Pessoal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Minha Lista Page
class MinhaLista extends StatefulWidget {
  const MinhaLista({Key? key}) : super(key: key);

  @override
  State<MinhaLista> createState() => _MinhaListaState();
}

class _MinhaListaState extends State<MinhaLista> {
  final box = Hive.box('livros');
  List<Livro> livros = [];
  List<Livro> livrosFiltrados = [];
  String searchQuery = '';
  StatusLivro? filtroStatus;

  @override
  void initState() {
    super.initState();
    carregarLivros();
  }

  void carregarLivros() {
    livros = [];
    for (var key in box.keys) {
      final data = Map<String, dynamic>.from(box.get(key));
      livros.add(Livro.fromJson(data));
    }
    aplicarFiltros();
  }

  void aplicarFiltros() {
    setState(() {
      livrosFiltrados = livros.where((livro) {
        final matchQuery = livro.titulo.toLowerCase().contains(searchQuery.toLowerCase()) ||
            livro.autor.toLowerCase().contains(searchQuery.toLowerCase());
        final matchStatus = filtroStatus == null || livro.status == filtroStatus;
        return matchQuery && matchStatus;
      }).toList();
    });
  }

  void mostrarFiltros() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Filtrar'),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<StatusLivro?>(
              title: const Text('Quero Ler'),
              value: StatusLivro.queroLer,
              groupValue: filtroStatus,
              onChanged: (v) {
                setState(() => filtroStatus = v);
                aplicarFiltros();
                Navigator.pop(context);
              },
            ),
            RadioListTile<StatusLivro?>(
              title: const Text('Lendo'),
              value: StatusLivro.lendo,
              groupValue: filtroStatus,
              onChanged: (v) {
                setState(() => filtroStatus = v);
                aplicarFiltros();
                Navigator.pop(context);
              },
            ),
            RadioListTile<StatusLivro?>(
              title: const Text('Lido'),
              value: StatusLivro.lido,
              groupValue: filtroStatus,
              onChanged: (v) {
                setState(() => filtroStatus = v);
                aplicarFiltros();
                Navigator.pop(context);
              },
            ),
            const Divider(),
            TextButton.icon(
              onPressed: () {
                setState(() => filtroStatus = null);
                aplicarFiltros();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.clear_all, color: Colors.red),
              label: const Text(
                'Limpar Filtros',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade600, Colors.blue.shade400],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Biblioteca Pessoal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (v) {
                    searchQuery = v;
                    aplicarFiltros();
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: filtroStatus != null ? Colors.blue : Colors.grey,
                      ),
                      onPressed: mostrarFiltros,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    ),
                  ),
                  child: livrosFiltrados.isEmpty
                      ? const Center(child: Text('Nenhum livro adicionado'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: livrosFiltrados.length,
                          itemBuilder: (context, i) {
                            final livro = livrosFiltrados[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 15),
                              elevation: 2,
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: livro.status == StatusLivro.lido
                                          ? [Colors.green.shade600, Colors.green.shade400]
                                          : livro.status == StatusLivro.lendo
                                              ? [Colors.blue.shade600, Colors.blue.shade400]
                                              : [Colors.red.shade600, Colors.red.shade400],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.book, color: Colors.white),
                                ),
                                title: Text(
                                  livro.titulo,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${livro.autor}\nStatus: ${livro.status.nome}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                                isThreeLine: true,
                                onTap: () async {
                                  final resultado = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditarLivro(livro: livro),
                                    ),
                                  );
                                  carregarLivros();
                                  
                                  // Se retornou true, significa que removeu o livro
                                  if (resultado == true && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.white),
                                            SizedBox(width: 10),
                                            Text('Livro Removido!'),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdicionarLivro()),
          );
          carregarLivros();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Adicionar Livro Page
class AdicionarLivro extends StatefulWidget {
  const AdicionarLivro({Key? key}) : super(key: key);

  @override
  State<AdicionarLivro> createState() => _AdicionarLivroState();
}

class _AdicionarLivroState extends State<AdicionarLivro> {
  final tituloCtrl = TextEditingController();
  final autorCtrl = TextEditingController();
  StatusLivro status = StatusLivro.queroLer;
  final box = Hive.box('livros');

  void salvar() {
    if (tituloCtrl.text.isEmpty || autorCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    final livro = Livro(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: tituloCtrl.text,
      autor: autorCtrl.text,
      status: status,
    );

    box.put(livro.id, livro.toJson());
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 15),
            const Text('Livro Salvo!', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade600, Colors.blue.shade400],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Biblioteca Pessoal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adicionar Livro',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      const Text('Título', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: tituloCtrl,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Autor(s)', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: autorCtrl,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Status', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      RadioListTile<StatusLivro>(
                        title: const Text('Quero Ler'),
                        value: StatusLivro.queroLer,
                        groupValue: status,
                        onChanged: (v) => setState(() => status = v!),
                      ),
                      RadioListTile<StatusLivro>(
                        title: const Text('Lendo'),
                        value: StatusLivro.lendo,
                        groupValue: status,
                        onChanged: (v) => setState(() => status = v!),
                      ),
                      RadioListTile<StatusLivro>(
                        title: const Text('Lido'),
                        value: StatusLivro.lido,
                        groupValue: status,
                        onChanged: (v) => setState(() => status = v!),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: salvar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Adicionar',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Editar Livro Page
class EditarLivro extends StatefulWidget {
  final Livro livro;
  const EditarLivro({Key? key, required this.livro}) : super(key: key);

  @override
  State<EditarLivro> createState() => _EditarLivroState();
}

class _EditarLivroState extends State<EditarLivro> {
  late TextEditingController tituloCtrl;
  late TextEditingController autorCtrl;
  late StatusLivro status;
  final box = Hive.box('livros');

  @override
  void initState() {
    super.initState();
    tituloCtrl = TextEditingController(text: widget.livro.titulo);
    autorCtrl = TextEditingController(text: widget.livro.autor);
    status = widget.livro.status;
  }

  void salvar() {
    if (tituloCtrl.text.isEmpty || autorCtrl.text.isEmpty) return;

    final livro = Livro(
      id: widget.livro.id,
      titulo: tituloCtrl.text,
      autor: autorCtrl.text,
      status: status,
    );

    box.put(livro.id, livro.toJson());
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 15),
            const Text('Livro Editado!', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  void remover() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Deseja remover este livro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Remove do banco
              box.delete(widget.livro.id);
              
              // Fecha o dialog de confirmação
              Navigator.pop(dialogContext);
              
              // Volta para tela inicial
              Navigator.pop(context, true);
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade600, Colors.blue.shade400],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Biblioteca Pessoal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Editar Livro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 30),
                        const Text('Título', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: tituloCtrl,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Autor(s)', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: autorCtrl,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Status', style: TextStyle(fontWeight: FontWeight.w500)),
                        RadioListTile<StatusLivro>(
                          title: const Text('Quero Ler'),
                          value: StatusLivro.queroLer,
                          groupValue: status,
                          onChanged: (v) => setState(() => status = v!),
                        ),
                        RadioListTile<StatusLivro>(
                          title: const Text('Lendo'),
                          value: StatusLivro.lendo,
                          groupValue: status,
                          onChanged: (v) => setState(() => status = v!),
                        ),
                        RadioListTile<StatusLivro>(
                          title: const Text('Lido'),
                          value: StatusLivro.lido,
                          groupValue: status,
                          onChanged: (v) => setState(() => status = v!),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: salvar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Editar', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: remover,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Remover', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}