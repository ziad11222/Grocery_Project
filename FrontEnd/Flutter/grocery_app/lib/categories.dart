import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? brandValue = 'Brand Name';
  String? priceRangeValue = 'Price Range';
  String? categoryValue = 'Category';
  String? nationalityValue = 'Nationality';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          margin: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          padding: const EdgeInsets.fromLTRB(8, 2, 6, 2),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    hintText: 'Search Groceries',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: brandValue,
                  icon: Icon(Icons.arrow_drop_down),
                  items: <String>['Brand Name', 'Brand 1', 'Brand 2', 'Brand 3'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      brandValue = newValue;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: priceRangeValue,
                  icon: Icon(Icons.arrow_drop_down),
                  items: <String>['Price Range', 'Range 1', 'Range 2', 'Range 3'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      priceRangeValue = newValue;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: categoryValue,
                  icon: Icon(Icons.arrow_drop_down),
                  items: <String>['Category', 'Category A', 'Category B', 'Category C'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      categoryValue = newValue;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: nationalityValue,
                  icon: Icon(Icons.arrow_drop_down),
                  items: <String>['Nationality', 'Nationality 1', 'Nationality 2', 'Nationality 3'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      nationalityValue = newValue;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}