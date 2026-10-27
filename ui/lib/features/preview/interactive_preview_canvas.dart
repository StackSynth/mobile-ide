import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class InteractivePreviewCanvas extends StatefulWidget {
  const InteractivePreviewCanvas({super.key});

  @override
  State<InteractivePreviewCanvas> createState() => _InteractivePreviewCanvasState();
}

class _InteractivePreviewCanvasState extends State<InteractivePreviewCanvas> {
  int _cartCount = 0;

  void _addToCart() {
    setState(() => _cartCount++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to Cart! Items in cart: ${_cartCount + 1}'),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF030712), // Slate 950 from React App
      child: Column(
        children: [
          // Simulated App Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF38BDF8)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'S',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'StackShop',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 14, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 6),
                      Text(
                        'Cart ($_cartCount)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Simulated App Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Vite HMR badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFFBBF24)),
                      SizedBox(width: 6),
                      Text(
                        'Vite 6.2 HMR Connected • Fast Refresh active',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Featured Mobile Gadgets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Live interactive web application built with React & Tailwind',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 16),

                // Product Card 1
                _buildProductCard(
                  title: 'CyberDeck Keyboard',
                  description: 'Ultra-portable split mechanical keyboard with OLED display',
                  price: 189,
                  badge: 'SALE 20% OFF',
                  badgeColor: AppColors.success,
                  onAdd: _addToCart,
                ),
                const SizedBox(height: 12),

                // Product Card 2
                _buildProductCard(
                  title: 'Holographic Field Monitor',
                  description: '4K low-latency external OLED display for mobile pair programming',
                  price: 429,
                  badge: 'HOT',
                  badgeColor: AppColors.primary,
                  onAdd: _addToCart,
                ),
                const SizedBox(height: 12),

                // Product Card 3
                _buildProductCard(
                  title: 'Neural Synthesizer Mic',
                  description: 'Directional USB-C microphone with real-time AI noise isolation',
                  price: 129,
                  badge: 'NEW',
                  badgeColor: AppColors.accentCyan,
                  onAdd: _addToCart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String description,
    required int price,
    required String badge,
    required Color badgeColor,
    required VoidCallback onAdd,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: badgeColor.withOpacity(0.4)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$$price',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
              ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Add to Cart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
