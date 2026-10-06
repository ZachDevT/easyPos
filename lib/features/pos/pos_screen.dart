import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/right_side_panel.dart';
import '../products/providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/session_provider.dart';
import 'widgets/opening_balance_dialog.dart';
import 'widgets/payment_panel.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  void _showOpeningBalanceDialog(BuildContext context, WidgetRef ref) async {
    final opened = await showRightSidePanel<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const OpeningBalanceDialog(),
    );
    if (opened == true) {
      ref.invalidate(activeSessionProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(activeSessionProvider);

    return Scaffold(
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        data: (session) {
          if (session == null) {
            return _buildClosedRegisterScreen(context, ref);
          }
          return _buildPosLayout(context, ref);
        },
      ),
    );
  }

  Widget _buildClosedRegisterScreen(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            'La caisse est fermée',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            'Vous devez ouvrir la caisse et déclarer le fond\ninitial avant de pouvoir effectuer des ventes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Ouvrir la caisse',
            icon: Icons.key,
            onPressed: () => _showOpeningBalanceDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildPosLayout(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Left Pane: Product Grid & Search
        Expanded(
            flex: 6,
            child: Column(
              children: [
                _buildSearchBar(context),
                Expanded(
                  child: _buildProductGrid(context, ref),
                ),
              ],
            ),
          ),
          
          // Right Pane: Cart & Payment
          Expanded(
            flex: 4,
            child: Container(
              color: AppTheme.cardColor,
              child: Column(
                children: [
                  _buildCartHeader(context),
                  Expanded(
                    child: _buildCartItems(context, ref),
                  ),
                  _buildCartSummary(context, ref),
                ],
              ),
            ),
          ),
        ],
      );
    
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: AppTheme.backgroundColor,
      child: TextField(
        decoration: InputDecoration(
          hintText: '🔎 Rechercher produit ou scanner un code-barres',
          filled: true,
          fillColor: AppTheme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erreur de chargement: $err')),
      data: (products) {
        if (products.isEmpty) {
          return const Center(
            child: Text('Aucun produit disponible. Allez dans "Produits" pour en ajouter.'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  ref.read(cartProvider.notifier).addProduct(
                    product.id,
                    product.name,
                    product.sellingPrice,
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.grey[100],
                        child: product.imagePath != null
                            ? Image.file(File(product.imagePath!), fit: BoxFit.cover)
                            : const Icon(Icons.image, size: 40, color: Colors.black26),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${product.sellingPrice} CDF',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCartHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Panier', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Icon(Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildCartItems(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    if (cartItems.isEmpty) {
      return const Center(
        child: Text('Le panier est vide', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cartItems.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline), 
                  onPressed: () {
                    ref.read(cartProvider.notifier).updateQuantity(item.productId, item.quantity - 1);
                  }
                ),
                Text('${item.quantity}'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline), 
                  onPressed: () {
                    ref.read(cartProvider.notifier).updateQuantity(item.productId, item.quantity + 1);
                  }
                ),
              ],
            ),
            Expanded(
              flex: 1,
              child: Text('${item.total} CDF', textAlign: TextAlign.right),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCartSummary(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(cartProvider.notifier).subtotal;
    // For now, no discount logic
    final total = subtotal;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sous-total:', style: TextStyle(color: Colors.grey)),
              Text('$subtotal CDF', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Réduction:', style: TextStyle(color: Colors.grey)),
              Text('0 CDF', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL:', style: Theme.of(context).textTheme.titleLarge),
              Text(
                '$total CDF',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: 'ENCAISSER',
              icon: Icons.payments,
              onPressed: () {
                if (total > 0) {
                  showRightSidePanel(
                    context: context,
                    builder: (context) => PaymentPanel(totalAmount: total),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
