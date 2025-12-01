import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const CryptoTraderApp());
}

class CryptoTraderApp extends StatelessWidget {
  const CryptoTraderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Trader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      home: const LoginScreen(),
    );
  }
}

/// SIMPLE MOCK LOGIN (no Firebase)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoggingIn = true;
    });

    // Fake delay to feel like "auth"
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _isLoggingIn = false;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.currency_bitcoin,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Crypto Trader',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscure = !_obscure;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 4) {
                          return 'Password must be at least 4 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isLoggingIn ? null : _login,
                        child: _isLoggingIn
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is a demo app with FAKE data.\nNo real trading is happening.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// MODEL FOR CRYPTO
class CryptoAsset {
  CryptoAsset({
    required this.symbol,
    required this.name,
    required this.price,
    this.changePercent = 0.0,
    this.holdings = 0.0,
  });

  final String symbol;
  final String name;
  double price;
  double changePercent;
  double holdings; // quantity owned
}

/// MAIN HOME WITH NAVIGATION
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Random _rand = Random();

  late List<CryptoAsset> _assets;
  int _selectedIndex = 0;
  double _fiatBalance = 10000.0; // USD balance (fake)
  Timer? _priceTimer;
  final List<String> _tradeHistory = [];

  @override
  void initState() {
    super.initState();
    _assets = [
      CryptoAsset(symbol: 'BTC', name: 'Bitcoin', price: 65000),
      CryptoAsset(symbol: 'ETH', name: 'Ethereum', price: 3300),
      CryptoAsset(symbol: 'BNB', name: 'BNB', price: 520),
      CryptoAsset(symbol: 'SOL', name: 'Solana', price: 175),
      CryptoAsset(symbol: 'XRP', name: 'XRP', price: 0.6),
    ];
    _startPriceUpdates();
  }

  void _startPriceUpdates() {
    _priceTimer?.cancel();
    _priceTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        for (final asset in _assets) {
          // Random +/- up to 2%
          final changeFactor = 1 + (_rand.nextDouble() * 0.04 - 0.02);
          final oldPrice = asset.price;
          asset.price = (asset.price * changeFactor).clamp(0.01, 1000000.0);
          asset.changePercent = ((asset.price - oldPrice) / oldPrice) * 100;
        }
      });
    });
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleTrade({
    required bool isBuy,
    required CryptoAsset asset,
    required double quantity,
    required BuildContext context,
  }) {
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a positive quantity')),
      );
      return;
    }

    final cost = quantity * asset.price;

    setState(() {
      if (isBuy) {
        if (cost > _fiatBalance) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not enough balance to buy')),
          );
          return;
        }
        _fiatBalance -= cost;
        asset.holdings += quantity;
        _tradeHistory.insert(
          0,
          'Bought ${quantity.toStringAsFixed(4)} ${asset.symbol} @ \$${asset.price.toStringAsFixed(2)}',
        );
      } else {
        if (quantity > asset.holdings) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not enough crypto to sell')),
          );
          return;
        }
        _fiatBalance += cost;
        asset.holdings -= quantity;
        _tradeHistory.insert(
          0,
          'Sold ${quantity.toStringAsFixed(4)} ${asset.symbol} @ \$${asset.price.toStringAsFixed(2)}',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isBuy ? 'Buy order executed' : 'Sell order executed'),
        ),
      );
    });
  }

  double get _portfolioCryptoValue {
    double total = 0;
    for (final asset in _assets) {
      total += asset.holdings * asset.price;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      PricesScreen(assets: _assets),
      TradeScreen(
        assets: _assets,
        fiatBalance: _fiatBalance,
        onTrade: _handleTrade,
      ),
      WalletScreen(
        assets: _assets,
        fiatBalance: _fiatBalance,
        portfolioValue: _portfolioCryptoValue,
      ),
      AlertsScreen(tradeHistory: _tradeHistory),
    ];

    final titles = [
      'Market',
      'Trade',
      'Wallet',
      'Alerts',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'Trade',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}

/// MARKET SCREEN
class PricesScreen extends StatelessWidget {
  const PricesScreen({super.key, required this.assets});

  final List<CryptoAsset> assets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        // Just a visual refresh; real prices are updated by timer
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, index) {
          final asset = assets[index];
          final isUp = asset.changePercent >= 0;
          final changeColor =
              isUp ? Colors.green.shade600 : Colors.red.shade600;
          final changeText =
              '${isUp ? '+' : ''}${asset.changePercent.toStringAsFixed(2)}%';

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(asset.symbol[0]),
              ),
              title: Text(
                '${asset.name} (${asset.symbol})',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('\$${asset.price.toStringAsFixed(2)}'),
              trailing: Text(
                changeText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: changeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: assets.length,
      ),
    );
  }
}

/// TRADE SCREEN
class TradeScreen extends StatefulWidget {
  const TradeScreen({
    super.key,
    required this.assets,
    required this.fiatBalance,
    required this.onTrade,
  });

  final List<CryptoAsset> assets;
  final double fiatBalance;
  final void Function({
    required bool isBuy,
    required CryptoAsset asset,
    required double quantity,
    required BuildContext context,
  }) onTrade;

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  CryptoAsset? _selectedAsset;
  bool _isBuy = true;
  final TextEditingController _qtyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.assets.isNotEmpty) {
      _selectedAsset = widget.assets.first;
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _submitTrade() {
    if (_selectedAsset == null) return;

    final text = _qtyCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter quantity')),
      );
      return;
    }

    final quantity = double.tryParse(text);
    if (quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid number')),
      );
      return;
    }

    widget.onTrade(
      isBuy: _isBuy,
      asset: _selectedAsset!,
      quantity: quantity,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asset = _selectedAsset;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fiat balance: \$${widget.fiatBalance.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<CryptoAsset>(
            value: asset,
            decoration: const InputDecoration(
              labelText: 'Select Crypto',
              border: OutlineInputBorder(),
            ),
            items: widget.assets
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text('${c.name} (${c.symbol})'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedAsset = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _isBuy = true;
                    });
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _isBuy ? Colors.green : theme.colorScheme.primary,
                  ),
                  child: const Text('Buy'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _isBuy = false;
                    });
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        !_isBuy ? Colors.red : theme.colorScheme.primary,
                  ),
                  child: const Text('Sell'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _qtyCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Quantity (${asset?.symbol ?? ''})',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (asset != null) ...[
            Text(
              'Current price: \$${asset.price.toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              'You own: ${asset.holdings.toStringAsFixed(4)} ${asset.symbol}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submitTrade,
              icon: const Icon(Icons.check),
              label: Text(_isBuy ? 'Place Buy Order' : 'Place Sell Order'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Note: This is a DEMO screen.\nNo real money or crypto is used.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// WALLET SCREEN
class WalletScreen extends StatelessWidget {
  const WalletScreen({
    super.key,
    required this.assets,
    required this.fiatBalance,
    required this.portfolioValue,
  });

  final List<CryptoAsset> assets;
  final double fiatBalance;
  final double portfolioValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalValue = fiatBalance + portfolioValue;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Total Portfolio Value',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${totalValue.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cash: \$${fiatBalance.toStringAsFixed(2)}   |   Crypto: \$${portfolioValue.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Your Crypto Holdings',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          if (assets.every((a) => a.holdings == 0))
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('You don\'t own any crypto yet. Make a trade first.'),
            )
          else
            Column(
              children: assets
                  .where((a) => a.holdings > 0)
                  .map(
                    (asset) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(asset.symbol[0]),
                        ),
                        title: Text('${asset.name} (${asset.symbol})'),
                        subtitle: Text(
                          '${asset.holdings.toStringAsFixed(4)} ${asset.symbol}',
                        ),
                        trailing: Text(
                          '\$${(asset.holdings * asset.price).toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

/// ALERTS / TRADE HISTORY SCREEN
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key, required this.tradeHistory});

  final List<String> tradeHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fakePriceAlerts = [
      'BTC price crossed \$65,000',
      'ETH dropped 1.5% in last 5 minutes',
      'BNB is up 2.1% today',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Price Alerts (Demo)',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...fakePriceAlerts.map(
          (alert) => Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(alert),
              subtitle: const Text('Demo push notification'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Recent Trades',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (tradeHistory.isEmpty)
          const Text('No trades yet. Execute a buy or sell order.')
        else
          ...tradeHistory.map(
            (t) => Card(
              child: ListTile(
                leading: const Icon(Icons.swap_vert),
                title: Text(t),
                subtitle: const Text('Just now (demo)'),
              ),
            ),
          ),
      ],
    );
  }
}
