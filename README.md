# 📚 Biblioteca Pessoal

Aplicativo Flutter para gerenciar sua coleção pessoal de livros com interface moderna e intuitiva.

## ✨ Funcionalidades

- ✅ Adicionar livros com título, autor e status
- ✅ Editar informações dos livros
- ✅ Remover livros da biblioteca
- ✅ Buscar livros por título ou autor
- ✅ Filtrar livros por status (Quero Ler, Lendo, Lido)
- ✅ Interface com gradientes e design moderno
- ✅ Armazenamento local com Hive (NoSQL)

## 🛠️ Tecnologias

- **Flutter** - Framework para desenvolvimento mobile
- **Hive** - Banco de dados NoSQL local e rápido
- **Material Design** - Componentes visuais do Google

## 📋 Pré-requisitos

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Emulador ou dispositivo físico

## 🚀 Como executar

1. Clone o repositório
```bash
git clone <seu-repositorio>
cd biblioteca_pessoal
```

2. Instale as dependências
```bash
flutter pub get
```

3. Execute o aplicativo
```bash
flutter run
```

## 📦 Dependências

Adicione no `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

## 📱 Estrutura do App

```
lib/
├── main.dart          # Código principal do app
└── (modelo Livro, páginas e funções inclusos)
```

## 🎨 Telas

1. **Loading** - Tela inicial com logo
2. **Minha Lista** - Lista todos os livros com busca e filtros
3. **Adicionar Livro** - Formulário para novo livro
4. **Editar Livro** - Editar ou remover livro existente

## 💾 Banco de Dados

O Hive salva os dados localmente em:
- **Android:** `/data/data/com.seuapp/files/`
- **iOS:** `Library/Application Support/`
- **Arquivo:** `livros.hive`

## 📝 Modelo de Dados

```dart
Livro {
  String id;        // ID único gerado automaticamente
  String titulo;    // Título do livro
  String autor;     // Nome do autor
  StatusLivro status; // queroLer, lendo ou lido
}
```

## 🎯 Status Disponíveis

- 🔴 **Quero Ler** - Livros na lista de desejos
- 🔵 **Lendo** - Livros em progresso
- 🟢 **Lido** - Livros completados

## 🤝 Contribuindo

Sinta-se à vontade para contribuir com melhorias:

1. Fork o projeto
2. Crie sua feature branch (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é de código aberto e está disponível sob a licença MIT.

## 👤 Autor

Desenvolvido com ❤️ usando Flutter

---

⭐ Se gostou do projeto, deixe uma estrela!
