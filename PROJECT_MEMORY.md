# Memória do Projeto - Calculador Compra × Locação

## Estado Atual: MVP Implementado
**Data Início**: 2025-01-28
**Última Atualização**: 2025-01-28 00:38

## Visão Geral
MVP de calculadora Flutter Web para comparar custo de compra vs locação de equipamentos ao longo de 5 anos.

## Stack Definida
- Flutter Web (foco principal)
- Firebase Realtime Database (estado reativo)
- Firebase Hosting
- Design: Split-screen colorido (azul/preto)

## Arquitetura
- FirebaseStore<T> genérico para estado observable
- DataRepository central
- Stream-based UI com Firebase
- Sem backend próprio

## Progresso

### ✅ Concluído
- [x] Análise de especificação
- [x] Definição de arquitetura
- [x] Análise de referência visual
- [x] Setup inicial do projeto Flutter
- [x] Implementação dos models (CalcParams)
- [x] Implementação do Calculator service
- [x] FirebaseStore genérico observable
- [x] DataRepository central
- [x] UI split-screen com cores vibrantes
- [x] Inputs reativos (bidirecionais)
- [x] Responsividade (desktop/mobile)
- [x] Versão demo sem Firebase (main_demo.dart)

### 🔄 Em Andamento
- [ ] Configurar Firebase real (usando credenciais demo)
- [ ] Testar com Firebase real

### 📋 Próximos Passos
1. Criar projeto Firebase real
2. Atualizar firebase_options.dart com credenciais reais
3. Deploy no Firebase Hosting
4. Implementar modal de configurações completo
5. Sistema de sessões/backlog

## Estrutura de Arquivos
```
comparison_calculator/
├── lib/
│   ├── core/
│   │   ├── firebase_store.dart
│   │   └── data_repository.dart
│   ├── models/
│   │   └── calc_params.dart
│   ├── services/
│   │   └── calculator.dart
│   ├── screens/
│   │   └── home_screen.dart
│   ├── widgets/
│   │   └── cost_side.dart
│   ├── theme/
│   │   └── app_colors.dart
│   ├── main.dart (com Firebase)
│   └── main_demo.dart (sem Firebase)
└── web/
    └── index.html
```

## Decisões Importantes
1. **Estado**: 100% Firebase Realtime Database
2. **Design**: Inspirado no app financeiro de referência (cores vibrantes)
3. **Foco**: Web-first, mobile depois
4. **Simplicidade**: Apenas o essencial no MVP
5. **Demo Mode**: Criado main_demo.dart para testar sem Firebase

## Funcionalidades Implementadas
- ✅ Split-screen azul/preto
- ✅ Inputs grandes e limpos
- ✅ Cálculo automático de equivalência
- ✅ Indicador de melhor opção
- ✅ Responsividade desktop/mobile
- ✅ AppBar com botão de configurações (placeholder)
- ✅ Formatação de moeda brasileira

## Notas Técnicas
- Fórmulas de cálculo implementadas conforme spec
- Equivalência automática funcionando
- 60 meses de análise (5 anos)
- Considera: frete, seguro, manutenção, licenças
- Modo demo funcional para testes locais

## Como Rodar
```bash
# Modo demo (sem Firebase)
flutter run -d chrome --target lib/main_demo.dart

# Modo completo (requer Firebase configurado)
flutter run -d chrome
```