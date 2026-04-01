import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/admin_service.dart';
import '../../services/user_prefs.dart';
import 'admin_user_profile_page.dart';

class AdminUsersListPage extends StatefulWidget {
  const AdminUsersListPage({super.key});

  @override
  State<AdminUsersListPage> createState() => _AdminUsersListPageState();
}

class _AdminUsersListPageState extends State<AdminUsersListPage> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  String _searchQuery = "";
  int? _adminId;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    _adminId = await UserPrefs.getUserId();
    if (_adminId == null) return;

    setState(() => _isLoading = true);

    final users = await _adminService.getAllUsers(_adminId!);
    
    // On ne garde que les bénévoles (ou tous les utilisateurs sauf soi-même ?)
    // Selon le besoin, on peut filtrer. Pour l'instant on affiche "Bénévole" (ou tout le monde).
    final benevoles = users.where((u) => u.role != 'Administrateur' && u.id != _adminId).toList();

    if (mounted) {
      setState(() {
        _allUsers = benevoles;
        _filteredUsers = benevoles;
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        final q = query.toLowerCase();
        _filteredUsers = _allUsers.where((u) {
          final fullName = "${u.prenom} ${u.nom}".toLowerCase();
          return fullName.contains(q) || u.email.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  void _openUserProfile(UserModel user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminUserProfilePage(user: user)),
    );
    if (result == true) {
      _loadUsers(); // Refresh on return if deleted or modified
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Gérer les Bénévoles", style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: TextField(
              onChanged: _filterUsers,
              decoration: InputDecoration(
                hintText: "Rechercher par nom ou email...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF004AAD)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF004AAD)))
                : _allUsers.isEmpty
                    ? _buildEmptyView()
                    : _filteredUsers.isEmpty
                        ? const Center(child: Text("Aucun bénévole ne correspond à la recherche.", style: TextStyle(color: Colors.grey)))
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(20),
                              itemCount: _filteredUsers.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                return _buildUserTile(user);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 15),
            const Text(
              "Aucun bénévole enregistré.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return InkWell(
      onTap: () => _openUserProfile(user),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF004AAD).withOpacity(0.1),
              backgroundImage: (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                  ? NetworkImage(user.imageUrl!)
                  : null,
              child: (user.imageUrl == null || user.imageUrl!.isEmpty)
                  ? Text(
                      user.prenom.isNotEmpty ? user.prenom[0].toUpperCase() : "?",
                      style: const TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold, fontSize: 20),
                    )
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${user.prenom} ${user.nom}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 3),
                  Text(user.email, style: const TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
