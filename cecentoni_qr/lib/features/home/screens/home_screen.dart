import 'package:cecentoni_qr/core/constants/app_colors.dart';
import 'package:cecentoni_qr/core/constants/app_routes.dart';
import 'package:cecentoni_qr/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cecentoni QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.perfil),
            tooltip: 'Perfil',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              currentUser.when(
                data: (user) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido,',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceLight,
                      ),
                    ),
                    Text(
                      user?.nombre ?? 'Empleado',
                      style: theme.textTheme.displayMedium,
                    ),
                    const Gap(4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user?.rol.label ?? '',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox(height: 60),
                error: (_, __) => const SizedBox.shrink(),
              ).animate().fadeIn(duration: 400.ms),

              const Gap(32),

              _MainActionCard(
                title: 'Verificar pedido',
                subtitle: 'Selecciona un pedido y escanea el QR del piso',
                icon: Icons.qr_code_scanner,
                color: AppColors.primary,
                onTap: () => context.push(AppRoutes.pedidos),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15),

              const Gap(16),

              Text(
                'Accesos rápidos',
                style: theme.textTheme.titleLarge,
              ).animate().fadeIn(delay: 300.ms),
              const Gap(12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _QuickCard(
                    title: 'Pedidos',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.accent,
                    onTap: () => context.push(AppRoutes.pedidos),
                  ),
                  _QuickCard(
                    title: 'Historial',
                    icon: Icons.history,
                    color: AppColors.primaryLight,
                    onTap: () => context.push(AppRoutes.historial),
                  ),
                  _QuickCard(
                    title: 'Mi perfil',
                    icon: Icons.person_outline,
                    color: Colors.teal,
                    onTap: () => context.push(AppRoutes.perfil),
                  ),
                  _QuickCard(
                    title: 'Cerrar sesión',
                    icon: Icons.logout,
                    color: AppColors.error,
                    onTap: () async {
                      await ref.read(loginProvider.notifier).logout();
                    },
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MainActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 48),
              const Gap(20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.7), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: AppColors.shadow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Gap(10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 14,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
