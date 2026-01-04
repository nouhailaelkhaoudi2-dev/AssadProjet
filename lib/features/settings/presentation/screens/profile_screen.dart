import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    (user?.displayName?.isNotEmpty == true)
                        ? user!.displayName![0].toUpperCase()
                        : '👤',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Invité',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (user?.email != null)
                      Text(
                        user!.email!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier le profil'),
              onTap: () {
                final authUser = FirebaseAuth.instance.currentUser;
                if (authUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez vous connecter')),
                  );
                  return;
                }

                final nameController = TextEditingController(
                  text: authUser.displayName ?? '',
                );

                showDialog(
                  context: context,
                  builder: (dialogCtx) {
                    return AlertDialog(
                      title: const Text('Modifier le nom'),
                      content: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom d\'affichage',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          child: const Text('Annuler'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final navigator = Navigator.of(dialogCtx);
                            final messenger = ScaffoldMessenger.of(context);
                            final newName = nameController.text.trim();

                            if (newName.isEmpty) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Le nom ne peut pas être vide'),
                                ),
                              );
                              return;
                            }

                            FirebaseAuth.instance.currentUser
                                ?.updateDisplayName(newName)
                                .then((_) async {
                                  await FirebaseAuth.instance.currentUser
                                      ?.reload();
                                  navigator.pop();
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Profil mis à jour'),
                                    ),
                                  );
                                })
                                .catchError((e) {
                                  messenger.showSnackBar(
                                    SnackBar(content: Text('Erreur: $e')),
                                  );
                                });
                          },
                          child: const Text('Enregistrer'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Se déconnecter'),
              onTap: () {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                FirebaseAuth.instance.signOut().then((_) {
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Déconnecté')),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
