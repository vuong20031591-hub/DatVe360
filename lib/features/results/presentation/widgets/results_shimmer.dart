import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_constants.dart';

class ResultsShimmer extends StatelessWidget {
  const ResultsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: Shimmer.fromColors(
              baseColor: theme.colorScheme.surface,
              highlightColor: theme.colorScheme.onSurface.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Logo placeholder
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Content placeholder
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time row
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 50,
                                    height: 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Route and duration
                              Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 60,
                                    height: 16,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Price placeholder
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 80,
                              height: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 30,
                              height: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Carrier info
                    Row(
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          color: Colors.white,
                        ),
                        const Spacer(),
                        Container(
                          width: 60,
                          height: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
