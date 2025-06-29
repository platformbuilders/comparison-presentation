import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class CostSide extends StatelessWidget {
  final bool isCompra;
  final double value;
  final double custoMedio;
  final Function(double) onChanged;
  final bool isBetterOption;

  const CostSide({
    super.key,
    required this.isCompra,
    required this.value,
    required this.custoMedio,
    required this.onChanged,
    required this.isBetterOption,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Container(
      color: isCompra ? AppColors.blueSide : AppColors.blackSide,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 48.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCompra ? 'COMPRA' : 'LOCAÇÃO',
              style: TextStyle(
                color: AppColors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            _buildMainValue(numberFormat),
            const SizedBox(height: 24),
            _buildInput(context),
            const SizedBox(height: 48),
            _buildCustoMedio(numberFormat),
            if (isBetterOption) ...[
              const SizedBox(height: 16),
              _buildBetterIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainValue(NumberFormat format) {
    return Text(
      format.format(value),
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 42,
        fontWeight: FontWeight.bold,
        height: 1,
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: TextFormField(
        initialValue: value.toStringAsFixed(2),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: isCompra ? 'Valor de Compra' : 'Valor Mensal',
          labelStyle: TextStyle(
            color: AppColors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        onChanged: (text) {
          final newValue = double.tryParse(text) ?? 0;
          if (newValue > 0) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Widget _buildCustoMedio(NumberFormat format) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custo médio mensal',
          style: TextStyle(
            color: AppColors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          format.format(custoMedio),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBetterIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.greenIndicator.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.greenIndicator.withOpacity(0.5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.greenIndicator,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            'Melhor opção',
            style: TextStyle(
              color: AppColors.greenIndicator,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}