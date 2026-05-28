import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../providers/pedidos_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../widgets/pedido_card.dart';

class PedidosListScreen extends ConsumerWidget {
  const PedidosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedidosAsync = ref.watch(pedidosPendientesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.pedidos),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.white24),
        ),
      ),
      body: pedidosAsync.when(
        data: (pedidos) {
          if (pedidos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 72,
                    color: AppColors.onSurfaceLight.withValues(alpha: 0.4),
                  ),
                  const Gap(16),
                  Text(
                    AppStrings.sinPedidos,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.onSurfaceLight,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'No hay pedidos pendientes por verificar.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  '${pedidos.length} pedido${pedidos.length != 1 ? 's' : ''} pendiente${pedidos.length != 1 ? 's' : ''}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = pedidos[index];
                    return PedidoCard(
                      pedido: pedido,
                      onTap: () {
                        ref.read(pedidoSeleccionadoProvider.notifier).state =
                            pedido;
                        context.push('/pedidos/${pedido.id}');
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const Gap(16),
                Text('Error al cargar pedidos',
                    style: theme.textTheme.titleLarge),
                const Gap(8),
                Text(error.toString(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
