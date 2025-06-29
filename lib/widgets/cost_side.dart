import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import 'cash_flow_chart.dart';

class CostSide extends StatefulWidget {
  final bool isCompra;
  final double value;
  final double custoMedio;
  final Function(double) onChanged;
  final Map<String, dynamic> detalhes;
  final int periodoAnos;
  final VoidCallback? onSettingsPressed;

  const CostSide({
    super.key,
    required this.isCompra,
    required this.value,
    required this.custoMedio,
    required this.onChanged,
    required this.detalhes,
    required this.periodoAnos,
    this.onSettingsPressed,
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
        child: isDesktop 
          ? _buildContent(numberFormat, false)
          : SingleChildScrollView(
              child: _buildContent(numberFormat, true)
            ),
      ),
    );
  }

  Widget _buildContent(NumberFormat numberFormat, bool isMobile) {
    final fluxos = widget.detalhes['fluxos'] as List<double>?;
    final hasValidFluxos = fluxos != null && fluxos.isNotEmpty;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        SizedBox(height: isMobile ? 16 : 24),
        _buildMainValue(numberFormat),
        SizedBox(height: isMobile ? 12 : 16),
        _buildInput(context),
        SizedBox(height: isMobile ? 20 : 32),
        _buildCustoMedio(numberFormat),
        SizedBox(height: isMobile ? 12 : 16),
        Flexible(
          child: _buildDetalhes(numberFormat),
        ),
        if (hasValidFluxos) ...[
          SizedBox(height: isMobile ? 8 : 12),
          CashFlowChart(
            fluxosCompra: widget.isCompra ? fluxos : [],
            fluxosLocacao: !widget.isCompra ? fluxos : [],
            periodoAnos: widget.periodoAnos,
            isCompra: widget.isCompra,
          ),
        ],
        if (isMobile) const SizedBox(height: 16), // Espaço extra no final para mobile
      ],
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
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        format.format(widget.value),
        style: TextStyle(
          color: AppColors.white,
          fontSize: isDesktop ? 42 : 32,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
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
    final custoTotal = widget.custoMedio * widget.periodoAnos * 12;
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Custo médio mensal',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.7),
                  fontSize: isDesktop ? 12 : 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isDesktop ? 8 : 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  format.format(widget.custoMedio),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: isDesktop ? 16 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Custo total (',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: isDesktop ? 12 : 11,
                      ),
                    ),
                    WidgetSpan(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: widget.onSettingsPressed,
                          child: Text(
                            '${widget.periodoAnos} ${widget.periodoAnos == 1 ? 'ano' : 'anos'}',
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.7),
                              fontSize: isDesktop ? 12 : 11,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextSpan(
                      text: ')',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: isDesktop ? 12 : 11,
                      ),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isDesktop ? 8 : 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  format.format(custoTotal),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
        _buildComposicaoCusto(format),
        const SizedBox(height: 12),
        _buildBeneficiosFiscais(format),
      ],
    );
  }

  Widget _buildComposicaoCusto(NumberFormat format) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Composição do Custo',
          style: TextStyle(
            color: AppColors.white.withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        if (widget.isCompra) ...[
          _buildDetalheItem('Valor do equipamento', format.format(widget.detalhes['valorCompra'] ?? 0)),
          if ((widget.detalhes['seguro'] ?? 0.0) > 0) 
            _buildDetalheItem('Seguro (${(widget.detalhes['seguroTx'] ?? 0).toStringAsFixed(1)}%)', format.format(widget.detalhes['seguro'] ?? 0)),
          _buildDetalheItem('Frete (envio + retorno)', format.format(widget.detalhes['freteTotal'] ?? 0)),
          _buildDetalheItem('Manutenção anual (${(widget.detalhes['manutencaoPct'] ?? 0).toStringAsFixed(1)}%)', format.format(widget.detalhes['manutencaoAnual'] ?? 0)),
        ] else ...[
          _buildDetalheItem('Valor mensal', format.format(widget.detalhes['opexMensal'] ?? 0)),
          _buildDetalheItem('Manutenção inclusa', widget.detalhes['manutencaoInclusa'] == true ? 'Sim' : 'Não'),
        ],
      ],
    );
  }

  Widget _buildBeneficiosFiscais(NumberFormat format) {
    final beneficioAnual = widget.detalhes['beneficioFiscalAnual'] ?? 0.0;
    final beneficioMensal = widget.detalhes['beneficioFiscalMensal'] ?? 0.0;
    final aliquotaNum = widget.detalhes['aliquotaIR'] ?? 25.0;
    final aliquota = '${aliquotaNum.toStringAsFixed(2)}%';
    
    if (beneficioAnual == 0.0) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benefícios Fiscais',
          style: TextStyle(
            color: Colors.green.withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        _buildDetalheItem('Alíquota IR/CSLL (${aliquota})', '', Colors.green),
        if (widget.isCompra)
          _buildDetalheItem('Economia depreciação/ano', format.format(beneficioAnual), Colors.green)
        else
          _buildDetalheItem('Economia dedução/mês', format.format(beneficioMensal), Colors.green),
        _buildDetalheItem('Custo líquido/mês', format.format(widget.detalhes['custoLiquido'] ?? 0), Colors.green),
      ],
    );
  }

  Widget _buildDetalheItem(String label, String value, [Color? cor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.6),
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                color: cor ?? AppColors.white.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

}