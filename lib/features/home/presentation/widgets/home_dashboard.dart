// lib/features/home/presentation/widgets/home_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../ai_advisor/presentation/pages/ai_advisor_page.dart';
import '../../../opportunities/presentation/pages/opportunities_page.dart';
import '../../../community/presentation/pages/community_page.dart';
import '../../../startup/presentation/pages/startup_ideas_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final theme   = context.watch<ThemeController>();
    final user    = context.watch<AuthController>().user;
    final now     = DateTime.now();
    final hour    = now.hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final emoji    = hour < 12 ? '☀️' : hour < 17 ? '👋' : '🌙';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.brandVertical),
                child: Stack(children: [
                  Positioned(top: -50, right: -60,
                      child: _Blob(220, 0.07)),
                  Positioned(bottom: -20, left: -40,
                      child: _Blob(160, 0.05)),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$greeting, $emoji',
                                        style: TextStyle(
                                            color: Colors.white.withAlpha(210),
                                            fontSize: 14, fontFamily: 'Inter')),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.fullName.split(' ').first ?? 'Explorer',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                          fontFamily: 'Inter'),
                                    ),
                                  ],
                                ),
                              ),
                              // Avatar
                              GestureDetector(
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const ProfilePage())),
                                child: Container(
                                  width: 46, height: 46,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withAlpha(40),
                                    border: Border.all(color: Colors.white.withAlpha(120), width: 2),
                                  ),
                                  child: user?.profileImageUrl != null
                                      ? ClipOval(child: Image.network(
                                          user!.profileImageUrl!, fit: BoxFit.cover))
                                      : Center(
                                          child: Text(user?.initials ?? 'U',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16,
                                                  fontFamily: 'Inter'))),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // XP badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withAlpha(60)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text('${user?.xpPoints ?? 0} XP · ${user?.xpLevel ?? 'Newcomer'}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12,
                                      fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Theme toggle
                  Positioned(
                    top: 0, right: 8,
                    child: SafeArea(
                      child: IconButton(
                        icon: Icon(
                          theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: Colors.white),
                        onPressed: theme.toggle,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Stats row ───────────────────────────────
                Row(children: [
                  _StatCard('12', 'Applications', Icons.send_rounded,    AppColors.primary,  isDark),
                  const SizedBox(width: 10),
                  _StatCard('8',  'Saved Jobs',   Icons.bookmark_rounded, AppColors.jobs,    isDark),
                  const SizedBox(width: 10),
                  _StatCard('5',  'AI Chats',     Icons.psychology_rounded, AppColors.aiAdvisor, isDark),
                ]),
                const SizedBox(height: 28),

                // ── Search bar ──────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const OpportunitiesPage())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.grey100),
                    ),
                    child: Row(children: [
                      Icon(Icons.search_rounded, color: AppColors.grey400, size: 20),
                      const SizedBox(width: 12),
                      Text('Search jobs, skills, people...',
                          style: TextStyle(color: AppColors.grey400,
                              fontSize: 14, fontFamily: 'Inter')),
                    ]),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Quick access ────────────────────────────
                _SectionHeader('Quick Access', isDark),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.05,
                  children: [
                    _FeatureCard(
                      icon: Icons.psychology_rounded,
                      title: 'AI Advisor',
                      subtitle: 'Career guidance',
                      gradient: AppColors.cardGradientPurple,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AiAdvisorPage())),
                    ),
                    _FeatureCard(
                      icon: Icons.work_rounded,
                      title: 'Job Board',
                      subtitle: 'Browse openings',
                      gradient: AppColors.cardGradientOrange,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const OpportunitiesPage())),
                    ),
                    _FeatureCard(
                      icon: Icons.group_rounded,
                      title: 'Community',
                      subtitle: 'Connect with peers',
                      gradient: AppColors.cardGradientTeal,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const CommunityPage())),
                    ),
                    _FeatureCard(
                      icon: Icons.lightbulb_rounded,
                      title: 'Startups',
                      subtitle: 'Explore ideas',
                      gradient: AppColors.cardGradientAmber,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const StartupIdeasPage())),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Featured jobs preview ───────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionHeader('Featured Jobs', isDark),
                    TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const OpportunitiesPage())),
                      child: const Text('See all',
                          style: TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._featuredJobs(isDark),
                const SizedBox(height: 16),

                // ── Tip of the day ──────────────────────────
                _TipCard(isDark),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _featuredJobs(bool isDark) {
    final jobs = [
      ('Senior Flutter Developer', 'TechCorp Africa', 'Remote', AppColors.primary),
      ('AI/ML Engineer', 'NeuralLabs', 'Lagos, NG', AppColors.aiAdvisor),
      ('Backend Engineer', 'DataFlow Inc', 'Yaoundé, CM', AppColors.community),
    ];
    return jobs.map((j) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.grey100),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: j.$4.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.work_rounded, color: j.$4, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(j.$1, style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14,
                color: isDark ? AppColors.white : AppColors.grey900,
                fontFamily: 'Inter')),
            const SizedBox(height: 2),
            Text('${j.$2} · ${j.$3}',
                style: const TextStyle(
                    color: AppColors.grey500, fontSize: 12, fontFamily: 'Inter')),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [j.$4, j.$4.withAlpha(200)]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Apply', style: TextStyle(
              color: Colors.white, fontSize: 11,
              fontWeight: FontWeight.w700, fontFamily: 'Inter')),
        ),
      ]),
    )).toList();
  }
}

// ── Small widgets ─────────────────────────────────────────────

class _Blob extends StatelessWidget {
  final double size;
  final double opacity;
  const _Blob(this.size, this.opacity);
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha((opacity * 255).round())),
  );
}

class _SectionHeader extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionHeader(this.text, this.isDark);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: isDark ? AppColors.white : AppColors.grey900,
          fontFamily: 'Inter'));
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _StatCard(this.value, this.label, this.icon, this.color, this.isDark);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.grey100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: isDark ? AppColors.white : AppColors.grey900,
                fontFamily: 'Inter')),
        Text(label,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w500,
                color: AppColors.grey400, fontFamily: 'Inter')),
      ]),
    ),
  );
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon, required this.title, required this.subtitle,
    required this.gradient, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: gradient.colors.first.withAlpha(70),
          blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(
              color: Colors.white, fontSize: 16,
              fontWeight: FontWeight.w700, fontFamily: 'Inter')),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(
              color: Colors.white.withAlpha(200),
              fontSize: 11, fontFamily: 'Inter')),
        ]),
      ]),
    ),
  );
}

class _TipCard extends StatelessWidget {
  final bool isDark;
  const _TipCard(this.isDark);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.primary.withAlpha(isDark ? 30 : 15),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withAlpha(60)),
    ),
    child: Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.tips_and_updates_rounded, color: AppColors.primary, size: 22),
      ),
      const SizedBox(width: 14),
      const Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tip of the day', style: TextStyle(
              color: AppColors.primary, fontSize: 12,
              fontWeight: FontWeight.w700, fontFamily: 'Inter')),
          SizedBox(height: 4),
          Text('Tailor your resume for each job application to pass AI screening filters.',
              style: TextStyle(
                  color: AppColors.grey600, fontSize: 13,
                  height: 1.5, fontFamily: 'Inter')),
        ]),
      ),
    ]),
  );
}
