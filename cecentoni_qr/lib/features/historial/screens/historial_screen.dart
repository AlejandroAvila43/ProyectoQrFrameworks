import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/historial_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/verificacion_card.dart';

class HistorialScreen extends ConsumerWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historialAsync = ref.watch(historialProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.historial)),
      body: historialAsync.when(
        data: (verificaciones) {
          if (verificaciones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 72,
                    color: AppColors.onSurfaceLight.withValues(alpha: 0.3),
                  ),
                  const Gap(16),
                  Text(
                    AppStrings.sinHistorial,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.onSurfaceLight,
                    ),
                  ),
                ],
              ),
            );
          }

          final correctos = verificaciones.where((v) => v.resultado).length;
          final incorrectos = verificaciones.length - correctos;

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Total',
                      value: verificaciones.length.toString(),
                      icon: Icons.assessment,
                      color: Colors.white,
                    ),
                    _StatItem(
                      label: 'Correctos',
                      value: correctos.toString(),
                      icon: Icons.check_circle,
                      color: Colors.greenAccent,
                    ),
                    _StatItem(
                      label: 'Errores',
                      value: incorrectos.toString(),
                      icon: Icons.cancel,
                      color: Colors.redAccent.shade100,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: verificaciones.length,
                  itemBuilder: (context, index) {
                    return VerificacionCard(
                      verificacion: verificaciones[index],
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const Gap(4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
