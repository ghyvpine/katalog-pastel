import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Notifier untuk mengontrol mode terang/gelap secara dinamis
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const pastelSeed = Color(0xFFB4C6E7); // Color seed pastel khas Material You

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Tugas Pratikum 2',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode, // Mengikuti switch manual dari user
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: pastelSeed,
              brightness: Brightness.light,
              surface: const Color(0xFFF9F9F9),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: pastelSeed,
              brightness: Brightness.dark,
            ),
          ),
          home: const ProductListPage(),
        );
      },
    );
  }
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<dynamic> products = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts([String query = '']) async {
    setState(() => isLoading = true);
    final url = query.isEmpty
        ? 'https://dummyjson.com/products'
        : 'https://dummyjson.com/products/search?q=$query';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = data['products'];
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Pastel'),
        centerTitle: true,
        actions: [
          // Tombol Switch Mode Terang / Gelap
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Switch ke Mode Terang' : 'Switch ke Mode Gelap',
            onPressed: () {
              themeNotifier.value =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Cari produk...',
              leading: const Icon(Icons.search),
              onSubmitted: (value) => fetchProducts(value),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    fetchProducts();
                  },
                )
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(context, product);
              },
            ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: product['id'],
                child: Image.network(
                  product['thumbnail'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product['price']}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
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

class ProductDetailPage extends StatelessWidget {
  final dynamic product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: product['id'],
              child: Image.network(
                product['thumbnail'],
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product['title'],
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          '\$${product['price']}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Deskripsi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['description'],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                        ),
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