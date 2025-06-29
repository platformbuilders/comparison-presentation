import 'package:flutter/material.dart';
import 'models/calc_params.dart';
import 'services/calculator.dart';
import 'widgets/cost_side.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const ComparisonCalculatorDemo());
}

class ComparisonCalculatorDemo extends StatefulWidget {
  const ComparisonCalculatorDemo({super.key});

  @override
  State<ComparisonCalculatorDemo> createState() => _ComparisonCalculatorDemoState();
}

class _ComparisonCalculatorDemoState extends State<ComparisonCalculatorDemo> {
  CalcParams params = const CalcParams();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Compra × Locação',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.blueSide,
        scaffoldBackgroundColor: AppColors.blackSide,
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: AppColors.blackSide,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Calculadora Compra × Locação (Demo)',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: AppColors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;
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
                      onChanged: (newValue) {
                        setState(() {
                          final equivalente = Calculator.calcularEquivalente(
                            valorBase: newValue,
                            params: params.copyWith(valorCompra: newValue),
                            isCompra: false,
                          );
                          params = params.copyWith(
                            valorCompra: newValue,
                            valorLocacao: equivalente,
                          );
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
                      onChanged: (newValue) {
                        setState(() {
                          final equivalente = Calculator.calcularEquivalente(
                            valorBase: newValue,
                            params: params.copyWith(valorLocacao: newValue),
                            isCompra: false,
                          );
                          params = params.copyWith(
                            valorCompra: equivalente,
                            valorLocacao: newValue,
                          );
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
                        onChanged: (newValue) {
                          setState(() {
                            final equivalente = Calculator.calcularEquivalente(
                              valorBase: newValue,
                              params: params.copyWith(valorCompra: newValue),
                              isCompra: false,
                            );
                            params = params.copyWith(
                              valorCompra: newValue,
                              valorLocacao: equivalente,
                            );
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
                        onChanged: (newValue) {
                          setState(() {
                            final equivalente = Calculator.calcularEquivalente(
                              valorBase: newValue,
                              params: params.copyWith(valorLocacao: newValue),
                              isCompra: false,
                            );
                            params = params.copyWith(
                              valorCompra: equivalente,
                              valorLocacao: newValue,
                            );
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
    );
  }
}