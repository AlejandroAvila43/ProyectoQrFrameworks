import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../models/pedido_model.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';

class PedidoCard extends StatelessWidget {
  final PedidoModel pedido;
  final VoidCallback onTap;

  const PedidoCard({
    super.key,
    required this.pedido,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pedido #${pedido.numeroPedido}',
                          style: theme.textTheme.titleLarge,
                        ),
                        _EstatusChip(estatus: pedido.estatus),
                      ],
                    ),
                    const Gap(4),
                    Text(pedido.cliente, style: theme.textTheme.bodyMedium),
                    const Gap(4),
                    Text(
                      pedido.productoEsperado.modelo,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (pedido.fechaEntrega != null) ...[
                      const Gap(2),
                      Text(
                        'Entrega: ${DateFormatter.toShort(pedido.fechaEntrega!)}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.onSurfaceLight),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstatusChip extends StatelessWidget {
  final EstatusPedido estatus;
  const _EstatusChip({required this.estatus});

  @override
  Widget build(BuildContext context) {
    // No puede ser const porque withValues no es const
    final Color color;
    final Color bgColor;

    switch (estatus) {
      case EstatusPedido.pendiente:
        color = AppColors.warning;
        bgColor = AppColors.warningLight;
      case EstatusPedido.verificado:
        color = AppColors.success;
        bgColor = AppColors.successLight;
      case EstatusPedido.entregado:
        color = AppColors.primary;
        bgColor = Color.fromRGBO(
          AppColors.primary.r.toInt(),
          AppColors.primary.g.toInt(),
          AppColors.primary.b.toInt(),
          0.1,
        );
      case EstatusPedido.error:
        color = AppColors.error;
        bgColor = AppColors.errorLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        estatus.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
