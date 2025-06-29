import 'package:flutter_test/flutter_test.dart';
import 'package:comparison_calculator/models/calc_params.dart';
import 'package:comparison_calculator/services/calculator.dart';

void main() {
  group('Calculator Tests', () {
    late CalcParams defaultParams;
    
    setUp(() {
      defaultParams = const CalcParams(
        valorCompra: 10000,
        valorLocacao: 1000,
        periodoAnos: 3,
        manutencaoPct: 3.0,
        aliquotaIR: 34.0,
        considerarBeneficioFiscal: true,
        usarValorNominal: true,
        seguroTx: 0.0,
      );
    });

    group('Cálculo de Compra', () {
      test('deve calcular CAPEX corretamente com seguro zero', () {
        final result = Calculator.calcularCompra(defaultParams);
        
        // CAPEX = valorCompra + frete + frete + seguro
        // CAPEX = 10000 + 120 + 120 + 0 = 10240
        expect(result.detalhes['valorCompra'], equals(10000.0));
        expect(result.detalhes['seguro'], equals(0.0)); // 0% de 10000
        expect(result.detalhes['seguroTx'], equals(0.0));
        expect(result.detalhes['freteTotal'], equals(240.0)); // 120 * 2
        expect(result.detalhes['capex'], equals(10240.0));
      });

      test('deve calcular CAPEX corretamente com seguro 1%', () {
        final paramsComSeguro = defaultParams.copyWith(seguroTx: 1.0);
        final result = Calculator.calcularCompra(paramsComSeguro);
        
        // CAPEX = valorCompra + frete + frete + seguro
        // CAPEX = 10000 + 120 + 120 + 100 = 10340
        expect(result.detalhes['valorCompra'], equals(10000.0));
        expect(result.detalhes['seguro'], equals(100.0)); // 1% de 10000
        expect(result.detalhes['seguroTx'], equals(1.0));
        expect(result.detalhes['freteTotal'], equals(240.0)); // 120 * 2
        expect(result.detalhes['capex'], equals(10340.0));
      });

      test('deve calcular manutenção corretamente', () {
        final result = Calculator.calcularCompra(defaultParams);
        
        // Manutenção anual = 10000 * 3% = 300
        expect(result.detalhes['manutencaoAnual'], equals(300.0));
        expect(result.detalhes['manutencaoPct'], equals(3.0));
      });

      test('deve calcular depreciação corretamente', () {
        final result = Calculator.calcularCompra(defaultParams);
        
        // Depreciação anual = valorCompra / periodo = 10000 / 3 = 3333.33
        expect(result.detalhes['depreciacaoAnual'], closeTo(3333.33, 0.01));
      });

      test('deve calcular benefício fiscal corretamente', () {
        final result = Calculator.calcularCompra(defaultParams);
        
        // Benefício fiscal anual = 3333.33 * 34.0% = 1133.33
        expect(result.detalhes['beneficioFiscalAnual'], closeTo(1133.33, 0.01));
        expect(result.detalhes['beneficioFiscalMensal'], closeTo(94.44, 0.01));
      });

      test('deve calcular custo médio mensal corretamente', () {
        final result = Calculator.calcularCompra(defaultParams);
        
        // Custo médio mensal deve ser positivo e razoável
        // Com alíquota 34%, o valor deve ser menor devido ao maior benefício fiscal
        expect(result.custoMedioMensal, greaterThan(0));
        expect(result.custoMedioMensal, closeTo(215.00, 1.0)); // Valor com alíquota 34%
      });

      test('deve calcular custo com seguro máximo (10%)', () {
        final paramsSeguroMax = defaultParams.copyWith(seguroTx: 10.0);
        final result = Calculator.calcularCompra(paramsSeguroMax);
        
        // Seguro de 10% = 1000 em 10000
        expect(result.detalhes['seguro'], equals(1000.0));
        expect(result.detalhes['capex'], equals(11240.0)); // 10000 + 240 + 1000
        expect(result.custoMedioMensal, greaterThan(0));
      });

      test('deve desativar benefício fiscal quando configurado', () {
        final paramsSemBeneficio = defaultParams.copyWith(
          considerarBeneficioFiscal: false,
        );
        final result = Calculator.calcularCompra(paramsSemBeneficio);
        
        expect(result.detalhes['beneficioFiscalAnual'], equals(0.0));
        expect(result.detalhes['beneficioFiscalMensal'], equals(0.0));
      });

      test('deve gerar fluxos de caixa corretos', () {
        final result = Calculator.calcularCompra(defaultParams);
        
        // Deve ter 37 fluxos (1 inicial + 36 mensais)
        expect(result.fluxos.length, equals(37));
        
        // Primeiro fluxo deve ser negativo (CAPEX sem seguro)
        expect(result.fluxos[0], equals(-10240.0));
        
        // Fluxos mensais = -manutenção + benefício fiscal
        // Manutenção mensal = 300/12 = 25
        // Benefício fiscal mensal = 1133.33/12 = 94.44
        // Fluxo mensal = -25 + 94.44 = 69.44 (positivo!)
        for (int i = 1; i < result.fluxos.length; i++) {
          expect(result.fluxos[i], closeTo(69.44, 0.01));
        }
      });
    });

    group('Cálculo de Locação', () {
      test('deve calcular locação corretamente', () {
        final result = Calculator.calcularLocacao(defaultParams);
        
        expect(result.detalhes['opexMensal'], equals(1000.0));
        expect(result.detalhes['freteTotal'], equals(0.0));
      });

      test('deve calcular benefício fiscal da locação corretamente', () {
        final result = Calculator.calcularLocacao(defaultParams);
        
        // Benefício fiscal mensal = 1000 * 34.0% = 340.00
        expect(result.detalhes['beneficioFiscalMensal'], closeTo(340.00, 0.01));
        expect(result.detalhes['beneficioFiscalAnual'], closeTo(4080.00, 0.01));
      });

      test('deve considerar manutenção quando não inclusa', () {
        final paramsManutencaoSeparada = defaultParams.copyWith(
          manutencaoInclusa: false,
        );
        final result = Calculator.calcularLocacao(paramsManutencaoSeparada);
        
        expect(result.detalhes['manutencaoInclusa'], equals(false));
      });

      test('deve gerar fluxos de caixa corretos', () {
        final result = Calculator.calcularLocacao(defaultParams);
        
        // Deve ter 36 fluxos mensais
        expect(result.fluxos.length, equals(36));
        
        // Todos os fluxos devem ser negativos (locação - benefício fiscal)
        for (final fluxo in result.fluxos) {
          expect(fluxo, lessThan(0));
        }
      });
    });

    group('Cálculo de Equivalência', () {
      test('deve calcular equivalência entre compra e locação', () {
        final equivalenteLocacao = Calculator.calcularEquivalente(
          valorBase: 10000,
          params: defaultParams,
          isCompra: true,
        );
        
        expect(equivalenteLocacao, greaterThan(0));
        expect(equivalenteLocacao, lessThan(10000)); // Deve ser menor que o valor de compra
      });

      test('deve calcular equivalência entre locação e compra', () {
        final equivalenteCompra = Calculator.calcularEquivalente(
          valorBase: 1000,
          params: defaultParams,
          isCompra: false,
        );
        
        expect(equivalenteCompra, greaterThan(1000));
      });

      test('deve manter equivalência próxima entre cálculos', () {
        final equivalenteLocacao = Calculator.calcularEquivalente(
          valorBase: 10000,
          params: defaultParams,
          isCompra: true,
        );
        
        final paramsEquivalentes = defaultParams.copyWith(
          valorLocacao: equivalenteLocacao,
        );
        
        final custoCompra = Calculator.calcularCompra(paramsEquivalentes).custoMedioMensal;
        final custoLocacao = Calculator.calcularLocacao(paramsEquivalentes).custoMedioMensal;
        
        expect((custoCompra - custoLocacao).abs(), lessThan(1.0));
      });
    });

    group('Cenários Específicos', () {
      test('deve lidar com período de 1 ano', () {
        final params1Ano = defaultParams.copyWith(periodoAnos: 1);
        final result = Calculator.calcularCompra(params1Ano);
        
        expect(result.fluxos.length, equals(13)); // 1 inicial + 12 mensais
        expect(result.detalhes['depreciacaoAnual'], equals(10000.0)); // 100% no primeiro ano
      });

      test('deve lidar com período de 5 anos', () {
        final params5Anos = defaultParams.copyWith(periodoAnos: 5);
        final result = Calculator.calcularCompra(params5Anos);
        
        expect(result.fluxos.length, equals(61)); // 1 inicial + 60 mensais
        expect(result.detalhes['depreciacaoAnual'], equals(2000.0)); // 20% ao ano
      });

      test('deve lidar com alíquota zero', () {
        final paramsAliquotaZero = defaultParams.copyWith(aliquotaIR: 0.0);
        final result = Calculator.calcularCompra(paramsAliquotaZero);
        
        expect(result.detalhes['beneficioFiscalAnual'], equals(0.0));
      });

      test('deve lidar com manutenção zero', () {
        final paramsManutencaoZero = defaultParams.copyWith(manutencaoPct: 0.0);
        final result = Calculator.calcularCompra(paramsManutencaoZero);
        
        expect(result.detalhes['manutencaoAnual'], equals(0.0));
      });

      test('deve lidar com diferentes taxas de seguro', () {
        // Teste com seguro 0%
        final resultSemSeguro = Calculator.calcularCompra(defaultParams);
        expect(resultSemSeguro.detalhes['seguro'], equals(0.0));
        
        // Teste com seguro 5%
        final paramsMedioSeguro = defaultParams.copyWith(seguroTx: 5.0);
        final resultMedioSeguro = Calculator.calcularCompra(paramsMedioSeguro);
        expect(resultMedioSeguro.detalhes['seguro'], equals(500.0)); // 5% de 10000
        
        // Teste com seguro 10%
        final paramsMaxSeguro = defaultParams.copyWith(seguroTx: 10.0);
        final resultMaxSeguro = Calculator.calcularCompra(paramsMaxSeguro);
        expect(resultMaxSeguro.detalhes['seguro'], equals(1000.0)); // 10% de 10000
        
        // Custos devem ser progressivos
        expect(resultSemSeguro.custoMedioMensal, lessThan(resultMedioSeguro.custoMedioMensal));
        expect(resultMedioSeguro.custoMedioMensal, lessThan(resultMaxSeguro.custoMedioMensal));
      });

      test('deve calcular VPL quando não usar valor nominal', () {
        final paramsVPL = defaultParams.copyWith(
          usarValorNominal: false,
          taxaDesconto: 10.0,
        );
        final result = Calculator.calcularCompra(paramsVPL);
        
        expect(result.detalhes['tipoCalculo'], equals('VPL'));
        // Custo médio com VPL deve ser diferente do nominal
        expect(result.custoMedioMensal, isNot(equals(Calculator.calcularCompra(defaultParams).custoMedioMensal)));
      });
    });

    group('Validação de Cenário Real', () {
      test('deve validar cenário específico do usuário (sem seguro, alíquota 34%)', () {
        // Cenário: R$ 10.000, 3 anos, 3% manutenção, 34.0% IR, 0% seguro
        final result = Calculator.calcularCompra(defaultParams);
        
        // Validações específicas baseadas no cálculo manual
        expect(result.detalhes['valorCompra'], equals(10000.0));
        expect(result.detalhes['seguro'], equals(0.0));
        expect(result.detalhes['seguroTx'], equals(0.0));
        expect(result.detalhes['freteTotal'], equals(240.0));
        expect(result.detalhes['capex'], equals(10240.0)); // Sem seguro
        expect(result.detalhes['manutencaoAnual'], equals(300.0));
        expect(result.detalhes['depreciacaoAnual'], closeTo(3333.33, 0.01));
        expect(result.detalhes['beneficioFiscalAnual'], closeTo(1133.33, 0.01)); // 34%
        
        // Custo total = CAPEX + Manutenção total - Benefício fiscal total
        // Custo total = 10240 + (300 * 3) - (1133.33 * 3) = 10240 + 900 - 3400 = 7740
        // Custo mensal = 7740 / 36 = 215
        expect(result.custoMedioMensal, closeTo(215.00, 1.0)); // Valor real calculado
      });

      test('deve validar cenário com alíquota 25.20% (compatibilidade)', () {
        // Cenário: R$ 10.000, 3 anos, 3% manutenção, 25.20% IR, 0% seguro
        final paramsAntigos = defaultParams.copyWith(aliquotaIR: 25.20);
        final result = Calculator.calcularCompra(paramsAntigos);
        
        // Validações para manter compatibilidade com cálculos anteriores
        expect(result.detalhes['valorCompra'], equals(10000.0));
        expect(result.detalhes['seguro'], equals(0.0));
        expect(result.detalhes['beneficioFiscalAnual'], closeTo(840.00, 0.01)); // 25.20%
        expect(result.custoMedioMensal, closeTo(239.44, 0.01));
      });

      test('deve validar cenário com seguro 1% e alíquota 25.20%', () {
        // Cenário: R$ 10.000, 3 anos, 3% manutenção, 25.20% IR, 1% seguro
        final paramsCompletos = defaultParams.copyWith(aliquotaIR: 25.20, seguroTx: 1.0);
        final result = Calculator.calcularCompra(paramsCompletos);
        
        // Validações para manter compatibilidade com cálculos anteriores
        expect(result.detalhes['valorCompra'], equals(10000.0));
        expect(result.detalhes['seguro'], equals(100.0));
        expect(result.detalhes['seguroTx'], equals(1.0));
        expect(result.detalhes['capex'], equals(10340.0)); // Com seguro 1%
        expect(result.custoMedioMensal, closeTo(242.22, 0.01));
      });
    });
  });
}