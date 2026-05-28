import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/pedido_model.dart';
import '../../../models/producto_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../providers/pedidos_provider.dart';

class CrearPedidoScreen extends ConsumerStatefulWidget {
  const CrearPedidoScreen({super.key});

  @override
  ConsumerState<CrearPedidoScreen> createState() => _CrearPedidoScreenState();
}

class _CrearPedidoScreenState extends ConsumerState<CrearPedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _clienteController = TextEditingController();
  final _modeloController = TextEditingController();
  final _colorController = TextEditingController();
  final _medidaController = TextEditingController();
  final _loteController = TextEditingController();
  final _fechaController = TextEditingController();

  DateTime _fechaEntrega = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fechaController.text = DateFormat('dd/MM/yyyy').format(_fechaEntrega);
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _modeloController.dispose();
    _colorController.dispose();
    _medidaController.dispose();
    _loteController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaEntrega,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _fechaEntrega) {
      setState(() {
        _fechaEntrega = picked;
        _fechaController.text = DateFormat('dd/MM/yyyy').format(_fechaEntrega);
      });
    }
  }

  Future<void> _guardarPedido() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      
      final nuevoPedido = PedidoModel(
        id: '', // Firestore generará un ID
        numeroPedido: '', // Se calculará del ID del documento
        cliente: _clienteController.text.trim(),
        productoEsperado: ProductoModel(
          modelo: _modeloController.text.trim(),
          color: _colorController.text.trim(),
          medida: _medidaController.text.trim(),
          lote: _loteController.text.trim().toUpperCase(),
        ),
        estatus: EstatusPedido.pendiente,
        fechaEntrega: _fechaEntrega,
      );

      await firestoreService.crearPedido(nuevoPedido);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido creado correctamente'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop(); // Volver a la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el pedido: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Pedido'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Datos del Cliente',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(8),
                const Divider(),
                const Gap(8),
                CustomTextField(
                  label: 'Nombre del Cliente',
                  hint: 'Ej. Juan Pérez',
                  controller: _clienteController,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa el nombre del cliente';
                    }
                    return null;
                  },
                ),
                const Gap(16),
                InkWell(
                  onTap: () => _seleccionarFecha(context),
                  child: IgnorePointer(
                    child: CustomTextField(
                      label: 'Fecha de Entrega',
                      controller: _fechaController,
                      prefixIcon: Icons.calendar_today_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ),
                const Gap(32),
                Text(
                  'Datos del Producto Esperado',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(8),
                const Divider(),
                const Gap(8),
                CustomTextField(
                  label: 'Modelo',
                  hint: 'Ej. Porcelanato Blanco',
                  controller: _modeloController,
                  prefixIcon: Icons.inventory_2_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa el modelo';
                    }
                    return null;
                  },
                ),
                const Gap(16),
                CustomTextField(
                  label: 'Color',
                  hint: 'Ej. Blanco',
                  controller: _colorController,
                  prefixIcon: Icons.color_lens_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa el color';
                    }
                    return null;
                  },
                ),
                const Gap(16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Medida',
                        hint: 'Ej. 60x120',
                        controller: _medidaController,
                        prefixIcon: Icons.aspect_ratio_outlined,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Campo obligatorio';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Lote',
                        hint: 'Ej. LT3301',
                        controller: _loteController,
                        prefixIcon: Icons.qr_code_outlined,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Campo obligatorio';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const Gap(40),
                CustomButton(
                  label: 'Guardar Pedido',
                  icon: Icons.save_outlined,
                  isLoading: _isLoading,
                  onPressed: _guardarPedido,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
