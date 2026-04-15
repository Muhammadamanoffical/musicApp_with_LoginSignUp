import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;

  bool isEditingBio = false;
  bool isSaving = false;

  final bioCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = widget.user;
    bioCtrl.text = user.bio;
  }

  // ================= REFRESH USER =================
  Future<void> refreshUser() async {
    final updated = await UserService.getUserProfile(user.id);
    if (!mounted) return;

    if (updated != null) {
      setState(() {
        user = updated;
        bioCtrl.text = user.bio;
      });
    }
  }

  // ================= SAVE BIO =================
  Future<void> saveBio() async {
    setState(() => isSaving = true);

    final ok = await UserService.updateBio(
      userId: user.id,
      bio: bioCtrl.text.trim(),
    );

    if (!mounted) return;

    setState(() => isSaving = false);

    if (ok) {
      await refreshUser();
      setState(() => isEditingBio = false);

      showMsg("Bio updated", true);
    } else {
      showMsg("Failed to update bio", false);
    }
  }

  // ================= UPDATE PROFILE PICTURE =================
  Future<void> updateProfilePic() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text("Update Profile Picture",
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Paste image URL",
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = controller.text.trim();

              if (url.isEmpty) return;

              Navigator.pop(context);

              setState(() => isSaving = true);

              final ok = await UserService.updateUserProfile(
                userId: user.id,
                bio: user.bio,
                profilePic: url,
              );

              if (!mounted) return;

              setState(() => isSaving = false);

              if (ok) {
                await refreshUser();
                showMsg("Profile picture updated", true);
              } else {
                showMsg("Failed to update picture", false);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= MESSAGE =================
  void showMsg(String msg, bool ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  // ================= LOGOUT =================
  void logout() async {
    await AuthService.logout();
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final favCount = (user.favorites).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshUser,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: logout,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= PROFILE IMAGE =================
            GestureDetector(
              onTap: updateProfilePic,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: NetworkImage(user.profilePic),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit,
                        size: 16, color: Colors.white),
                  )
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text(
              user.username,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),

            Text(
              user.email,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            // ================= BIO =================
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Bio",
                          style: TextStyle(color: Colors.white)),

                      IconButton(
                        icon: Icon(
                          isEditingBio ? Icons.check : Icons.edit,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          if (isEditingBio) {
                            saveBio();
                          } else {
                            setState(() => isEditingBio = true);
                          }
                        },
                      )
                    ],
                  ),

                  isEditingBio
                      ? TextField(
                          controller: bioCtrl,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                        )
                      : Text(
                          user.bio.isEmpty ? "No bio yet" : user.bio,
                          style: const TextStyle(color: Colors.white70),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= FAVORITES =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Favorites",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "$favCount",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
         ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    bioCtrl.dispose();
    super.dispose();
  }
}