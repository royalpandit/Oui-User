import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/remote_urls.dart';
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
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App Bar ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(color: Color(0xE5131313)),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: 0.10,
              child: Container(width: double.infinity, height: 1, color: const Color(0xFF1C1B1B)),
            ),

            // ── Body ──
            Expanded(
              child: BlocBuilder<AboutUsCubit, AboutUsState>(
                builder: (context, state) {
                  if (state is AboutUsStateLoaded) {
                    final aboutInfo = state.aboutInfo;
                    final model = aboutInfo.aboutUsModel;
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                      children: [
                        const SizedBox(height: 48),
                        Text(
                          'THE HOUSE',
                          style: GoogleFonts.manrope(
                            fontSize: 10, fontWeight: FontWeight.w400,
                            color: Colors.white, height: 1.5, letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'About\nOUI',
                          style: GoogleFonts.notoSerif(
                            fontSize: 36, fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFE5E2E1), height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'We are committed to delivering high-quality digital solutions that simplify everyday experiences.',
                          style: GoogleFonts.manrope(
                            fontSize: 16, fontWeight: FontWeight.w300,
                            color: const Color(0xFFC4C8C0), height: 1.63,
                          ),
                        ),

                        if (model != null) ...[
                          const SizedBox(height: 48),

                          // ── 3 feature tiles ──
                          Column(
                            children: [
                              _buildFeatureTile(model.titleOne, model.descriptionOne),
                              const SizedBox(height: 1),
                              _buildFeatureTile(model.titleTwo, model.descriptionTwo),
                              const SizedBox(height: 1),
                              _buildFeatureTile(model.titleThree, model.descriptionThree),
                            ],
                          ),

                          // ── Banner image ──
                          if (model.bannerImage.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            CustomImage(
                              path: RemoteUrls.imageUrl(model.bannerImage),
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                            ),
                          ],

                          // ── HTML content ──
                          const SizedBox(height: 32),
                          Html(
                            data: model.aboutUs,
                            style: {
                              'h1': Style(
                                color: const Color(0xFFE5E2E1),
                                fontSize: FontSize.xLarge,
                                fontWeight: FontWeight.w400,
                              ),
                              'h2': Style(
                                color: const Color(0xFFE5E2E1),
                                fontSize: FontSize.large,
                                fontWeight: FontWeight.w400,
                              ),
                              'h3': Style(color: const Color(0xFFE5E2E1)),
                              'p': Style(
                                lineHeight: LineHeight.number(1.7),
                                textAlign: TextAlign.justify,
                                fontSize: FontSize.medium,
                                color: const Color(0xFFC4C8C0),
                              ),
                              'li': Style(
                                margin: Margins.only(bottom: 4),
                                color: const Color(0xFFC4C8C0),
                              ),
                              'ul': Style(color: const Color(0xFFC4C8C0)),
                              'a': Style(color: const Color(0xFFE9C349)),
                              'strong': Style(color: const Color(0xFFE5E2E1)),
                              'blockquote': Style(
                                backgroundColor: const Color(0xFF1C1B1B),
                                padding: HtmlPaddings.all(16),
                                color: const Color(0xFFC4C8C0),
                                border: const Border(
                                  left: BorderSide(width: 3, color: Color(0x33E9C349)),
                                ),
                              ),
                            },
                          ),
                        ],

                        // ── Testimonials ──
                        if (aboutInfo.testimonials.isNotEmpty) ...[
                          const SizedBox(height: 48),
                          Text(
                            'CLIENT TESTIMONIALS',
                            style: GoogleFonts.manrope(
                              fontSize: 10, fontWeight: FontWeight.w400,
                              color: Colors.white, height: 1.5, letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...aboutInfo.testimonials.map((t) {
                            final countRating = int.tryParse(t.rating) ?? 0;
                            final imageUrl = t.image;
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 1),
                              padding: const EdgeInsets.all(32),
                              color: const Color(0xFF1C1B1B),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: List.generate(countRating,
                                        (_) => const Icon(Icons.star_rounded, color: Color(0xFFE9C349), size: 14)),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    t.comment,
                                    style: GoogleFonts.manrope(
                                      fontSize: 14, fontWeight: FontWeight.w300,
                                      color: const Color(0xFFC4C8C0), height: 1.7,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: const Color(0xFF262626),
                                        backgroundImage: imageUrl.isNotEmpty
                                            ? NetworkImage(RemoteUrls.imageUrl(imageUrl))
                                            : null,
                                        onBackgroundImageError: imageUrl.isNotEmpty ? (_, __) {} : null,
                                        child: imageUrl.isEmpty
                                            ? const Icon(Icons.person, size: 18, color: Color(0xFF777777))
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.name,
                                            style: GoogleFonts.manrope(
                                              fontSize: 13, fontWeight: FontWeight.w600,
                                              color: const Color(0xFFE5E2E1),
                                            ),
                                          ),
                                          Text(
                                            t.designation,
                                            style: GoogleFonts.manrope(
                                              fontSize: 11, color: const Color(0xFF777777),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],

                        const SizedBox(height: 32),
                      ],
                    );
                  } else if (state is AboutUsStateLoading) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF444444)),
                    );
                  } else if (state is AboutUsStateError) {
                    return Center(
                      child: Text(state.errorMessage, style: GoogleFonts.manrope(color: Colors.red.shade300)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: const Color(0xFF1C1B1B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: const Color(0xFFE5E2E1), height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.manrope(
              fontSize: 13, fontWeight: FontWeight.w300,
              color: const Color(0xFFC4C8C0), height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
