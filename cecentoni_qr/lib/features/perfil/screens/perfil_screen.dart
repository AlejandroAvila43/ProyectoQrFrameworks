import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: currentUser.when(
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.nombre.isNotEmpty
                        ? user.nombre[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const Gap(16),

                Text(user.nombre, style: theme.textTheme.displayMedium),
                const Gap(4),
                Text(user.email, style: theme.textTheme.bodyMedium),
                const Gap(8),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.rol.label,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Gap(40),
                const Divider(),
                const Gap(20),

                _InfoTile(
                    icon: Icons.email_outlined,
                    title: 'Correo',
                    subtitle: user.email),
                _InfoTile(
                    icon: Icons.badge_outlined,
                    title: 'Rol',
                    subtitle: user.rol.label),
                _InfoTile(
                    icon: Icons.fingerprint,
                    title: 'ID',
                    subtitle: user.uid,
                    isCode: true),

                const Gap(40),

                OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  onPressed: () async {
                    await ref.read(loginProvider.notifier).logout();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Error al cargar perfil')),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isCode;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isCode = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(
        subtitle,
        style: isCode
            ? const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: AppColors.onSurfaceLight,
              )
            : null,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
