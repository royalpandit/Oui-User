import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_font_awesome_web_names/flutter_font_awesome.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/remote_urls.dart';
import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import '/widgets/custom_image.dart';
import 'controllers/about_us_cubit/about_us_cubit.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AboutUsCubit>().getAboutUs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          Language.aboutUs.capitalizeByWord(),
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: BlocBuilder<AboutUsCubit, AboutUsState>(
        builder: (context, state) {
          if (state is AboutUsStateLoaded) {
            final aboutInfo = state.aboutInfo;
            final model = aboutInfo.aboutUsModel;
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                // ── Hero header ──────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'About Us',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'We are committed to delivering high-quality digital solutions that simplify everyday experiences.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                if (model != null) ...[
                  // ── 3 feature tiles ──────────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Row(
                      children: [
                        Expanded(child: _buildFeatureTile(model.iconOne, model.titleOne, model.descriptionOne)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildFeatureTile(model.iconTwo, model.titleTwo, model.descriptionTwo)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildFeatureTile(model.iconThree, model.titleThree, model.descriptionThree)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Banner image (only if non-empty) ─────────────────
                  if (model.bannerImage.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CustomImage(
                          path: RemoteUrls.imageUrl(model.bannerImage),
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── HTML content ─────────────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Html(
                      data: model.aboutUs,
                      style: {
                        'h1': Style(
                          margin: Margins.only(top: 12, bottom: 4),
                          color: Colors.black,
                          fontSize: FontSize.xLarge,
                          fontWeight: FontWeight.w700,
                          padding: HtmlPaddings.zero,
                        ),
                        'h2': Style(
                          margin: Margins.only(top: 12, bottom: 4),
                          color: Colors.black,
                          fontSize: FontSize.large,
                          fontWeight: FontWeight.w700,
                          padding: HtmlPaddings.zero,
                        ),
                        'p': Style(
                          lineHeight: LineHeight.number(1.7),
                          textAlign: TextAlign.justify,
                          margin: Margins.only(top: 4, bottom: 8),
                          fontSize: FontSize.medium,
                          color: Colors.grey.shade700,
                        ),
                        'li': Style(margin: Margins.only(bottom: 4), color: Colors.grey.shade700),
                        'ul': Style(margin: Margins.only(top: 8, bottom: 8)),
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                ],

                // ── Testimonials ─────────────────────────────────────
                if (aboutInfo.testimonials.isNotEmpty) ...[
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(20, 24, 0, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'What Our Customers Say',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              Row(
                                children: List.generate(5, (i) => const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 210,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: aboutInfo.testimonials.length,
                            padding: const EdgeInsets.only(right: 20),
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final t = aboutInfo.testimonials[index];
                              return _buildTestimonialCard(t, int.tryParse(t.rating) ?? 0);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 32),
              ],
            );
          } else if (state is AboutUsStateLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } else if (state is AboutUsStateError) {
            return Center(
              child: Text(state.errorMessage, style: GoogleFonts.inter(color: Colors.red.shade400)),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildFeatureTile(String icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
            child: Center(child: FaIcon(icon, color: Colors.white, size: 15)),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade600, height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(dynamic result, int countRating) {
    final imageUrl = result.image ?? '';
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(countRating,
                  (_) => const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 15)),
              const Spacer(),
              const Icon(Icons.format_quote_rounded, color: Colors.black12, size: 22),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              result.comment,
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700, height: 1.55),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: imageUrl.isNotEmpty ? NetworkImage(RemoteUrls.imageUrl(imageUrl)) : null,
                onBackgroundImageError: imageUrl.isNotEmpty ? (_, __) {} : null,
                child: imageUrl.isEmpty ? const Icon(Icons.person, size: 18, color: Colors.grey) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.name,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black)),
                    Text(result.designation,
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
