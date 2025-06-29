# Testes Unitários - Calculadora Compra vs Locação

## Estrutura dos Testes

### `calculator_test.dart`
Testes abrangentes para a lógica de cálculo financeiro do aplicativo.

#### Grupos de Testes:

##### 1. **Cálculo de Compra**
- ✅ Validação do CAPEX (valor + seguro + frete)
- ✅ Cálculo de manutenção anual
- ✅ Depreciação baseada no período real
- ✅ Benefícios fiscais (IR/CSLL)
- ✅ Custo médio mensal
- ✅ Fluxos de caixa mensais
- ✅ Configuração de benefícios fiscais

##### 2. **Cálculo de Locação**
- ✅ Valor mensal de locação
- ✅ Benefícios fiscais da locação
- ✅ Manutenção inclusa/separada
- ✅ Fluxos de caixa mensais

##### 3. **Cálculo de Equivalência**
- ✅ Equivalência compra → locação
- ✅ Equivalência locação → compra
- ✅ Convergência entre métodos

##### 4. **Cenários Específicos**
- ✅ Períodos diferentes (1, 3, 5 anos)
- ✅ Alíquotas variadas (incluindo zero)
- ✅ Manutenção zero
- ✅ Cálculo VPL vs Nominal

##### 5. **Validação de Cenário Real**
- ✅ Cenário específico: R$ 10.000, 3 anos, 3% manutenção, 25,20% IR
- ✅ Validação matemática completa

## Executar os Testes

### Todos os testes de cálculo:
```bash
flutter test test/calculator_test.dart
```

### Todos os testes (pode ter erros de layout):
```bash
flutter test
```

### Com cobertura:
```bash
flutter test test/calculator_test.dart --coverage
```

## Validações Principais

### Cenário Padrão (R$ 10.000, 3 anos):
- **CAPEX**: R$ 10.340 (equipamento + seguro + frete)
- **Depreciação anual**: R$ 3.333,33 (33,33% ao ano)
- **Benefício fiscal anual**: R$ 840,00 (25,20% sobre depreciação)
- **Custo líquido mensal**: R$ 242,22

### Cobertura:
- ✅ 20 testes passando
- ✅ Todos os cálculos financeiros cobertos
- ✅ Cenários extremos testados
- ✅ Validação matemática rigorosa

## Estrutura dos Dados de Teste

```dart
CalcParams(
  valorCompra: 10000,
  valorLocacao: 1000,
  periodoAnos: 3,
  manutencaoPct: 3.0,
  aliquotaIR: 25.20,
  considerarBeneficioFiscal: true,
  usarValorNominal: true,
)
```