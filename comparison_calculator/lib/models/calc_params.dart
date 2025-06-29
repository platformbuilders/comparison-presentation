class CalcParams {
  final double valorCompra;
  final double valorLocacao;
  final double taxaDesconto;
  final bool aplicarDesconto;
  final double valorResidual;
  final bool considerarResidual;
  final bool manutencaoInclusa;
  final double manutencaoPct;

  const CalcParams({
    this.valorCompra = 50000,
    this.valorLocacao = 1000,
    this.taxaDesconto = 10,
    this.aplicarDesconto = true,
    this.valorResidual = 10,
    this.considerarResidual = false,
    this.manutencaoInclusa = true,
    this.manutencaoPct = 5,
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
    );
  }
}