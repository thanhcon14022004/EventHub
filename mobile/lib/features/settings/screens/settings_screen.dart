import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/background_color_provider.dart';
import '../../../core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLocaleProvider);
    final bgColor = ref.watch(appBgColorProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    String t(String key) => AppTranslations.translate(key, lang);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : bgColor.color,
      appBar: AppBar(
        title: Text(
          t('settings_title'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Description Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('settings_title'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          t('settings_subtitle'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ================= 1. SECTION ĐỔI NGÔN NGỮ =================
            _buildSectionHeader(
              context,
              icon: Icons.language_rounded,
              title: t('settings_language_section'),
              subtitle: t('settings_language_desc'),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildLanguageTile(
                    context: context,
                    flag: '🇻🇳',
                    title: 'Tiếng Việt',
                    subtitle: 'Ngôn ngữ Tiếng Việt (Mặc định)',
                    isSelected: lang == AppLanguage.vi,
                    isDark: isDark,
                    onTap: () {
                      ref.read(appLocaleProvider.notifier).setLanguage(AppLanguage.vi);
                    },
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  ),
                  _buildLanguageTile(
                    context: context,
                    flag: '🇬🇧',
                    title: 'English',
                    subtitle: 'English language interface',
                    isSelected: lang == AppLanguage.en,
                    isDark: isDark,
                    onTap: () {
                      ref.read(appLocaleProvider.notifier).setLanguage(AppLanguage.en);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ================= 2. SECTION ĐỔI MÀU NỀN =================
            _buildSectionHeader(
              context,
              icon: Icons.palette_rounded,
              title: t('settings_bgcolor_section'),
              subtitle: t('settings_bgcolor_desc'),
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // 4 Color Selection Grid (Trắng, Xám, Xanh dương, Xanh lá)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildColorCard(
                  context: context,
                  colorOption: AppBgColor.white,
                  isSelected: bgColor == AppBgColor.white && !isDark,
                  isDark: isDark,
                  lang: lang,
                  onTap: () {
                    if (isDark) {
                      ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                    }
                    ref.read(appBgColorProvider.notifier).setBgColor(AppBgColor.white);
                  },
            // Các ô tròn nhỏ chọn màu (Trắng, Xám, Xanh dương, Xanh lá, Đỏ, Vàng)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                _buildColorCard(
                  context: context,
                  colorOption: AppBgColor.gray,
                  isSelected: bgColor == AppBgColor.gray && !isDark,
                  isDark: isDark,
                  lang: lang,
                  onTap: () {
                    if (isDark) {
                      ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                    }
                    ref.read(appBgColorProvider.notifier).setBgColor(AppBgColor.gray);
                  },
                ),
                _buildColorCard(
                  context: context,
                  colorOption: AppBgColor.blue,
                  isSelected: bgColor == AppBgColor.blue && !isDark,
                  isDark: isDark,
                  lang: lang,
                  onTap: () {
                    if (isDark) {
                      ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                    }
                    ref.read(appBgColorProvider.notifier).setBgColor(AppBgColor.blue);
                  },
                ),
                _buildColorCard(
                  context: context,
                  colorOption: AppBgColor.green,
                  isSelected: bgColor == AppBgColor.green && !isDark,
                  isDark: isDark,
                  lang: lang,
                  onTap: () {
                    if (isDark) {
                      ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                    }
                    ref.read(appBgColorProvider.notifier).setBgColor(AppBgColor.green);
                  },
                ),
              ],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: AppBgColor.values.map((colorOption) {
                  return _buildColorCircleItem(
                    context: context,
                    colorOption: colorOption,
                    isSelected: bgColor == colorOption && !isDark,
                    isDark: isDark,
                    lang: lang,
                    onTap: () {
                      if (isDark) {
                        ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                      }
                      ref.read(appBgColorProvider.notifier).setBgColor(colorOption);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // Live Preview Card demonstrating that only background changes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye_rounded, size: 18, color: Color(0xFF4F46E5)),
                      const SizedBox(width: 8),
                      Text(
                        t('settings_preview_title'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t('settings_active_badge'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // The actual preview box filled with the active background color
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : bgColor.color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang == AppLanguage.en ? 'Background Canvas Preview' : 'Không gian nền hiển thị',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lang == AppLanguage.en ? bgColor.descriptionEn : bgColor.descriptionVi,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Example card demonstrating buttons and text stay unchanged
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Nút & Chữ giữ nguyên',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F46E5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Nút bấm mẫu',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ================= 3. SECTION GIAO DIỆN TỐI (DARK MODE) =================
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: SwitchListTile.adaptive(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF312E81) : const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF4F46E5),
                    size: 20,
                  ),
                ),
                title: Text(
                  t('settings_darkmode_section'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                subtitle: Text(
                  t('settings_darkmode_desc'),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                  ),
                ),
                value: isDark,
                activeColor: const Color(0xFF4F46E5),
                onChanged: (_) {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
            ),
            const SizedBox(height: 32),

            // ================= 4. APP VERSION FOOTER =================
            Center(
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t('settings_version_tag'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF4F46E5), size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String flag,
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCard({
  Widget _buildColorCircleItem({
    required BuildContext context,
    required AppBgColor colorOption,
    required bool isSelected,
    required bool isDark,
    required AppLanguage lang,
    required VoidCallback onTap,
  }) {
    final title = lang == AppLanguage.en ? colorOption.nameEn : colorOption.nameVi;
    final isWhite = colorOption == AppBgColor.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorOption.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF4F46E5).withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Color circle swatch preview
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: colorOption.previewColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF94A3B8), width: 1.5),
                  ),
            // Ô tròn nhỏ chọn màu
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorOption.previewColor,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4F46E5)
                      : (isWhite ? const Color(0xFFCBD5E1) : Colors.transparent),
                  width: isSelected ? 3.0 : (isWhite ? 1.5 : 0),
                ),
                // Selected indicator badge
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF4F46E5).withOpacity(0.35)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
              ],
                ],
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 22,
                      color: (colorOption == AppBgColor.white || colorOption == AppBgColor.yellow)
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                    )
                  : null,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  colorOption == AppBgColor.white ? 'Mặc định' : 'Màu nền',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF4F46E5)
                    : (isDark ? Colors.grey[300] : const Color(0xFF334155)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
