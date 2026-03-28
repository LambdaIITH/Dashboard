import 'package:dashbaord/extensions.dart';
import 'package:dashbaord/models/announcement_model.dart';
import 'package:dashbaord/widgets/announcement_card.dart';
import 'package:dashbaord/widgets/announcement_scroll_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dashbaord/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dashbaord/utils/loading_widget.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final ApiServices apiServices = ApiServices();
  List<String> _highlightedFilterOptions = ['All'];
  final List<String> _filterOptions = ['All', 'Unread', 'Important'];
  final List<String> tags = [
    'All',
    'Courses',
    'Admin',
    'Mess',
    'Scholarship',
    'ERP',
    'OCS',
    'Talks',
    'Transport',
    'Hostel Office',
    'Director',
    'Tag A',
    'Tag B',
    'Tag C',
    'Tag D',
  ];
  List<String> selectedTags = ['All'];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int _selectedChipIndex = 0;
  int _filterOptionChipIndex = 0;
  int limit = 10;
  int offset = 0;
  bool isSearching = false;
  bool isLoading = false;
  bool loadedAll = false;
  bool _isFilterExpanded = false;
  late FocusNode _searchFocusNode;
  List<AnnouncementModel> announcements = [];

  void showError({String? msg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg ?? 'Please login to use this feature'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> fetchAnnouncements() async {
    if (loadedAll || isLoading) return;

    setState(() {
      isLoading = true;
    });

    final response = await ApiServices().getAnnouncements(limit, offset);
    final tags = await ApiServices().getAnnouncementsTags();

    if (tags == null) {
      debugPrint('Error: Could not fetch filters');
    } else {
      _highlightedFilterOptions = tags;
    }

    if (response == null) {
      setState(() {
        loadedAll = true;
      });
    } else {
      setState(() {
        announcements.addAll(response);
        offset += 10;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
    _searchFocusNode = FocusNode();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        fetchAnnouncements();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double topChipsHeight = 60.0;
    double extraHeight = (_isFilterExpanded) ? 487.0 : 0;
    final double appBarBottomHeight = topChipsHeight + extraHeight;
    final double totalAppBarHeight = kToolbarHeight + appBarBottomHeight;
    final double appBarBottomMaxHeight = topChipsHeight + extraHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: context.customColors.customAccentColor,
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        leadingWidth: isSearching ? 0 : 20,
        title: isSearching
            ? AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: isSearching
                    ? MediaQuery.of(context).size.width - 78
                    : MediaQuery.of(context).size.width - 40,
                curve: Curves.easeInOut,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 0, 2, 0),
                  child: TextField(
                    cursorColor: context.customColors.customAccentColor,
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search, color: Colors.grey[400]),
                        onPressed: () {
                          setState(() {
                            isSearching = !isSearching;
                          });
                        },
                      ),
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              )
            : Text(
                "Announcements",
                style: GoogleFonts.outfit(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                isSearching ? Icons.close : Icons.search,
                color: context.customColors.customAccentColor,
                size: 28,
              ),
              onPressed: () {
                setState(() {
                  isSearching = !isSearching;
                });
                _searchFocusNode.requestFocus();
                if (isSearching) {
                  _searchController.clear();
                }
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(appBarBottomMaxHeight),
          child: Container(
            height: appBarBottomMaxHeight,
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: Row(children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 5, 8, 5),
                    child: Row(
                      children: List.generate(
                        _filterOptions.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: _filterOptionChipIndex == index,
                            label: Text(_filterOptions[index]),
                            onSelected: (bool selected) {
                              setState(() {
                                _filterOptionChipIndex = selected ? index : 0;
                              });
                            },
                            selectedColor: const Color.fromRGBO(237, 90, 36, 1),
                            showCheckmark: false,
                            labelStyle: const TextStyle(color: Colors.white),
                            backgroundColor: const Color.fromRGBO(48, 48, 48, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _isFilterExpanded,
                      label: Icon(CupertinoIcons.slider_horizontal_3),
                      onSelected: (bool selected) {
                        setState(() {
                          _isFilterExpanded = !_isFilterExpanded;
                        });
                      },
                      selectedColor: const Color.fromRGBO(237, 90, 36, 1),
                      showCheckmark: false,
                      labelStyle: const TextStyle(color: Colors.white),
                      backgroundColor: const Color.fromRGBO(48, 48, 48, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ])),
                ClipRect(
                  child: AnimatedSlide(
                    offset: Offset(0, _isFilterExpanded ? 0.0 : -1.0),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: AnimatedOpacity(
                      opacity: _isFilterExpanded ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: SizedBox(
                        height: extraHeight,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius:
                                  const BorderRadius.vertical(bottom: Radius.circular(16)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                const Center(
                                  child: Text(
                                    'Filters',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Padding(
                                  padding: EdgeInsets.only(left: 30.0),
                                  child: Text(
                                    'Categories',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _highlightedFilterOptions.map((category) {
                                      final isSelected = _selectedChipIndex ==
                                          _highlightedFilterOptions.indexOf(category);

                                      return FilterChip(
                                        label: Text(category),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedChipIndex =
                                                _highlightedFilterOptions.indexOf(category);
                                          });
                                        },
                                        backgroundColor: const Color(0xFF2A2A2A),
                                        selectedColor: const Color(0xFFFF5722),
                                        checkmarkColor: Colors.transparent,
                                        showCheckmark: false,
                                        labelStyle: TextStyle(
                                          color: isSelected ? Colors.white : Colors.white70,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Padding(
                                  padding: EdgeInsets.only(left: 30.0),
                                  child: Text(
                                    'Tags',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 140,
                                  child: ScrollConfiguration(
                                    behavior: CustomScrollBehavior(),
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: tags.map((tag) {
                                            final isSelected = selectedTags.contains(tag);
                                            return FilterChip(
                                              label: Text(tag),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                setState(() {
                                                  if (tag == 'All') {
                                                    selectedTags = ['All'];
                                                  } else {
                                                    selectedTags.remove('All');
                                                    if (selected) {
                                                      selectedTags.add(tag);
                                                    } else {
                                                      selectedTags.remove(tag);
                                                    }
                                                    if (selectedTags.isEmpty) {
                                                      selectedTags = ['All'];
                                                    }
                                                  }
                                                });
                                              },
                                              backgroundColor: const Color(0xFF2A2A2A),
                                              selectedColor: const Color(0xFFFF5722),
                                              checkmarkColor: Colors.transparent,
                                              showCheckmark: false,
                                              labelStyle: TextStyle(
                                                color: isSelected ? Colors.white : Colors.white70,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isFilterExpanded = false;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 16),
                                      padding: const EdgeInsets.all(12),
                                      child: const Icon(
                                        Icons.close,
                                        color: Color(0xFFFF5722),
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + totalAppBarHeight,
        ),
        curve: Curves.easeInOut,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: announcements.length + 1,
          itemBuilder: (context, index) {
            if (index < announcements.length) {
              final announcement = announcements[index];
              if (_highlightedFilterOptions[_selectedChipIndex] != 'All') {
                if (!announcement.tags.contains(_highlightedFilterOptions[_selectedChipIndex])) {
                  return const SizedBox.shrink();
                }
              }
              if (!selectedTags.contains('All')) {
                if (!announcement.tags.any((element) => selectedTags.contains(element))) {
                  return const SizedBox.shrink();
                }
              }

              return AnnouncementCard(
                image: announcement.imageUrl,
                source: announcement.createdBy,
                date: announcement.createdAt.toString(),
                title: announcement.title,
                description: announcement.description,
                tags: announcement.tags,
                id: announcement.id,
              );
            } else if (isLoading) {
              return const Center(
                child: CustomLoadingIndicator(width: 80, height: 80),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
