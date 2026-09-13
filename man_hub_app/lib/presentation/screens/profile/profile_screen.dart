import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/bookmark_service.dart';
import '../auth/auth_screen.dart';
import 'edit_profile_screen.dart';
import 'personalized_profile_screen.dart';
import 'bookmarks_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final BookmarkService _bookmarkService = BookmarkService();

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthChanged);
    _bookmarkService.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    _bookmarkService.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _openLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  void _openEditProfile(UserProfile user) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
    );
  }

  void _openPersonalizedProfile(UserProfile user) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PersonalizedProfileScreen(user: user)),
    );
  }

  void _openBookmarks() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BookmarksScreen()),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Sair da Conta', style: TextStyle(color: AppColors.textPrimary)),
          content: const Text(
            'Tem certeza que deseja encerrar a sua sessão?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _authService.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sessão encerrada com sucesso.')),
                  );
                }
              },
              child: const Text('Sair', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _authService.isLoggedIn;
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: false,
        actions: [
          if (isLoggedIn && user != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.neonPrimary),
              tooltip: 'Editar Perfil',
              onPressed: () => _openEditProfile(user),
            ),
        ],
      ),
      body: SafeArea(
        child: isLoggedIn && user != null
            ? _buildLoggedInView(user)
            : _buildVisitorView(),
      ),
    );
  }

  Widget _buildVisitorView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonPrimary.withValues(alpha: 0.05),
                border: Border.all(
                  color: AppColors.neonPrimary.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonPrimary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 64,
                color: AppColors.neonPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Acesse Seu Perfil',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Acompanhe seu progresso de evolução, acesse suas anamneses de visagismo/estilo e personalize a sua experiência.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _openLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalBlue,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Entrar na Jornada',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildProfileOption(
              icon: Icons.bookmarks_outlined,
              title: 'Telas Salvas & Favoritos',
              subtitle: 'Acesse suas dicas e telas marcadas',
              badge: _bookmarkService.count > 0 ? '${_bookmarkService.count}' : null,
              onTap: _openBookmarks,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInView(UserProfile user) {
    final hasCustomPhoto = user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _openEditProfile(user),
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.card,
                          border: Border.all(
                            color: AppColors.neonPrimary,
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonPrimary.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 16,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: hasCustomPhoto
                            ? ClipOval(
                                child: Image.network(
                                  user.profileImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildAvatarFallback(user.name),
                                ),
                              )
                            : _buildAvatarFallback(user.name),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.royalBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.backgroundMain,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.royalBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.neonPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    user.memberType,
                    style: const TextStyle(
                      color: AppColors.neonLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    user.bio!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openEditProfile(user),
                      icon: const Icon(Icons.edit_note_rounded, size: 16),
                      label: const Text('Editar Conta'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _openPersonalizedProfile(user),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
                      label: const Text('Diagnóstico VIP'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.royalBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Medidas e Biotipo se cadastrados
          if (user.height != null || user.weight != null || user.bodyType != null || user.faceShape != null || user.stylePreference != null) ...[
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (user.height != null && user.height!.isNotEmpty)
                  _buildStatBadge(Icons.height_rounded, user.height!),
                if (user.weight != null && user.weight!.isNotEmpty)
                  _buildStatBadge(Icons.fitness_center_rounded, user.weight!),
                if (user.bodyType != null && user.bodyType!.isNotEmpty)
                  _buildStatBadge(Icons.accessibility_new_rounded, user.bodyType!),
                if (user.faceShape != null && user.faceShape!.isNotEmpty)
                  _buildStatBadge(Icons.face_rounded, 'Rosto ${user.faceShape!}'),
                if (user.stylePreference != null && user.stylePreference!.isNotEmpty)
                  _buildStatBadge(Icons.style_rounded, user.stylePreference!),
              ],
            ),
          ],

          // Card Destaque: Diagnóstico de Estilo
          const SizedBox(height: 24),
          InkWell(
            onTap: () => _openPersonalizedProfile(user),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.royalBlue.withValues(alpha: 0.35),
                    AppColors.card,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.neonPrimary.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.neonPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.neonPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DIAGNÓSTICO PERSONALIZADO',
                          style: TextStyle(
                            color: AppColors.neonLight,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.faceShape != null || user.bodyType != null
                              ? 'Atualizar Visagismo & Estilo'
                              : 'Registrar Minhas Características',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.faceShape != null || user.bodyType != null
                              ? 'Suas medidas e preferências estão salvas'
                              : 'Defina seu formato de rosto, biotipo e estilo',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.neonPrimary, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          _buildProfileOption(
            icon: Icons.bookmarks_outlined,
            title: 'Telas Salvas & Favoritos',
            subtitle: 'Revise rapidamente suas dicas e telas marcadas',
            badge: _bookmarkService.count > 0 ? '${_bookmarkService.count}' : null,
            onTap: _openBookmarks,
          ),
          const SizedBox(height: 12),
          _buildProfileOption(
            icon: Icons.person_outline,
            title: 'Meus Dados Principais',
            subtitle: 'Editar nome, e-mail, foto e bio',
            onTap: () => _openEditProfile(user),
          ),
          const SizedBox(height: 12),
          _buildProfileOption(
            icon: Icons.face_outlined,
            title: 'Anamnese de Visagismo & Estilo',
            subtitle: 'Formato de rosto, pele, biotipo e perfumes',
            onTap: () => _openPersonalizedProfile(user),
          ),
          const SizedBox(height: 12),
          _buildProfileOption(
            icon: Icons.emoji_events_outlined,
            title: 'Conquistas & Progresso',
            subtitle: 'Acompanhe suas metas de evolução',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildProfileOption(
            icon: Icons.credit_card_outlined,
            title: 'Minha Assinatura',
            subtitle: 'Gerenciar plano e acessos',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          
          // Botão Sair da Conta
          OutlinedButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Sair da Conta'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error, width: 1.2),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.neonPrimary,
          fontSize: 38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonPrimary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.neonPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.neonPrimary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.neonPrimary, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.neonPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.neonPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: AppColors.neonPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
