import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/session.dart';
import '../services/notification_service.dart';
import '../widgets/modern_loading.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  List<Map<String, dynamic>> _rewards = [];
  bool _isLoading = true;
  bool _isClaiming = false;
  Timer? _refreshTimer;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _fetchRewards();
    
    // Refresh rewards every 2 seconds for real-time updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _fetchRewards();
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

  Future<void> _fetchRewards() async {
    try {
      const base = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.254.128/mabote_api');
      final url = Uri.parse('$base/list_rewards.php');
      final res = await http.get(url);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      
      if (res.statusCode == 200 && data['success'] == true) {
        setState(() {
          _rewards = (data['rewards'] as List).cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch rewards');
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
      appBar: AppBar(title: const Text('Rewards')),
      body: RefreshIndicator(
        onRefresh: _fetchRewards,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _rewards.isEmpty
                ? const Center(child: Text('No rewards available'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rewards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final r = _rewards[i];
                      return _buildRewardCard(r);
                    },
                  ),
      ),
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> r) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['reward_name'] ?? 'Unknown Reward',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r['description'] ?? 'No description available',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Points Required',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${r['points_required'] ?? 0} pts',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _isClaiming ? null : () => _claimReward(r),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isClaiming
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Claim'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _claimReward(Map<String, dynamic> reward) async {
    if (_isClaiming) return;

    setState(() {
      _isClaiming = true;
    });

    try {
      final uid = await Session.userId();
      if (uid == null) {
        throw Exception('Not logged in');
      }

      const base = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.254.128/mabote_api');
      final url = Uri.parse('$base/claim_reward.php');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': uid,
          'reward_id': reward['reward_id'],
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['success'] == true) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Reward claimed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Send notification
        await _notificationService.sendServerNotification(
          userId: uid,
          type: 'reward_claimed',
          title: '🎉 Reward Claimed!',
          message: 'You successfully claimed ${reward['reward_name']}!',
        );

        // Refresh rewards list
        _fetchRewards();
      } else {
        throw Exception(data['message'] ?? 'Failed to claim reward');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClaiming = false;
        });
      }
    }
  }
}
