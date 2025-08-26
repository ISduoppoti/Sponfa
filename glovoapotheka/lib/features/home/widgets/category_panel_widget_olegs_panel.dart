import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Data class for category information
class CategoryData {
  final String svgPath;
  final List<String> subcategories;
  
  CategoryData({
    required this.svgPath,
    required this.subcategories,
  });
}

class CategorySelectorOleg extends StatefulWidget {
  final Function(String category, String? subcategory)? onSelectionChanged;
  
  const CategorySelectorOleg({
    Key? key,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<CategorySelectorOleg> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelectorOleg>
    with TickerProviderStateMixin {
  int selectedCategoryIndex = 0;
  String? selectedSubcategory;
  int? hoveredButtonIndex;

  final Map<String, CategoryData> categoriesData = {
    'Electronics': CategoryData(
      svgPath: 'assets/images/orange_pill.svg', // Replace with your SVG path
      subcategories: ['Smartphones', 'Laptops', 'Headphones', 'Gaming'],
    ),
    'Fashion': CategoryData(
      svgPath: 'assets/images/child_care.svg', // Replace with your SVG path
      subcategories: ['Men\'s Clothing', 'Women\'s Clothing', 'Shoes', 'Accessories'],
    ),
    'Home & Garden': CategoryData(
      svgPath: 'assets/images/dermo_face_care.svg', // Replace with your SVG path
      subcategories: ['Furniture', 'Kitchen', 'Garden Tools', 'Decor'],
    ),
    'Sports': CategoryData(
      svgPath: 'assets/images/doctor_shit.svg', // Replace with your SVG path
      subcategories: ['Fitness', 'Outdoor Sports', 'Team Sports', 'Water Sports'],
    ),
    'Books': CategoryData(
      svgPath: 'assets/images/green_pill.svg', // Replace with your SVG path
      subcategories: ['Fiction', 'Non-Fiction', 'Educational', 'Comics'],
    ),
    'Automotive': CategoryData(
      svgPath: 'assets/images/poll.svg', // Replace with your SVG path
      subcategories: ['Car Parts', 'Motorcycles', 'Tools', 'Accessories'],
    ),
    'Health': CategoryData(
      svgPath: 'assets/images/sport.svg', // Replace with your SVG path
      subcategories: ['Supplements', 'Medical Devices', 'Personal Care', 'Fitness'],
    ),
    'Toys': CategoryData(
      svgPath: 'assets/images/travma.svg', // Replace with your SVG path
      subcategories: ['Educational Toys', 'Action Figures', 'Board Games', 'Outdoor Toys'],
    ),
  };

  List<String> get categories => categoriesData.keys.toList();
  List<String> get currentSubcategories => 
      categoriesData[categories[selectedCategoryIndex]]?.subcategories ?? [];
  String get currentSvgPath => 
      categoriesData[categories[selectedCategoryIndex]]?.svgPath ?? '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _selectCategory(int index) {
    setState(() {
      selectedCategoryIndex = index;
      selectedSubcategory = null; // Reset subcategory selection
    });
    
    widget.onSelectionChanged?.call(categories[index], null);
  }

  void _selectSubcategory(String subcategory) {
    setState(() {
      selectedSubcategory = subcategory;
    });
    
    widget.onSelectionChanged?.call(categories[selectedCategoryIndex], subcategory);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 768;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Panel - Categories
        Expanded(
          flex: 1,
          child: Container(
            height: 620, // Height to fit all 4 rows (4 * 100px + spacing)
            child: _buildCategoryGrid(false),
          ),
        ),
        const SizedBox(width: 16),
        // Right Panel - Subcategories
        Expanded(
          flex: 5,
          child: Container(
            height: 620, // Same height as left panel
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: _buildSubcategorySection(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildCategoryGrid(true),
        if (selectedSubcategory != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              'Selected: ${categories[selectedCategoryIndex]} > $selectedSubcategory',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryGrid(bool isMobile) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0, // Perfect square for 100x100 icons
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryButton(index, isMobile);
      },
    );
  }

  Widget _buildCategoryButton(int index, bool isMobile) {
    bool isSelected = selectedCategoryIndex == index;
    bool isHovered = hoveredButtonIndex == index;
    String svgPath = categoriesData[categories[index]]?.svgPath ?? '';
    

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredButtonIndex = index),
      onExit: (_) => setState(() => hoveredButtonIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(isHovered ? 1.1 : 1.0),
        child: GestureDetector(
          onTap: () {
            _selectCategory(index);
            if (isMobile) {
              _showSubcategoryModal(context);
            }
          },
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange.shade300 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected ? Border.all(color: Colors.orange.shade500, width: 2) : null,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SvgPicture.asset( // Change `Image.asset` to `SvgPicture.asset`
                    svgPath,
                    width: 150,
                    height: 150,
                  ),
                ),
                Text(
                  categories[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.orange.shade800 : Colors.orange.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ]
            )
          ),
        ),
      ),
    );
  }

  Widget _buildSubcategorySection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categories[selectedCategoryIndex],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: currentSubcategories.map((subcategory) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildSubcategoryButton(subcategory),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryButton(String subcategory) {
    bool isSelected = selectedSubcategory == subcategory;
    
    return GestureDetector(
      onTap: () => _selectSubcategory(subcategory),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange.shade300 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.orange.shade500 : Colors.orange.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade200.withOpacity(0.3),
                blurRadius: isSelected ? 4 : 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            subcategory,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.orange.shade800 : Colors.orange.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showSubcategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              width: double.infinity,
              child: Text(
                categories[selectedCategoryIndex],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3,
                ),
                itemCount: currentSubcategories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _selectSubcategory(currentSubcategories[index]);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Center(
                        child: Text(
                          currentSubcategories[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}