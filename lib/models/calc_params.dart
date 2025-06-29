class CalcParams {
  final double valorCompra;
  final double valorLocacao;
  final double taxaDesconto;
  final bool aplicarDesconto;
  final double valorResidual;
  final bool considerarResidual;
  final bool manutencaoInclusa;
  final double manutencaoPct;
  final bool usarValorNominal;
  final int periodoAnos;
  final double aliquotaIR;
  final double taxaDepreciacao;
  final bool considerarBeneficioFiscal;

  const CalcParams({
    this.valorCompra = 50000,
    this.valorLocacao = 1000,
    this.taxaDesconto = 10,
    this.aplicarDesconto = true,
    this.valorResidual = 10,
    this.considerarResidual = false,
    this.manutencaoInclusa = true,
    this.manutencaoPct = 5,
    this.usarValorNominal = true,
    this.periodoAnos = 3,
    this.aliquotaIR = 25.0,
    this.taxaDepreciacao = 20.0,
    this.considerarBeneficioFiscal = true,
  });

  CalcParams copyWith({
    double? valorCompra,
    double? valorLocacao,
    double? taxaDesconto,
    bool? aplicarDesconto,
    double? valorResidual,
    bool? considerarResidual,
    bool? manutencaoInclusa,
    double? manutencaoPct,
    bool? usarValorNominal,
    int? periodoAnos,
    double? aliquotaIR,
    double? taxaDepreciacao,
    bool? considerarBeneficioFiscal,
  }) {
    return CalcParams(
      valorCompra: valorCompra ?? this.valorCompra,
      valorLocacao: valorLocacao ?? this.valorLocacao,
      taxaDesconto: taxaDesconto ?? this.taxaDesconto,
      aplicarDesconto: aplicarDesconto ?? this.aplicarDesconto,
      valorResidual: valorResidual ?? this.valorResidual,
      considerarResidual: considerarResidual ?? this.considerarResidual,
      manutencaoInclusa: manutencaoInclusa ?? this.manutencaoInclusa,
      manutencaoPct: manutencaoPct ?? this.manutencaoPct,
      usarValorNominal: usarValorNominal ?? this.usarValorNominal,
      periodoAnos: periodoAnos ?? this.periodoAnos,
      aliquotaIR: aliquotaIR ?? this.aliquotaIR,
      taxaDepreciacao: taxaDepreciacao ?? this.taxaDepreciacao,
      considerarBeneficioFiscal: considerarBeneficioFiscal ?? this.considerarBeneficioFiscal,
    );
  }

  Map<String, dynamic> toJson() => {
        'valorCompra': valorCompra,
        'valorLocacao': valorLocacao,
        'taxaDesconto': taxaDesconto,
        'aplicarDesconto': aplicarDesconto,
        'valorResidual': valorResidual,
        'considerarResidual': considerarResidual,
        'manutencaoInclusa': manutencaoInclusa,
        'manutencaoPct': manutencaoPct,
        'usarValorNominal': usarValorNominal,
        'periodoAnos': periodoAnos,
        'aliquotaIR': aliquotaIR,
        'taxaDepreciacao': taxaDepreciacao,
        'considerarBeneficioFiscal': considerarBeneficioFiscal,
      };

  factory CalcParams.fromJson(Map<String, dynamic> json) {
    return CalcParams(
      valorCompra: (json['valorCompra'] ?? 50000).toDouble(),
      valorLocacao: (json['valorLocacao'] ?? 1000).toDouble(),
      taxaDesconto: (json['taxaDesconto'] ?? 10).toDouble(),
      aplicarDesconto: json['aplicarDesconto'] ?? true,
      valorResidual: (json['valorResidual'] ?? 10).toDouble(),
      considerarResidual: json['considerarResidual'] ?? false,
      manutencaoInclusa: json['manutencaoInclusa'] ?? true,
      manutencaoPct: (json['manutencaoPct'] ?? 5).toDouble(),
      usarValorNominal: json['usarValorNominal'] ?? true,
      periodoAnos: json['periodoAnos'] ?? 3,
      aliquotaIR: (json['aliquotaIR'] ?? 25.0).toDouble(),
      taxaDepreciacao: (json['taxaDepreciacao'] ?? 20.0).toDouble(),
      considerarBeneficioFiscal: json['considerarBeneficioFiscal'] ?? true,
    );
  }
}