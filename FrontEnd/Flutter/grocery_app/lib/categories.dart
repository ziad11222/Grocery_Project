import 'package:flutter/material.dart';
import 'details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? FilterValue = 'Chosse Filter';
  String? priceRangeValue = 'Price Range';
  String? BrandValue = 'Brand';
  String? nationalityValue = 'Nationality';
  List<search_product> products = [];
  String? search_name;
  List list = [];
  bool priceFilter = false;
  bool nationalityFilter = false;
  bool brandFilter = false;
  List<String> brands = ['Brand'];
  List<String> nations = ['Nationality'];
  List<filter_product> productsByBrands = [];
  List<filter_product> productsByprices = [];
  bool searchIsCalled = false;
  bool filterIsCalled = false;
  List<filter_nation> productsByNations = [];
  String? price1;
  String? price2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
                    onChanged: (value) {
                      setState(() {
                        products = [];
                        filterIsCalled = false;
                        productsByBrands = [];
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        searchIsCalled = true;
                        filterIsCalled = false;
                        search_name = value;
                        get_search(search_name!);
                      });
                    },
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
                    value: FilterValue,
                    icon: Icon(Icons.arrow_drop_down),
                    items: <String>[
                      'Chosse Filter',
                      'Filter by price',
                      'Filter by Nationality',
                      'Filter brand'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        FilterValue = newValue;
                        if (newValue == 'Filter by price') {
                          nationalityFilter = false;
                          priceFilter = true;
                          brandFilter = false;
                          productsByBrands = [];
                          productsByNations = [];
                        } else if (newValue == 'Filter by Nationality') {
                          nationalityFilter = true;
                          priceFilter = false;
                          brandFilter = false;
                          productsByBrands = [];
                          productsByprices = [];
                        } else if (newValue == 'Filter brand') {
                          nationalityFilter = false;
                          priceFilter = false;
                          brandFilter = true;
                          productsByNations = [];
                          productsByprices = [];
                        }
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                SizedBox(width: 16),
                SizedBox(width: 16),
                nationalityFilter
                    ? Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: nationalityValue,
                          icon: Icon(Icons.arrow_drop_down),
                          items: nations.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              nationalityValue = newValue;
                              filterIsCalled = true;
                              searchIsCalled = false;
                              searchByFilterNationality(newValue!);
                              productsByNations = [];

                              productsByBrands = [];
                            });
                          },
                        ),
                      )
                    : priceFilter
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                  width: 50,
                                  child: TextField(onChanged: (value) {
                                    setState(() {
                                      price1 = value;
                                    });
                                  },
                                    decoration: InputDecoration(
                                        hintStyle: TextStyle(fontSize: 12),
                                        hintText: 'Price 1 '),
                                  )),
                              SizedBox(
                                width: 30,
                              ),
                              Container(
                                  width: 50,
                                  child: TextField(onSubmitted: (value) {
                                    setState(() {
                                      price2 = value;
                                      searchByFilterprice(price1! , price2!);
                                      searchIsCalled = false;
                                      filterIsCalled = true;
                                      productsByBrands = [];
                                      productsByNations = [];
                                      productsByprices = [];

                                    });
                                  },
                                    decoration: InputDecoration(
                                        hintStyle: TextStyle(fontSize: 12),
                                        hintText: 'Price 2'),
                                  ))
                            ],
                          )
                        : brandFilter
                            ? Expanded(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: BrandValue,
                                  icon: Icon(Icons.arrow_drop_down),
                                  items: brands.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      filterIsCalled = true;
                                      searchIsCalled = false;

                                      BrandValue = newValue;
                                      productsByBrands = [];
                                      productsByNations = [];

                                      searchByFilterBrand(newValue!);
                                      print(
                                          '---------------------------------');
                                      print(productsByBrands.length);
                                      print(
                                          '---------------------------------');
                                    });
                                  },
                                ),
                              )
                            : SizedBox.shrink(),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Flexible(
            child: _widget(),
          )
        ],
      ),
    ));
  }

  Widget _widget() {
    if (searchIsCalled) {
      return ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          separatorBuilder: (BuildContext, int i) {
            return SizedBox(width: 10);
          },
          itemCount: products == null ? 0 : products.length,
          itemBuilder: (context, int i) {
            return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return details();
                  }));
                },
                child: Stack(
                  children: [
                    Container(
                      height: 300,
                      width: 400,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Padding(
                        padding: EdgeInsets.only(top: 3, right: 3, left: 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                height: 200,
                                width: 600,
                                '${products[i].image}',
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                                style: TextStyle(fontWeight: FontWeight.bold),
                                '${products[i].name}'),
                            SizedBox(
                              height: 3,
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black),
                                "${products[i].brand}"),
                            Row(
                              children: [
                                Text(
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                    "\$${products[i].price}"),
                                SizedBox(
                                  width: 300,
                                ),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.green),
                                  child: Icon(
                                      color: Colors.white,
                                      Icons.add_shopping_cart_rounded),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ));
          });
    } else if (filterIsCalled) {
      return ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          separatorBuilder: (BuildContext, int i) {
            return SizedBox(width: 10);
          },
          itemCount: brandFilter
              ? productsByBrands.length
              : nationalityFilter
                  ? productsByNations.length
                  : priceFilter
                      ? productsByprices.length
                      : 0,
          itemBuilder: (context, int i) {
            return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return details();
                  }));
                },
                child: Stack(
                  children: [
                    Container(
                      height: 300,
                      width: 400,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Padding(
                        padding: EdgeInsets.only(top: 3, right: 3, left: 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                height: 200,
                                width: 600,
                                brandFilter
                                    ? '${productsByBrands[i].image}'
                                    : priceFilter
                                        ? '${productsByprices[i].image}'
                                        : '${productsByNations[i].image}',
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                                style: TextStyle(fontWeight: FontWeight.bold),
                                brandFilter
                                    ? '${productsByBrands[i].name}'
                                    : priceFilter
                                        ? '${productsByprices[i].name}'
                                        : '${productsByNations[i].name}'),
                            SizedBox(
                              height: 3,
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black),
                                brandFilter
                                    ? "${productsByBrands[i].brand}"
                                    : priceFilter
                                        ? '${productsByprices[i].brand}'
                                        : '${productsByNations[i].brand}'),
                            Row(
                              children: [
                                Text(
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                    brandFilter
                                        ? "\$${productsByBrands[i].price}"
                                        : priceFilter
                                            ? '\$${productsByprices[i].price}'
                                            : "\$${productsByNations[i].price}"),
                                SizedBox(
                                  width: 300,
                                ),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.green),
                                  child: Icon(
                                      color: Colors.white,
                                      Icons.add_shopping_cart_rounded),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ));
          });
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  void initState() {
    get_homepage();
  }

  Future<void> get_search(String name) async {
    http.Response response =
        await http.get(Uri.parse('http://34.31.110.154/getBySearch?q=$name'));
    list = jsonDecode(response.body);
    print('----------------------------------');
    print(list);
    print('----------------------------------');
    setState(() {
      for (int i = 0; i < list.length; i++) {
        search_product product = search_product.fromjson(list[i]);
        products.add(product);
      }
    });
  }

  Future<void> get_homepage() async {
    http.Response response =
        await http.get(Uri.parse('http://34.31.110.154/getAllProduct'));
    List list = json.decode(response.body);
    setState(() {
      Set<String> uniqueNationalities = Set<String>();
      Set<String> uniqueBrands = Set<String>();
      uniqueNationalities.add('Nationality');
      uniqueBrands.add('Brand');
      for (int i = 0; i < list.length; i++) {
        
        uniqueNationalities.add(list[i]['nationality']);
        uniqueBrands.add(list[i]['Brand']);
      }
      nations = List<String>.from(uniqueNationalities);
      brands = List<String>.from(uniqueBrands);
    });
  }

  Future<void> searchByFilterBrand(String brandName) async {
    http.Response response = await http.get(
        Uri.parse('http://34.31.110.154/filterByBrand?brandName=$brandName'));
    List Brands_list = jsonDecode(response.body);
    setState(() {
      for (int i = 0; i < Brands_list.length; i++) {
        filter_product productByBrand = filter_product.fromjson(Brands_list[i]);
        productsByBrands.add(productByBrand);
      }
    });
  }

  Future<void> searchByFilterNationality(String nation) async {
    http.Response response = await http.get(Uri.parse(
        'http://34.31.110.154//filterByNationality?nationality=$nation'));
    List nations_list = jsonDecode(response.body);
    setState(() {
      for (int i = 0; i < nations_list.length; i++) {
        filter_nation productBynaton = filter_nation.fromjson(nations_list[i]);
        productsByNations.add(productBynaton);
      }
    });
  }

  Future<void> searchByFilterprice(String price1, String price2) async {
    http.Response response = await http.get(Uri.parse(
        'http://34.31.110.154/filterByPrice?from=$price1&to=$price2'));
    List prices_list = jsonDecode(response.body);
    setState(() {
      for (int i = 0; i < prices_list.length; i++) {
        filter_product productByprice = filter_product.fromjson(prices_list[i]);
        productsByprices.add(productByprice);
      }
    });
  }
}

class search_product {
  String? name;
  String? brand;
  int? price;
  String? image;

  search_product.fromjson(Map<String, dynamic> list) {
    name = list['product_name'];
    brand = list['brand'];
    price = list['price'];
    image = list['image'];
  }
}

class filter_product {
  String? name;
  String? brand;
  int? price;
  String? image;

  filter_product.fromjson(Map<String, dynamic> Brands_list) {
    name = Brands_list['product_name'];
    brand = Brands_list['brand'];
    price = Brands_list['price'];
    image = Brands_list['image'];
  }
}

class filter_nation {
  String? name;
  String? brand;
  int? price;
  String? image;

  filter_nation.fromjson(Map<String, dynamic> nations_list) {
    name = nations_list['product_name'];
    brand = nations_list['brand'];
    price = nations_list['price'];
    image = nations_list['image'];
  }
}
