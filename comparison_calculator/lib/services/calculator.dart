import 'dart:math';
import '../models/calc_params.dart';

class Calculator {
  static const int meses = 60;
  static const double frete = 120.0;
  static const double seguroTx = 0.01;
  static const double licencasAno = 600.0;
  static const double adminLocacao = 30.0;

  static double taxaMensal(double taxaAnual) {
    return pow(1 + taxaAnual / 100, 1 / 12).toDouble() - 1;
  }

  static double calcularPV(double valor, double taxaMensal, int periodo) {
    if (taxaMensal == 0) return valor;
    return valor / pow(1 + taxaMensal, periodo).toDouble();
  }

  static CalculationResult calcularCompra(CalcParams params) {
    final capex = params.valorCompra + frete + (params.valorCompra * seguroTx);
    final manutAnual = params.valorCompra * params.manutencaoPct / 100;
    final garantiaExtra = params.valorCompra * 0.03;
    
    final fluxos = <double>[-capex];
    
    for (int m = 1; m <= meses; m++) {
      double fluxoMensal = -(manutAnual / 12 + licencasAno / 12);
      
      if (m == meses && params.considerarResidual) {
        fluxoMensal += params.valorCompra * params.valorResidual / 100;
      }
      
      fluxos.add(fluxoMensal);
    }
    
    final taxa = params.aplicarDesconto ? taxaMensal(params.taxaDesconto) : 0.0;
    double soma = 0;
    
    for (int i = 0; i < fluxos.length; i++) {
      if (params.aplicarDesconto) {
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
        'capex': capex,
        'manutencaoAnual': manutAnual,
        'garantiaExtra': garantiaExtra,
      },
    );
  }

  static CalculationResult calcularLocacao(CalcParams params) {
    final opexMensal = params.valorLocacao;
    final manutAnual = params.valorCompra * params.manutencaoPct / 100;
    
    final fluxos = <double>[
      -(frete + params.valorLocacao * seguroTx + adminLocacao),
    ];
    
    for (int m = 1; m <= meses; m++) {
      double fluxoMensal = -(opexMensal + licencasAno / 12);
      
      if (!params.manutencaoInclusa) {
        fluxoMensal -= manutAnual / 12;
      }
      
      fluxos.add(fluxoMensal);
    }
    
    fluxos.add(-(frete + params.valorLocacao * seguroTx));
    
    final taxa = params.aplicarDesconto ? taxaMensal(params.taxaDesconto) : 0.0;
    double soma = 0;
    
    for (int i = 0; i < fluxos.length; i++) {
      if (params.aplicarDesconto) {
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
        'manutencaoInclusa': params.manutencaoInclusa,
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