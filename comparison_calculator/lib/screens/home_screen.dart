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
      body: StreamBuilder<CalcParams?>(
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
          final compraMelhor = compraResult.custoMedioMensal < locacaoResult.custoMedioMensal;

          if (isDesktop) {
            return Row(
              children: [
                Expanded(
                  child: CostSide(
                    isCompra: true,
                    value: params.valorCompra,
                    custoMedio: compraResult.custoMedioMensal,
                    isBetterOption: compraMelhor,
                    onChanged: (newValue) {
                      final equivalente = Calculator.calcularEquivalente(
                        valorBase: newValue,
                        params: params.copyWith(valorCompra: newValue),
                        isCompra: false,
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
                    isBetterOption: !compraMelhor,
                    onChanged: (newValue) {
                      final equivalente = Calculator.calcularEquivalente(
                        valorBase: newValue,
                        params: params.copyWith(valorLocacao: newValue),
                        isCompra: true,
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
                      isBetterOption: compraMelhor,
                      onChanged: (newValue) {
                        final equivalente = Calculator.calcularEquivalente(
                          valorBase: newValue,
                          params: params.copyWith(valorCompra: newValue),
                          isCompra: false,
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
                      isBetterOption: !compraMelhor,
                      onChanged: (newValue) {
                        final equivalente = Calculator.calcularEquivalente(
                          valorBase: newValue,
                          params: params.copyWith(valorLocacao: newValue),
                          isCompra: true,
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
    );
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.blackSide,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Configurações',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Em desenvolvimento...',
                style: TextStyle(
                  color: AppColors.greyText,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Fechar',
                  style: TextStyle(color: AppColors.blueSide),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}