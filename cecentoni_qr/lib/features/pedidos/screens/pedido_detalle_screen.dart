import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/pedidos_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../widgets/custom_button.dart';

class PedidoDetalleScreen extends ConsumerWidget {
  final String pedidoId;
  const PedidoDetalleScreen({super.key, required this.pedidoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedido = ref.watch(pedidoSeleccionadoProvider);
    final theme = Theme.of(context);

    if (pedido == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: Text('Pedido no encontrado')),
      );
    }

    final producto = pedido.productoEsperado;

    return Scaffold(
      appBar: AppBar(title: Text('Pedido #${pedido.numeroPedido}')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoSection(
                icon: Icons.person,
                title: 'Cliente',
                children: [
                  _InfoRow(label: 'Nombre', value: pedido.cliente),
                  if (pedido.fechaEntrega != null)
                    _InfoRow(
                      label: 'Fecha de entrega',
                      value: DateFormatter.toMedium(pedido.fechaEntrega!),
                    ),
                ],
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

              const Gap(16),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.inventory_2,
                            color: AppColors.primary, size: 20),
                        const Gap(8),
                        Text(
                          AppStrings.productoEsperado,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _InfoRow(label: AppStrings.modelo, value: producto.modelo),
                    _InfoRow(label: AppStrings.color, value: producto.color),
                    _InfoRow(label: AppStrings.medida, value: producto.medida),
                    _InfoRow(
                        label: AppStrings.lote,
                        value: producto.lote,
                        isHighlighted: true),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              const Gap(32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warning),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        'Escanea el código QR del piso a entregar para verificar que coincida con este pedido.',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const Gap(24),

              CustomButton(
                label: AppStrings.escanearQR,
                icon: Icons.qr_code_scanner,
                onPressed: () => context.push(AppRoutes.qrScanner),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const Gap(8),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight:
                      isHighlighted ? FontWeight.w800 : FontWeight.w600,
                  color:
                      isHighlighted ? AppColors.primary : AppColors.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}
