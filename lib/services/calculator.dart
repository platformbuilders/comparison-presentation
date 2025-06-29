import 'dart:math';
import '../models/calc_params.dart';

class Calculator {
  static const double frete = 120.0;
  static const double adminLocacao = 30.0;

  static double taxaMensal(double taxaAnual) {
    return pow(1 + taxaAnual / 100, 1 / 12).toDouble() - 1;
  }

  static double calcularPV(double valor, double taxaMensal, int periodo) {
    if (taxaMensal == 0) return valor;
    return valor / pow(1 + taxaMensal, periodo).toDouble();
  }

  static CalculationResult calcularCompra(CalcParams params) {
    final meses = params.periodoAnos * 12;
    final seguro = params.valorCompra * params.seguroTx / 100;
    final capex = params.valorCompra + frete + frete + seguro;
    final manutAnual = params.valorCompra * params.manutencaoPct / 100;
    final garantiaExtra = params.valorCompra * 0.03;
    
    // Cálculo do benefício fiscal da depreciação
    // Depreciação anual baseada no período real (valor / período em anos)
    final depreciacaoAnual = params.valorCompra / params.periodoAnos;
    final beneficioFiscalAnual = params.considerarBeneficioFiscal 
        ? depreciacaoAnual * params.aliquotaIR / 100 
        : 0.0;
    final beneficioFiscalMensal = beneficioFiscalAnual / 12;
    
    final fluxos = <double>[-capex];
    
    for (int m = 1; m <= meses; m++) {
      double fluxoMensal = -(manutAnual / 12);
      
      // Adicionar benefício fiscal da depreciação
      if (params.considerarBeneficioFiscal) {
        fluxoMensal += beneficioFiscalMensal;
      }
      
      if (m == meses && params.considerarResidual) {
        fluxoMensal += params.valorCompra * params.valorResidual / 100;
      }
      
      fluxos.add(fluxoMensal);
    }
    
    final aplicarDesconto = !params.usarValorNominal;
    final taxa = aplicarDesconto ? taxaMensal(params.taxaDesconto) : 0.0;
    double soma = 0;
    
    for (int i = 0; i < fluxos.length; i++) {
      if (aplicarDesconto) {
        soma += calcularPV(fluxos[i], taxa, i);
      } else {
        soma += fluxos[i];
      }
    }
    
    final custoMedio = -soma / meses;
    
    return CalculationResult(
      custoMedioMensal: custoMedio,
      fluxos: fluxos,
      detalhes: {
        'valorCompra': params.valorCompra,
        'seguro': seguro,
        'seguroTx': params.seguroTx,
        'capex': capex,
        'freteTotal': frete * 2,
        'manutencaoAnual': manutAnual,
        'manutencaoPct': params.manutencaoPct,
        'garantiaExtra': garantiaExtra,
        'depreciacaoAnual': depreciacaoAnual,
        'beneficioFiscalAnual': beneficioFiscalAnual,
        'beneficioFiscalMensal': beneficioFiscalMensal,
        'custoLiquido': custoMedio,
        'periodo': '${params.periodoAnos} anos',
        'tipoCalculo': params.usarValorNominal ? 'Nominal' : 'VPL',
        'aliquotaIR': params.aliquotaIR,
        'fluxos': fluxos,
      },
    );
  }

  static CalculationResult calcularLocacao(CalcParams params) {
    final meses = params.periodoAnos * 12;
    final opexMensal = params.valorLocacao;
    final manutAnual = params.valorCompra * params.manutencaoPct / 100;
    
    // Cálculo do benefício fiscal da locação
    final beneficioFiscalMensal = params.considerarBeneficioFiscal 
        ? opexMensal * params.aliquotaIR / 100 
        : 0.0;
    final beneficioFiscalAnual = beneficioFiscalMensal * 12;
    
    final fluxos = <double>[];
    
    for (int m = 1; m <= meses; m++) {
      double fluxoMensal = -opexMensal;
      
      if (!params.manutencaoInclusa) {
        fluxoMensal -= manutAnual / 12;
      }
      
      // Adicionar benefício fiscal da locação
      if (params.considerarBeneficioFiscal) {
        fluxoMensal += beneficioFiscalMensal;
      }
      
      fluxos.add(fluxoMensal);
    }
    
    final aplicarDesconto = !params.usarValorNominal;
    final taxa = aplicarDesconto ? taxaMensal(params.taxaDesconto) : 0.0;
    double soma = 0;
    
    for (int i = 0; i < fluxos.length; i++) {
      if (aplicarDesconto) {
        soma += calcularPV(fluxos[i], taxa, i);
      } else {
        soma += fluxos[i];
      }
    }
    
    final custoMedio = -soma / meses;
    
    return CalculationResult(
      custoMedioMensal: custoMedio,
      fluxos: fluxos,
      detalhes: {
        'opexMensal': opexMensal,
        'freteTotal': 0.0,
        'manutencaoInclusa': params.manutencaoInclusa,
        'manutencaoPct': params.manutencaoPct,
        'beneficioFiscalMensal': beneficioFiscalMensal,
        'beneficioFiscalAnual': beneficioFiscalAnual,
        'custoLiquido': custoMedio,
        'periodo': '${params.periodoAnos} anos',
        'tipoCalculo': params.usarValorNominal ? 'Nominal' : 'VPL',
        'aliquotaIR': params.aliquotaIR,
        'fluxos': fluxos,
      },
    );
  }

  static double calcularEquivalente({
    required double valorBase,
    required CalcParams params,
    required bool isCompra,
  }) {
    final targetCost = isCompra
        ? calcularCompra(params).custoMedioMensal
        : calcularLocacao(params).custoMedioMensal;
    
    double min = 1;
    double max = 1000000;
    double mid = 0;
    
    for (int i = 0; i < 50; i++) {
      mid = (min + max) / 2;
      
      final testParams = isCompra
          ? params.copyWith(valorLocacao: mid)
          : params.copyWith(valorCompra: mid);
      
      final result = isCompra
          ? calcularLocacao(testParams)
          : calcularCompra(testParams);
      
      if ((result.custoMedioMensal - targetCost).abs() < 0.01) {
        return mid;
      }
      
      if (result.custoMedioMensal < targetCost) {
        min = mid;
      } else {
        max = mid;
      }
    }
    
    return mid;
  }
}

class CalculationResult {
  final double custoMedioMensal;
  final List<double> fluxos;
  final Map<String, dynamic> detalhes;

  const CalculationResult({
    required this.custoMedioMensal,
    required this.fluxos,
    required this.detalhes,
  });
}