import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

enum Scenario {
  compra,
  locacao,
}

class CostInputCard extends StatefulWidget {
  final Scenario scenario;
  final double value;
  final double custoMedio;
  final bool isBetterOption;
  final ValueChanged<double> onChanged;

  const CostInputCard({
    super.key,
    required this.scenario,
    required this.value,
    required this.custoMedio,
    required this.isBetterOption,
    required this.onChanged,
  });

  @override
  State<CostInputCard> createState() => _CostInputCardState();
}

class _CostInputCardState extends State<CostInputCard> {
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
  void didUpdateWidget(CostInputCard oldWidget) {
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
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 800;

    final cardContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isBetterOption)
            Align(
              alignment: Alignment.topRight,
              child: Chip(
                label: const Text('Melhor opção'),
                backgroundColor: colorScheme.tertiaryContainer,
                labelStyle: TextStyle(color: colorScheme.onTertiaryContainer),
              ),
            ),
          Text(
            widget.scenario == Scenario.compra ? 'COMPRA' : 'LOCAÇÃO',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 48),
          _buildInputField(context),
          const Spacer(),
          _buildCustoMedio(context),
        ],
      ),
    );

    if (isWide) {
      return Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(width: 4, color: colorScheme.primary)),
        ),
        child: cardContent,
      );
    } else {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: cardContent,
      );
    }
  }

  Widget _buildInputField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onFieldSubmitted: (text) {
        final doubleValue = double.tryParse(text) ?? 0.0;
        widget.onChanged(doubleValue);
      },
    );
  }

  Widget _buildCustoMedio(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormatter =
        NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custo médio mensal',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Text(
          currencyFormatter.format(widget.custoMedio),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
