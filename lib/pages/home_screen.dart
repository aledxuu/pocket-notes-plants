import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Plant> _plants = [];
  bool _isLoading = true;

  // Load plants from SQLite.
  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    final plants = await DatabaseHelper.instance.getPlants();
  
    final db = await DatabaseHelper.instance.database;
    print(await db.query('plants'));
    
    if (!mounted) return;

    setState(() {
      _plants = plants;
      _isLoading = false;
    });
  }

  // Add or edit a plant.
  Future<void> _showPlantDialog({Plant? plant}) async {
    final isEditing = plant != null;

    final nameController = TextEditingController(text: plant?.plantName ?? '');
    final notesController =
        TextEditingController(text: plant?.wateringNotes ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Plant' : 'Add Plant'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Plant Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a plant name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Watering Notes',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter watering notes';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final newPlant = Plant(
                  id: plant?.id,
                  plantName: nameController.text.trim(),
                  wateringNotes: notesController.text.trim(),
                );

                if (isEditing) {
                  await DatabaseHelper.instance.updatePlant(newPlant);
                } else {
                  await DatabaseHelper.instance.insertPlant(newPlant);
                }

                if (!dialogContext.mounted) return;

                // Only close the dialog here. The list reloads after
                // showDialog finishes (below), so it never rebuilds
                // while the dialog is still closing.
                Navigator.pop(dialogContext);
              },
              child: Text(isEditing ? 'Update' : 'Save'),
            ),
          ],
        );
      },
    );

    // No dispose() calls here: disposing the controllers while the dialog
    // is still animating closed causes "_dependents.isEmpty is not true".
    await _loadPlants();
  }

  // Delete a plant.
  Future<void> _deletePlant(Plant plant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Plant?'),
          content: Text('Are you sure you want to delete ${plant.plantName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deletePlant(plant.id!);
      await _loadPlants();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pocket Notes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const Icon(Icons.light_mode_outlined),
          Switch(value: isDark, onChanged: widget.onThemeChanged),
          const Icon(Icons.dark_mode_outlined),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plants.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_florist_outlined, size: 70),
                      SizedBox(height: 12),
                      Text('No plants yet.', style: TextStyle(fontSize: 18)),
                      Text('Tap + to add your first plant.'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _plants.length,
                  itemBuilder: (context, index) {
                    final plant = _plants[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            plant.plantName.isNotEmpty
                                ? plant.plantName[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(
                          plant.plantName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(plant.wateringNotes),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showPlantDialog(plant: plant);
                            } else if (value == 'delete') {
                              _deletePlant(plant);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlantDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
