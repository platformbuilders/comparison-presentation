import 'package:flutter/material.dart';
import '../core/data_repository.dart';
import '../models/calc_params.dart';
import '../services/calculator.dart';
import '../widgets/cost_side.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = RepositoryProvider.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: AppColors.blackSide,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Calculadora Compra × Locação',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.white),
            onPressed: () {
              _showSettingsModal(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<CalcParams?>(
        initialData: repository.calcParams.currentValue,
        stream: repository.calcParams.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.white,
              ),
            );
          }

          final params = snapshot.data!;
          final compraResult = Calculator.calcularCompra(params);
          final locacaoResult = Calculator.calcularLocacao(params);

          if (isDesktop) {
            return Row(
              children: [
                Expanded(
                  child: CostSide(
                    isCompra: true,
                    value: params.valorCompra,
                    custoMedio: compraResult.custoMedioMensal,
                    detalhes: compraResult.detalhes,
                    periodoAnos: params.periodoAnos,
                    onSettingsPressed: () => _showSettingsModal(context),
                    onChanged: (newValue) {
                      final equivalente = Calculator.calcularEquivalente(
                        valorBase: newValue,
                        params: params.copyWith(valorCompra: newValue),
                        isCompra: true,
                      );
                      repository.calcParams.update({
                        'valorCompra': newValue,
                        'valorLocacao': equivalente,
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CostSide(
                    isCompra: false,
                    value: params.valorLocacao,
                    custoMedio: locacaoResult.custoMedioMensal,
                    detalhes: locacaoResult.detalhes,
                    periodoAnos: params.periodoAnos,
                    onSettingsPressed: () => _showSettingsModal(context),
                    onChanged: (newValue) {
                      final equivalente = Calculator.calcularEquivalente(
                        valorBase: newValue,
                        params: params.copyWith(valorLocacao: newValue),
                        isCompra: false,
                      );
                      repository.calcParams.update({
                        'valorCompra': equivalente,
                        'valorLocacao': newValue,
                      });
                    },
                  ),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: CostSide(
                      isCompra: true,
                      value: params.valorCompra,
                      custoMedio: compraResult.custoMedioMensal,
                      detalhes: compraResult.detalhes,
                      periodoAnos: params.periodoAnos,
                      onSettingsPressed: () => _showSettingsModal(context),
                      onChanged: (newValue) {
                        final equivalente = Calculator.calcularEquivalente(
                          valorBase: newValue,
                          params: params.copyWith(valorCompra: newValue),
                          isCompra: true,
                        );
                        repository.calcParams.update({
                          'valorCompra': newValue,
                          'valorLocacao': equivalente,
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: CostSide(
                      isCompra: false,
                      value: params.valorLocacao,
                      custoMedio: locacaoResult.custoMedioMensal,
                      detalhes: locacaoResult.detalhes,
                      periodoAnos: params.periodoAnos,
                      onSettingsPressed: () => _showSettingsModal(context),
                      onChanged: (newValue) {
                        final equivalente = Calculator.calcularEquivalente(
                          valorBase: newValue,
                          params: params.copyWith(valorLocacao: newValue),
                          isCompra: false,
                        );
                        repository.calcParams.update({
                          'valorCompra': equivalente,
                          'valorLocacao': newValue,
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
            ),
          ),
        ],
      ),
    );
  }


  void _showSettingsModal(BuildContext context) {
    final repository = RepositoryProvider.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.blackSide,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final currentParams = repository.calcParams.currentValue ?? const CalcParams();
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Configurações',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                  _buildSettingItem(
                    'Tipo de Cálculo',
                    'Escolha entre valor nominal ou VPL (Valor Presente Líquido)',
                    Switch(
                      value: currentParams.usarValorNominal,
                      onChanged: (value) {
                        repository.calcParams.update({'usarValorNominal': value});
                        setState(() {});
                      },
                      activeColor: AppColors.blueSide,
                    ),
                    currentParams.usarValorNominal ? 'Nominal' : 'VPL (10% a.a.)',
                  ),
                  const SizedBox(height: 24),
                  _buildSettingItem(
                    'Benefícios Fiscais',
                    'Considerar economia de IR/CSLL nos cálculos',
                    Switch(
                      value: currentParams.considerarBeneficioFiscal,
                      onChanged: (value) {
                        repository.calcParams.update({'considerarBeneficioFiscal': value});
                        setState(() {});
                      },
                      activeColor: AppColors.blueSide,
                    ),
                    currentParams.considerarBeneficioFiscal ? 'Ativado' : 'Desativado',
                  ),
                  const SizedBox(height: 24),
                  _buildNumericSetting(
                    'Alíquota IR/CSLL (%)',
                    'Taxa de imposto sobre lucro (IR + CSLL)',
                    currentParams.aliquotaIR,
                    (value) {
                      repository.calcParams.update({'aliquotaIR': value});
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildNumericSetting(
                    'Taxa Depreciação (%)',
                    'Percentual de depreciação anual do equipamento',
                    currentParams.taxaDepreciacao,
                    (value) {
                      repository.calcParams.update({'taxaDepreciacao': value});
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildNumericSetting(
                    'Manutenção Anual (%)',
                    'Percentual anual do valor do equipamento gasto com manutenção',
                    currentParams.manutencaoPct,
                    (value) {
                      repository.calcParams.update({'manutencaoPct': value});
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildNumericSetting(
                    'Taxa de Seguro (%)',
                    'Percentual do valor do equipamento para seguro',
                    currentParams.seguroTx,
                    (value) {
                      repository.calcParams.update({'seguroTx': value});
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildNumericSetting(
                    'Período (anos)',
                    'Período de análise para comparação entre compra e locação',
                    currentParams.periodoAnos.toDouble(),
                    (value) {
                      final newPeriodo = value.toInt();
                      final equivalente = Calculator.calcularEquivalente(
                        valorBase: currentParams.valorCompra,
                        params: currentParams.copyWith(periodoAnos: newPeriodo),
                        isCompra: true,
                      );
                      
                      repository.calcParams.update({
                        'periodoAnos': newPeriodo,
                        'valorLocacao': equivalente,
                      });
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueSide,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Fechar',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingItem(String title, String description, Widget control, String currentValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            control,
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Atual: $currentValue',
          style: TextStyle(
            color: AppColors.blueSide,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNumericSetting(String title, String description, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: title.contains('Alíquota') ? 0 : (title.contains('Manutenção') ? 0 : (title.contains('Seguro') ? 0 : (title.contains('Período') ? 1 : 1))),
                max: title.contains('Alíquota') ? 50 : (title.contains('Manutenção') ? 20 : (title.contains('Seguro') ? 10 : (title.contains('Período') ? 5 : 50))),
                divisions: title.contains('Alíquota') ? 500 : (title.contains('Manutenção') ? 200 : (title.contains('Seguro') ? 100 : (title.contains('Período') ? 4 : 490))),
                onChanged: onChanged,
                activeColor: AppColors.blueSide,
                inactiveColor: AppColors.blueSide.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: title.contains('Período') ? 80 : 60,
              child: Text(
                title.contains('Período') ? '${value.toInt()} ${value.toInt() == 1 ? 'ano' : 'anos'}' : '${value.toStringAsFixed(2)}%',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ],
    );
  }
}