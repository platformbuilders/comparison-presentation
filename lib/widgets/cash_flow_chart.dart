import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class CashFlowChart extends StatelessWidget {
  final List<double> fluxosCompra;
  final List<double> fluxosLocacao;
  final int periodoAnos;
  final bool isCompra;

  const CashFlowChart({
    super.key,
    required this.fluxosCompra,
    required this.fluxosLocacao,
    required this.periodoAnos,
    required this.isCompra,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);
    final fluxos = isCompra ? fluxosCompra : fluxosLocacao;
    
    // Validações mais robustas
    if (fluxos.isEmpty || fluxos.every((f) => f == 0)) {
      return const SizedBox.shrink();
    }
    
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Container(
      margin: EdgeInsets.only(top: isDesktop ? 16 : 8),
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Impacto no Fluxo de Caixa',
            style: TextStyle(
              color: AppColors.white,
              fontSize: isDesktop ? 14 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isDesktop ? 12 : 8),
          _buildFluxoMensal(numberFormat, fluxos, isDesktop),
          SizedBox(height: isDesktop ? 8 : 4),
          _buildFluxoAnual(numberFormat, fluxos, isDesktop),
          SizedBox(height: isDesktop ? 8 : 4),
          _buildFluxoTotal(numberFormat, fluxos, isDesktop),
        ],
      ),
    );
  }

  Widget _buildFluxoMensal(NumberFormat format, List<double> fluxos, bool isDesktop) {
    if (fluxos.length <= 1) return const SizedBox.shrink();
    
    try {
      // Pegar fluxo médio mensal (excluindo o investimento inicial)
      final fluxosMensais = fluxos.skip(isCompra ? 1 : 0).toList();
      if (fluxosMensais.isEmpty) return const SizedBox.shrink();
      
      final fluxoMedio = fluxosMensais.reduce((a, b) => a + b) / fluxosMensais.length;

      return _buildFluxoItem(
        'Impacto Mensal:',
        format.format(fluxoMedio),
        fluxoMedio >= 0 ? Colors.green : Colors.red,
        isDesktop,
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildFluxoAnual(NumberFormat format, List<double> fluxos, bool isDesktop) {
    if (fluxos.length <= 1) return const SizedBox.shrink();
    
    try {
      final fluxosMensais = fluxos.skip(isCompra ? 1 : 0).toList();
      if (fluxosMensais.isEmpty) return const SizedBox.shrink();
      
      final fluxoAnual = (fluxosMensais.reduce((a, b) => a + b) / fluxosMensais.length) * 12;

      return _buildFluxoItem(
        'Impacto Anual:',
        format.format(fluxoAnual),
        fluxoAnual >= 0 ? Colors.green : Colors.red,
        isDesktop,
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildFluxoTotal(NumberFormat format, List<double> fluxos, bool isDesktop) {
    try {
      if (fluxos.isEmpty) return const SizedBox.shrink();
      
      final fluxoTotal = fluxos.reduce((a, b) => a + b);

      return _buildFluxoItem(
        'Impacto Total:',
        format.format(fluxoTotal),
        fluxoTotal >= 0 ? Colors.green : Colors.red,
        isDesktop,
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildFluxoItem(String label, String valor, Color cor, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.7),
              fontSize: isDesktop ? 12 : 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: Text(
            valor,
            style: TextStyle(
              color: cor,
              fontSize: isDesktop ? 12 : 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}