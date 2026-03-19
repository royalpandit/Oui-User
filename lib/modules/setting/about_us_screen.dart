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
      backgroundColor: Colors.white,
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
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                if (aboutInfo.aboutUsModel != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildIntro(aboutInfo.aboutUsModel!.iconOne, aboutInfo.aboutUsModel!.titleOne),
                      _buildIntro(aboutInfo.aboutUsModel!.iconTwo, aboutInfo.aboutUsModel!.titleTwo),
                      _buildIntro(aboutInfo.aboutUsModel!.iconThree, aboutInfo.aboutUsModel!.titleThree),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomImage(
                      path: RemoteUrls.imageUrl(aboutInfo.aboutUsModel!.bannerImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Html(
                    data: aboutInfo.aboutUsModel!.aboutUs,
                    style: {
                      'h1': Style(
                        maxLines: 2,
                        margin: Margins.symmetric(horizontal: 0),
                        color: Colors.black,
                        textOverflow: TextOverflow.ellipsis,
                        fontSize: FontSize.xLarge,
                        padding: HtmlPaddings.zero,
                      ),
                      'li': Style(margin: Margins.zero),
                      'ul': Style(
                        margin: Margins.only(top: 14),
                        color: Colors.grey.shade600,
                        listStyleType: ListStyleType.none,
                      ),
                      'p': Style(
                        lineHeight: LineHeight.number(1.6),
                        textAlign: TextAlign.justify,
                        margin: Margins.only(top: 4.0),
                        fontSize: FontSize.medium,
                        color: Colors.grey.shade600,
                      ),
                    },
                  ),
                ],
                if (aboutInfo.testimonials.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    "Customer Reviews",
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: aboutInfo.testimonials.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final result = aboutInfo.testimonials[index];
                        final countRating = int.tryParse(result.rating) ?? 0;
                        return _buildTestimonialCard(result, countRating);
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 40),
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

  Widget _buildIntro(String icon, String title) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          margin: const EdgeInsets.only(bottom: 8),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: FaIcon(icon, color: Colors.white, size: 18),
        ),
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTestimonialCard(dynamic result, int countRating) {
    final imageUrl = result.image ?? '';
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(
                countRating,
                (_) => const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
              ),
              const SizedBox(width: 4),
              Text('(${result.rating})', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              result.comment,
              overflow: TextOverflow.ellipsis,
              maxLines: 6,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: imageUrl.isNotEmpty
                    ? NetworkImage(RemoteUrls.imageUrl(imageUrl))
                    : null,
                onBackgroundImageError: imageUrl.isNotEmpty ? (_, __) {} : null,
                child: imageUrl.isEmpty
                    ? const Icon(Icons.person, size: 18, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
                    Text(result.designation, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500)),
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
