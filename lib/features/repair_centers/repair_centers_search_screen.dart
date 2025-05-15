import 'package:flutter/material.dart';
import 'package:crscl/features/repair_centers/repair_center_repository.dart';
import 'package:crscl/features/repair_centers/models/repair_center.dart';

class RepairCentersSearchScreen extends StatefulWidget {
  const RepairCentersSearchScreen({super.key});

  @override
  RepairCentersSearchScreenState createState() =>
      RepairCentersSearchScreenState();
}

class RepairCentersSearchScreenState extends State<RepairCentersSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RepairCenterRepository _repository = RepairCenterRepository();
  List<RepairCenter> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchRepairCenters(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final results = await _repository.searchRepairCenters(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching repair centers: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Repair Centers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for repair centers...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchRepairCenters(_searchController.text);
                  },
                ),
              ),
              onSubmitted: _searchRepairCenters,
            ),
          ),
          _isLoading
              ? const CircularProgressIndicator()
              : Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final repairCenter = _searchResults[index];
                    return ListTile(
                      title: Text(repairCenter.name),
                      subtitle: Text(repairCenter.address),
                      onTap: () {
                        // Navigate to repair center detail screen
                      },
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}
