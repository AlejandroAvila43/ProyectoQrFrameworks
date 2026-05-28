import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../models/verificacion_model.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';

/// Tarjeta para mostrar una verificación en el historial.
class VerificacionCard extends StatelessWidget {
  final VerificacionModel verificacion;

  const VerificacionCard({super.key, required this.verificacion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esValido = verificacion.resultado;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícono del resultado
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: esValido ? AppColors.successLight : AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                esValido ? Icons.check_circle : Icons.cancel,
                color: esValido ? AppColors.success : AppColors.error,
                size: 26,
              ),
            ),
            const Gap(12),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        verificacion.cliente,
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        DateFormatter.toShort(verificacion.fecha),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Gap(2),
                  Text(
                    verificacion.productoEscaneado.modelo,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    'Lote: ${verificacion.productoEscaneado.lote}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppColors.onSurfaceLight,
                      ),
                      const Gap(4),
                      Expanded(
                        child: Text(
                          verificacion.empleadoNombre,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: esValido
                              ? AppColors.successLight
                              : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          esValido ? '✓ Correcto' : '✗ Error',
                          style: TextStyle(
                            color:
                                esValido ? AppColors.success : AppColors.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}