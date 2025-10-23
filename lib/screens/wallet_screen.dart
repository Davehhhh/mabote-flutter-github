import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/session.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Map<String, dynamic>? _walletData;
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
    
    // Refresh wallet data every 2 seconds for real-time updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _fetchWalletData();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchWalletData() async {
    try {
      final uid = await Session.userId();
      if (uid == null) throw Exception('Not logged in - user_id is null');
      
      const base = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.254.128/mabote_api');
      final url = Uri.parse('$base/get_wallet.php?user_id=$uid');
      final res = await http.get(url);
      final data = jsonDecode(res.body);
      
      if (res.statusCode == 200 && data is Map<String, dynamic> && data['success'] == true) {
        setState(() {
          _walletData = data;
          _isLoading = false;
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch wallet');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: RefreshIndicator(
        onRefresh: _fetchWalletData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_walletData == null)
                const Center(child: Text('Failed to load wallet data'))
              else ...[
                _item(context, 'Available Balance', _walletData!['current_balance'] ?? 0, Colors.green),
                const SizedBox(height: 12),
                _item(context, 'Total Earned', _walletData!['total_earned'] ?? 0, Colors.blue),
                const SizedBox(height: 12),
                _item(context, 'Total Redeemed', _walletData!['total_redeemed'] ?? 0, Colors.orange),
                const SizedBox(height: 12),
                _item(context, 'Total Deposits', _walletData!['total_deposits'] ?? 0, Colors.purple),
                const SizedBox(height: 12),
                // Add member since date
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Member Since',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatMemberSince(_walletData!['last_transaction_date']),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFEAF3E8), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.lightBlue.shade600, fontWeight: FontWeight.w700)),
          Text('$value', style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  String _formatMemberSince(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'September 2025';
    }
    
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'September 2025';
    }
  }
}


