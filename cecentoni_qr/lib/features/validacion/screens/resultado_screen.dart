import 'package:cecentoni_qr/core/constants/app_colors.dart';
import 'package:cecentoni_qr/core/constants/app_routes.dart';
import 'package:cecentoni_qr/core/constants/app_strings.dart';
import 'package:cecentoni_qr/features/auth/providers/auth_provider.dart';
import 'package:cecentoni_qr/features/pedidos/providers/pedidos_provider.dart';
import 'package:cecentoni_qr/features/qr/providers/qr_provider.dart';
import 'package:cecentoni_qr/features/validacion/logic/validacion_logic.dart';
import 'package:cecentoni_qr/models/pedido_model.dart';
import 'package:cecentoni_qr/models/producto_model.dart';
import 'package:cecentoni_qr/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ResultadoScreen extends ConsumerStatefulWidget {
  const ResultadoScreen({super.key});

  @override
  ConsumerState<ResultadoScreen> createState() => _ResultadoScreenState();
}

class _ResultadoScreenState extends ConsumerState<ResultadoScreen> {
  bool _guardado = false;
  bool _guardando = false;
  final _validacionLogic = const ValidacionLogic();

  @override
  void initState() {
    super.initState();
    _guardarVerificacion();
  }

  Future<void> _guardarVerificacion() async {
    if (_guardado) return;
    setState(() => _guardando = true);

    final pedido = ref.read(pedidoSeleccionadoProvider);
    final qrState = ref.read(qrScannerProvider);
    final usuarioAsync = ref.read(currentUserProvider);

    if (pedido == null || qrState.producto == null) {
      setState(() => _guardando = false);
      return;
    }

    final resultado = _validacionLogic.validar(
      pedido: pedido,
      productoEscaneado: qrState.producto!,
    );

    final usuario = usuarioAsync.value;

    final verificacion = _validacionLogic.crearVerificacion(
      empleadoEmail: usuario?.email ?? 'unknown',
      empleadoNombre: usuario?.nombre ?? 'Empleado',
      pedido: pedido,
      productoEscaneado: qrState.producto!,
      resultado: resultado.esValido,
    );

    try {
      await ref.read(firestoreServiceProvider).guardarVerificacion(verificacion);
      if (resultado.esValido) {
        await ref.read(firestoreServiceProvider).actualizarEstatusPedido(
              pedido.id,
              EstatusPedido.verificado,
            );
      }
    } catch (e) {
      debugPrint('Error guardando verificación: $e');
    }

    if (mounted) setState(() => _guardado = true);
    setState(() => _guardando = false);
  }

  @override
  Widget build(BuildContext context) {
    final pedido = ref.watch(pedidoSeleccionadoProvider);
    final qrState = ref.watch(qrScannerProvider);
    final theme = Theme.of(context);

    if (pedido == null || qrState.producto == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resultado')),
        body: const Center(child: Text('Error: datos incompletos')),
      );
    }

    final resultado = _validacionLogic.validar(
      pedido: pedido,
      productoEscaneado: qrState.producto!,
    );

    final esValido = resultado.esValido;
    final color = esValido ? AppColors.success : AppColors.error;
    final bgColor = esValido ? AppColors.successLight : AppColors.errorLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        foregroundColor: color,
        title: const Text('Resultado'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  esValido ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 72,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fade(duration: 300.ms),

              const Gap(24),

              Text(
                esValido
                    ? AppStrings.pisoCorrectoTitulo
                    : AppStrings.pisoIncorrectoTitulo,
                style: theme.textTheme.displayMedium?.copyWith(color: color),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

              const Gap(8),

              Text(
                esValido
                    ? AppStrings.pisoCorrectoDesc
                    : AppStrings.pisoIncorrectoDesc,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),

              const Gap(32),

              _ComparacionCard(
                pedido: pedido,
                productoEscaneado: qrState.producto!,
                diferencias: resultado.diferencias,
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

              if (!esValido && resultado.diferencias.isNotEmpty) ...[
                const Gap(16),
                _DiferenciasCard(diferencias: resultado.diferencias),
              ],

              const Gap(32),

              if (esValido) ...[
                CustomButton(
                  label: 'Confirmar entrega',
                  icon: Icons.check_circle_outline,
                  backgroundColor: AppColors.success,
                  onPressed: _guardando
                      ? null
                      : () {
                          ref.read(pedidoSeleccionadoProvider.notifier).state =
                              null;
                          ref.read(qrScannerProvider.notifier).reiniciar();
                          context.go(AppRoutes.home);
                        },
                  isLoading: _guardando,
                ),
                const Gap(12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('Ver historial'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                  ),
                  onPressed: () => context.go(AppRoutes.historial),
                ),
              ] else ...[
                CustomButton(
                  label: 'Volver a escanear',
                  icon: Icons.qr_code_scanner,
                  backgroundColor: AppColors.error,
                  onPressed: () {
                    ref.read(qrScannerProvider.notifier).reiniciar();
                    context.pop();
                  },
                ),
                const Gap(12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Cambiar pedido'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: () => context.go(AppRoutes.pedidos),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparacionCard extends StatelessWidget {
  final PedidoModel pedido;
  final ProductoModel productoEscaneado;
  final List<String> diferencias;

  const _ComparacionCard({
    required this.pedido,
    required this.productoEscaneado,
    required this.diferencias,
  });

  @override
  Widget build(BuildContext context) {
    final esperado = pedido.productoEsperado;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Esperado',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(width: 1, height: 20, color: AppColors.divider),
                Expanded(
                  child: Text(
                    'Escaneado',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _ComparacionRow(
            label: 'Modelo',
            esperado: esperado.modelo,
            escaneado: productoEscaneado.modelo,
          ),
          _ComparacionRow(
            label: 'Color',
            esperado: esperado.color,
            escaneado: productoEscaneado.color,
          ),
          _ComparacionRow(
            label: 'Medida',
            esperado: esperado.medida,
            escaneado: productoEscaneado.medida,
          ),
          _ComparacionRow(
            label: 'Lote',
            esperado: esperado.lote,
            escaneado: productoEscaneado.lote,
          ),
        ],
      ),
    );
  }
}

class _ComparacionRow extends StatelessWidget {
  final String label;
  final String esperado;
  final String escaneado;

  const _ComparacionRow({
    required this.label,
    required this.esperado,
    required this.escaneado,
  });

  bool get _hayDiferencia =>
      esperado.toLowerCase().trim() != escaneado.toLowerCase().trim();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _hayDiferencia ? AppColors.error : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _hayDiferencia
            ? AppColors.errorLight.withValues(alpha: 0.4)
            : null,
        border: const Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  esperado,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Icon(
                _hayDiferencia ? Icons.close : Icons.check,
                color: color,
                size: 18,
              ),
              Expanded(
                child: Text(
                  escaneado,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiferenciasCard extends StatelessWidget {
  final List<String> diferencias;
  const _DiferenciasCard({required this.diferencias});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIXED: era const Row con Gap(8) no-const adentro → quitamos const
          Row(
            children: const [
              Icon(Icons.warning_amber, color: AppColors.error, size: 18),
              Gap(8),
              Text(
                'Diferencias encontradas:',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Gap(8),
          ...diferencias.map((d) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '• $d',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
