import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';
import '../cubits/article/article_cubit.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key});

  Future<void> _openDetail(BuildContext context, ArticleItem article) async {
    final favoriteResult = await context.push<bool>(
      '/articles/${article.id}',
      extra: article,
    );

    if (favoriteResult != null && context.mounted) {
      await context
          .read<ArticleCubit>()
          .setFavorite(article.id, favoriteResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticleCubit, ArticleState>(
      builder: (context, state) {
        if (state.status == ArticleStatus.loading ||
            state.status == ArticleStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }

        return PageWidth(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SectionTitle(
                'Artikel Kesehatan',
                subtitle:
                    'Detail menggunakan data transit; status favorit dikembalikan melalui await context.push<T>().',
              ),
              ...state.articles.map(
                (article) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Stack(
                    children: [
                      ArticleTile(
                        article: article,
                        onTap: () => _openDetail(context, article),
                      ),
                      if (state.isFavorite(article.id))
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.favorite,
                              size: 18,
                              color: AppColors.pink,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
