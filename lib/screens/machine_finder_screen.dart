import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MachineFinderScreen extends StatefulWidget {
  const MachineFinderScreen({super.key});

  @override
  State<MachineFinderScreen> createState() => _MachineFinderScreenState();
}

class _MachineFinderScreenState extends State<MachineFinderScreen> {
  final List<Map<String, dynamic>> _machines = [
    {
      'name': 'SM City Cebu',
      'address': 'Juan Luna Ave, Cebu City, 6000 Cebu',
      'distance': '2.1 km',
      'status': 'online',
      'capacity': 85,
      'lat': 10.3157,
      'lng': 123.9046,
    },
    {
      'name': 'Ayala Center Cebu', 
      'address': 'Cardinal Rosales Ave, Cebu City, 6000 Cebu',
      'distance': '3.4 km',
      'status': 'online',
      'capacity': 92,
      'lat': 10.3181,
      'lng': 123.9064,
    },
    {
      'name': 'Robinson\'s Place Cebu',
      'address': 'General Maxilom Avenue, Cebu City, 6000 Cebu',
      'distance': '4.2 km', 
      'status': 'maintenance',
      'capacity': 0,
      'lat': 10.3125,
      'lng': 123.8998,
    },
    {
      'name': 'IT Park Central Bloc',
      'address': 'Salinas Dr, Lahug, Cebu City, 6000 Cebu',
      'distance': '5.8 km',
      'status': 'online',
      'capacity': 73,
      'lat': 10.3267,
      'lng': 123.9081,
    },
    {
      'name': 'University of San Carlos',
      'address': 'P. del Rosario St, Cebu City, 6000 Cebu',
      'distance': '6.3 km',
      'status': 'online',
      'capacity': 41,
      'lat': 10.2968,
      'lng': 123.9018,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Machines'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Machine status updated')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade400],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Machines near Cebu City',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_machines.where((m) => m['status'] == 'online').length} of ${_machines.length} machines available',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Machine List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _machines.length,
              itemBuilder: (context, index) {
                final machine = _machines[index];
                final isOnline = machine['status'] == 'online';
                final capacity = machine['capacity'] as int;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isOnline ? Colors.green.shade200 : Colors.red.shade200,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      machine['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      machine['address'],
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isOnline ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isOnline ? Colors.green.shade300 : Colors.red.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isOnline ? Colors.green : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isOnline ? 'Online' : 'Offline',
                                      style: TextStyle(
                                        color: isOnline ? Colors.green.shade700 : Colors.red.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Capacity Bar
                          if (isOnline) ...[
                            Row(
                              children: [
                                Icon(Icons.inventory, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  'Capacity: $capacity%',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: capacity / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                capacity > 80 ? Colors.red :
                                capacity > 50 ? Colors.orange : Colors.green,
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 12),
                          
                          // Action Buttons
                          Row(
                            children: [
                              Icon(Icons.near_me, size: 16, color: Colors.blue),
                              const SizedBox(width: 6),
                              Text(
                                machine['distance'],
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () => _openInMaps(machine),
                                icon: const Icon(Icons.directions, size: 16),
                                label: const Text('Directions'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openInMaps(Map<String, dynamic> machine) async {
    final lat = machine['lat'];
    final lng = machine['lng'];
    final name = machine['name'];
    
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open maps for $name')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening maps: $e')),
        );
      }
    }
  }
}
