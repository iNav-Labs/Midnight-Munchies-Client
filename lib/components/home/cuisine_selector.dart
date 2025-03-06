import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategorySelector extends StatefulWidget {
  const CategorySelector({super.key});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _categories = [
    {
      'name': 'Chicken',
      'image': 'https://static.vecteezy.com/system/resources/previews/055/240/717/non_2x/delicious-chicken-dish-presentation-on-transparent-background-png.png',
    },
    {
      'name': 'Burger',
      'image': 'https://static.vecteezy.com/system/resources/previews/032/508/308/non_2x/a-tempting-burger-on-a-plate-isolated-on-a-transparent-background-fresh-tasty-and-appetizing-with-delicious-layers-ai-generative-free-png.png',
    },
    {
      'name': 'Pasta',
      'image': 'https://png.pngtree.com/png-vector/20241018/ourmid/pngtree-pasta-dishes-png-image_13536010.png',
    },
    {
      'name': 'Deserts',
      'image': 'https://png.pngtree.com/png-vector/20231015/ourmid/pngtree-chocolate-brownie-png-png-image_10163263.png',
    },
    {
      'name': 'Nasto',
      'image': 'https://png.pngtree.com/png-clipart/20230506/ourmid/pngtree-indian-samosa-png-image_7086113.png',
    },
  
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 90,
              height: 110,
              child: Container(
                width: 90,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Inner Container with Image
                    Container(
                      width: 75,
                      height: 75,
                   
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _categories[index]['image']!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / 
                                      loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Category Name
                    Text(
                      _categories[index]['name']!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF6552FF) : Colors.black87,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



