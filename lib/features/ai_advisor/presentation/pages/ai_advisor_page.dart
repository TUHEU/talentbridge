// lib/features/ai_advisor/presentation/pages/ai_advisor_page.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AiAdvisorPage extends StatefulWidget {
  const AiAdvisorPage({super.key});
  @override
  State<AiAdvisorPage> createState() => _AiAdvisorPageState();
}

class _AiAdvisorPageState extends State<AiAdvisorPage> {
  final _msgCtrl  = TextEditingController();
  final _scroll   = ScrollController();
  final _msgs = <_Msg>[
    _Msg(true, "Hi! I'm your AI Career Advisor 🤖\n\nI can help you with:\n• Career path planning\n• Resume & CV tips\n• Interview preparation\n• Salary negotiation\n• In-demand skills in Africa's job market\n\nWhat would you like to explore today?"),
  ];

  void _send() {
    final t = _msgCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _msgs.add(_Msg(false, t));
      _msgs.add(_Msg(true,
          "Great question! Based on current market trends in Africa, I recommend focusing on practical skills and building a strong portfolio. Would you like specific advice on your career path or skills development?"));
    });
    _msgCtrl.clear();
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() { _msgCtrl.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.brandVertical)),
        title: Column(children: [
          const Text('AI Career Advisor', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Text('Powered by Gemini AI',
              style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(200))),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _msgs.length,
            itemBuilder: (_, i) => _Bubble(msg: _msgs[i], isDark: isDark),
          ),
        ),
        _InputBar(controller: _msgCtrl, isDark: isDark, onSend: _send),
      ]),
    );
  }
}

class _Msg { final bool isBot; final String text; const _Msg(this.isBot, this.text); }

class _Bubble extends StatelessWidget {
  final _Msg msg; final bool isDark;
  const _Bubble({required this.msg, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: msg.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (msg.isBot) ...[
          Container(width: 34, height: 34,
            decoration: const BoxDecoration(gradient: AppColors.brandGradient, shape: BoxShape.circle),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20)),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: msg.isBot
                  ? (isDark ? AppColors.darkCard : AppColors.white)
                  : AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft:     const Radius.circular(18),
                topRight:    const Radius.circular(18),
                bottomLeft:  Radius.circular(msg.isBot ? 4 : 18),
                bottomRight: Radius.circular(msg.isBot ? 18 : 4),
              ),
              boxShadow: [BoxShadow(
                color: (msg.isBot ? AppColors.grey200 : AppColors.primary).withAlpha(50),
                blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Text(msg.text, style: TextStyle(
              fontSize: 14, height: 1.55, fontFamily: 'Inter',
              color: msg.isBot ? (isDark ? AppColors.darkText : AppColors.grey800) : Colors.white)),
          ),
        ),
      ],
    ),
  );
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller; final bool isDark; final VoidCallback onSend;
  const _InputBar({required this.controller, required this.isDark, required this.onSend});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.white,
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 16, offset: const Offset(0, -4))],
    ),
    child: Row(children: [
      Expanded(
        child: TextField(
          controller: controller,
          onSubmitted: (_) => onSend(),
          maxLines: null,
          decoration: InputDecoration(
            hintText: 'Ask your career question...',
            filled: true,
            fillColor: isDark ? AppColors.darkCard : AppColors.grey50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: onSend,
        child: Container(
          width: 48, height: 48,
          decoration: const BoxDecoration(gradient: AppColors.brandGradient, shape: BoxShape.circle),
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
        ),
      ),
    ]),
  );
}


// ═══════════════════════════════════════════════════════════════
// OPPORTUNITIES PAGE
// ═══════════════════════════════════════════════════════════════
class OpportunitiesPage extends StatefulWidget {
  const OpportunitiesPage({super.key});
  @override
  State<OpportunitiesPage> createState() => _OpportunitiesPageState();
}

class _OpportunitiesPageState extends State<OpportunitiesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _filter = 'All';

  final _filters = ['All', 'Remote', 'Full-time', 'Part-time', 'Internship'];

  final _jobs = const [
    ('Senior Flutter Dev', 'TechCorp Africa', 'Douala, CM', 'Remote', '\$1.5K–\$3K', Icons.phone_android_rounded, AppColors.primary, 1),
    ('ML Engineer', 'AI Labs', 'Lagos, NG', 'Remote', '\$2K–\$4K', Icons.psychology_rounded, AppColors.aiAdvisor, 2),
    ('Backend Engineer', 'DataFlow Inc', 'Yaoundé, CM', 'Hybrid', '\$1.2K–\$2.5K', Icons.storage_rounded, AppColors.community, 3),
    ('UI/UX Designer', 'Creative Studio', 'Abuja, NG', 'On-site', '\$0.8K–\$1.5K', Icons.design_services_rounded, AppColors.messages, 4),
    ('DevOps Engineer', 'CloudBase', 'Remote', 'Remote', '\$1.5K–\$2.8K', Icons.cloud_rounded, AppColors.jobs, 5),
    ('Mobile Intern', 'InnovateCM', 'Yaoundé, CM', 'On-site', 'Stipend', Icons.code_rounded, AppColors.startup, 7),
  ];

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.brandVertical)),
        title: const Text('Opportunities', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white, indicatorWeight: 3,
          labelColor: Colors.white, unselectedLabelColor: Colors.white60,
          tabs: const [Tab(text: 'All Jobs'), Tab(text: 'Saved')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          Column(children: [
            // filter chips
            SizedBox(height: 54, child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final sel = _filter == _filters[i];
                return FilterChip(
                  label: Text(_filters[i]),
                  selected: sel,
                  onSelected: (_) => setState(() => _filter = _filters[i]),
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
                  labelStyle: TextStyle(
                    color: sel ? Colors.white : AppColors.grey600,
                    fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Inter'),
                  side: BorderSide(color: sel ? AppColors.primary : AppColors.grey200),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              },
            )),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _jobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _JobCard(job: _jobs[i], isDark: isDark),
              ),
            ),
          ]),
          Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.bookmark_outline_rounded, size: 64, color: isDark ? AppColors.grey600 : AppColors.grey300),
            const SizedBox(height: 16),
            const Text('No saved jobs yet', style: TextStyle(color: AppColors.grey500, fontSize: 16, fontFamily: 'Inter')),
            const SizedBox(height: 8),
            const Text('Bookmark jobs to find them here', style: TextStyle(color: AppColors.grey400, fontSize: 13, fontFamily: 'Inter')),
          ])),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final (String, String, String, String, String, IconData, Color, int) job;
  final bool isDark;
  const _JobCard({required this.job, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.grey100),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 48, height: 48,
          decoration: BoxDecoration(color: job.$7.withAlpha(26), borderRadius: BorderRadius.circular(12)),
          child: Icon(job.$6, color: job.$7, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(job.$1, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Inter',
              color: isDark ? AppColors.white : AppColors.grey900)),
          const SizedBox(height: 2),
          Text(job.$2, style: const TextStyle(color: AppColors.grey500, fontSize: 13, fontFamily: 'Inter')),
        ])),
        IconButton(icon: const Icon(Icons.bookmark_outline_rounded, color: AppColors.grey400, size: 22), onPressed: () {}),
      ]),
      const SizedBox(height: 12),
      Wrap(spacing: 6, runSpacing: 6, children: [
        _Tag(Icons.location_on_outlined, job.$3, isDark),
        _Tag(Icons.work_outline_rounded, job.$4, isDark),
        _Tag(Icons.attach_money_rounded, job.$5, isDark),
      ]),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${job.$8}d ago', style: const TextStyle(color: AppColors.grey400, fontSize: 12, fontFamily: 'Inter')),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
            borderRadius: BorderRadius.circular(10)),
          child: const Text('Apply Now', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
        ),
      ]),
    ]),
  );
}

class _Tag extends StatelessWidget {
  final IconData icon; final String text; final bool isDark;
  const _Tag(this.icon, this.text, this.isDark);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.grey50,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.grey100)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: AppColors.grey500),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 11, color: AppColors.grey500, fontWeight: FontWeight.w500, fontFamily: 'Inter')),
    ]),
  );
}


// ═══════════════════════════════════════════════════════════════
// COMMUNITY, MESSAGES, STARTUP, PROFILE PAGES (stubs)
// ═══════════════════════════════════════════════════════════════
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.brandVertical)),
        title: const Text('Community', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: const Center(child: Text('Community — coming soon', style: TextStyle(fontFamily: 'Inter'))),
    );
  }
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.brandVertical)),
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: const Center(child: Text('Messages — coming soon', style: TextStyle(fontFamily: 'Inter'))),
    );
  }
}

class StartupIdeasPage extends StatelessWidget {
  const StartupIdeasPage({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.brandVertical)),
        title: const Text('Startup Ideas', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: const Center(child: Text('Startup Ideas — coming soon', style: TextStyle(fontFamily: 'Inter'))),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.brandVertical)),
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: const Center(child: Text('Profile — coming soon', style: TextStyle(fontFamily: 'Inter'))),
    );
  }
}
