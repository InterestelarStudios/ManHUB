import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';

enum _PhotoAction { camera, gallery, remove }

class ProfilePhotoBottomSheet {
  /// Exibe o menu de opções e orquestra a seleção e o upload da foto.
  static Future<void> show(
    BuildContext context, {
    String? currentPhotoUrl,
    required Function(String? newUrl) onPhotoChanged,
  }) async {
    final hasPhoto = currentPhotoUrl != null && currentPhotoUrl.isNotEmpty;

    // 1. Exibe a folha de opções de foto
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _ProfilePhotoOptionsSheet(hasPhoto: hasPhoto),
    );

    if (action == null || !context.mounted) return;

    // 2. Executa a ação escolhida usando o context da tela
    if (action == _PhotoAction.remove) {
      await _handleRemovePhoto(context, onPhotoChanged);
    } else {
      final source = action == _PhotoAction.camera
          ? ImageSource.camera
          : ImageSource.gallery;
      await _handlePickAndUpload(context, source, onPhotoChanged);
    }
  }

  static Future<void> _handlePickAndUpload(
    BuildContext context,
    ImageSource source,
    Function(String? newUrl) onPhotoChanged,
  ) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null || !context.mounted) return;

      final Uint8List bytes = await pickedFile.readAsBytes();

      if (!context.mounted) return;

      // Diálogo de confirmação com visualização da foto
      final bool? confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _PhotoPreviewDialog(bytes: bytes),
      );

      if (confirmed != true || !context.mounted) return;

      // Realiza o upload para o Firebase Storage
      await _performUpload(context, bytes, pickedFile.name, onPhotoChanged);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Não foi possível carregar a imagem: $e'),
          ),
        );
      }
    }
  }

  static Future<void> _performUpload(
    BuildContext context,
    Uint8List bytes,
    String fileName,
    Function(String? newUrl) onPhotoChanged,
  ) async {
    // Diálogo com indicador de progresso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            color: AppColors.card,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.neonPrimary),
                  SizedBox(height: 16),
                  Text(
                    'Salvando sua foto...',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final authService = AuthService();
      final user = authService.firebaseUser;
      if (user == null) {
        throw 'Usuário não autenticado.';
      }

      final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
      final fileNameOnStorage = 'profile_${DateTime.now().millisecondsSinceEpoch}.$ext';

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child(fileNameOnStorage);

      final uploadTask = await storageRef.putData(
        bytes,
        SettableMetadata(contentType: mime),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Atualiza no banco de dados de forma isolada sem apagar outros dados
      await authService.updateProfilePhoto(downloadUrl);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Fecha diálogo de loading
        onPhotoChanged(downloadUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.neonPrimary,
            content: Text(
              'Foto de perfil atualizada com sucesso!',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Fecha diálogo de loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Erro ao salvar foto: $e'),
          ),
        );
      }
    }
  }

  static Future<void> _handleRemovePhoto(
    BuildContext context,
    Function(String? newUrl) onPhotoChanged,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover foto de perfil', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Deseja realmente remover sua foto atual e voltar ao avatar padrão?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      final authService = AuthService();
      await authService.updateProfilePhoto(null);

      if (context.mounted) {
        onPhotoChanged('');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil removida com sucesso.'),
            backgroundColor: AppColors.card,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Erro ao remover foto: $e'),
          ),
        );
      }
    }
  }
}

class _ProfilePhotoOptionsSheet extends StatelessWidget {
  final bool hasPhoto;

  const _ProfilePhotoOptionsSheet({required this.hasPhoto});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                'Alterar Foto de Perfil',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              context: context,
              icon: Icons.photo_camera_rounded,
              title: 'Câmera',
              subtitle: 'Tirar uma foto agora com a câmera',
              action: _PhotoAction.camera,
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              context: context,
              icon: Icons.photo_library_rounded,
              title: 'Galeria',
              subtitle: 'Escolher uma imagem da galeria do celular',
              action: _PhotoAction.gallery,
            ),
            if (hasPhoto) ...[
              const SizedBox(height: 8),
              _buildOptionTile(
                context: context,
                icon: Icons.delete_outline_rounded,
                title: 'Remover Foto Atual',
                subtitle: 'Excluir a foto e usar o avatar padrão',
                isDestructive: true,
                action: _PhotoAction.remove,
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required _PhotoAction action,
    bool isDestructive = false,
  }) {
    final iconColor = isDestructive ? AppColors.error : AppColors.neonLight;
    final titleColor = isDestructive ? AppColors.error : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(action),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDestructive
                  ? AppColors.error.withValues(alpha: 0.3)
                  : AppColors.textSecondary.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.15),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
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
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPreviewDialog extends StatelessWidget {
  final Uint8List bytes;

  const _PhotoPreviewDialog({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Center(
        child: Text(
          'Confirmar Foto',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neonPrimary, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonPrimary.withValues(alpha: 0.25),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.memory(
                bytes,
                fit: BoxFit.cover,
                width: 150,
                height: 150,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Deseja salvar esta imagem como sua nova foto de perfil no Man Hub?',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonPrimary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
