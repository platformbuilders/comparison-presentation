# Calculadora Compra vs. Locação

Uma calculadora financeira construída com Flutter para ajudar na tomada de decisão entre comprar ou alugar um ativo.

## Sobre o Produto

Este aplicativo foi projetado para fornecer uma análise comparativa detalhada entre os custos de aquisição e locação de um bem. Ele calcula o **custo médio mensal** para ambos os cenários, permitindo que os usuários entendam qual opção é financeiramente mais vantajosa a médio e longo prazo.

### Funcionalidades Principais

- **Comparação Direta:** Apresenta lado a lado (ou um acima do outro, em dispositivos móveis) os cenários de **Compra** e **Locação**.
- **Custo Médio Mensal:** Calcula e exibe o custo médio mensal para cada opção, simplificando a comparação.
- **Indicação da Melhor Opção:** Destaca visualmente qual cenário é o mais econômico com base nos dados inseridos.
- **Cálculo de Equivalência:** Ao alterar o valor de compra ou de locação, o aplicativo calcula automaticamente o valor correspondente no outro cenário que resultaria em um custo médio mensal equivalente.
- **Parâmetros Configuráveis:** A lógica de cálculo (encontrada em `lib/services/calculator.dart`) leva em consideração diversas variáveis, como:
  - Frete
  - Taxa de seguro
  - Custos anuais de licenças
  - Percentual de manutenção
  - Valor residual do ativo (para o cenário de compra)

## Tecnologias

- **Framework:** Flutter
- **Linguagem:** Dart

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
