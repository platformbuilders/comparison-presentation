import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class CostSide extends StatefulWidget {
  final bool isCompra;
  final double value;
  final double custoMedio;
  final Function(double) onChanged;
  final Map<String, dynamic> detalhes;

  const CostSide({
    super.key,
    required this.isCompra,
    required this.value,
    required this.custoMedio,
    required this.onChanged,
    required this.detalhes,
  });

  @override
  State<CostSide> createState() => _CostSideState();
}

class _CostSideState extends State<CostSide> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateText(widget.value);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(CostSide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
      _updateText(widget.value);
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _controller.text = widget.value.toInt().toString();
    } else {
      final value = double.tryParse(_controller.text) ?? 0.0;
      widget.onChanged(value);
      _updateText(value);
    }
  }

  void _updateText(double value) {
    final currencyFormatter =
        NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 0);
    _controller.text = currencyFormatter.format(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Container(
      color: widget.isCompra ? AppColors.blueSide : AppColors.blackSide,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 48.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildMainValue(numberFormat),
            const SizedBox(height: 24),
            _buildInput(context),
            const SizedBox(height: 48),
            _buildCustoMedio(numberFormat),
            const SizedBox(height: 24),
            _buildDetalhes(numberFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      widget.isCompra ? 'COMPRA' : 'LOCAÇÃO',
      style: TextStyle(
        color: AppColors.white.withOpacity(0.7),
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMainValue(NumberFormat format) {
    return Text(
      format.format(widget.value),
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
        controller: _controller,
        focusNode: _focusNode,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: widget.isCompra ? 'Valor de Compra' : 'Valor Mensal',
          labelStyle: TextStyle(
            color: AppColors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onFieldSubmitted: (text) {
          final newValue = double.tryParse(text) ?? 0;
          if (newValue > 0) {
            widget.onChanged(newValue);
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
          format.format(widget.custoMedio),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetalhes(NumberFormat format) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalhes do cálculo',
          style: TextStyle(
            color: AppColors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.isCompra) ...[
          _buildDetalheItem('CAPEX inicial', format.format(widget.detalhes['capex'] ?? 0)),
          _buildDetalheItem('Frete envio', format.format(widget.detalhes['freteEnvio'] ?? 0)),
          _buildDetalheItem('Manutenção anual', format.format(widget.detalhes['manutencaoAnual'] ?? 0)),
          _buildDetalheItem('Período', '60 meses'),
          _buildDetalheItem('Tipo de cálculo', widget.detalhes['tipoCalculo'] ?? 'Nominal'),
        ] else ...[
          _buildDetalheItem('Valor mensal', format.format(widget.detalhes['opexMensal'] ?? 0)),
          _buildDetalheItem('Frete envio', format.format(widget.detalhes['freteEnvio'] ?? 0)),
          _buildDetalheItem('Frete retorno', format.format(widget.detalhes['freteRetorno'] ?? 0)),
          _buildDetalheItem('Manutenção inclusa', widget.detalhes['manutencaoInclusa'] == true ? 'Sim' : 'Não'),
          _buildDetalheItem('Período', '60 meses'),
          _buildDetalheItem('Tipo de cálculo', widget.detalhes['tipoCalculo'] ?? 'Nominal'),
        ],
      ],
    );
  }

  Widget _buildDetalheItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

}