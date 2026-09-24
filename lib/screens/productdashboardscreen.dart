import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../data/productdata.dart';

class ProductDashboardScreen extends StatefulWidget {
  const ProductDashboardScreen({super.key});

  @override
  State<ProductDashboardScreen> createState() => _ProductDashboardScreenState();
}

class _ProductDashboardScreenState extends State<ProductDashboardScreen> {
  int touchedIndex = -1;
  bool isSquare = true;
  double size = 16;
  final CarouselController controller = CarouselController(initialItem: 1);
  final SearchController searchController = SearchController();
  List<Map<String, Object>> allProducts = products;

  void searchProducts(String enteredKeyword) {
    List<Map<String, Object>> results = [];

    if (enteredKeyword.isEmpty) {
      // If the search field is empty, bring back all items
      results = products;
    } else {
      // Filter by matching substrings
      results = products
          .where(
            (product) => product['productName']
                .toString()
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()),
          )
          .toList();
    }

    // Update the UI
    setState(() {
      products = results;
    });
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      return switch (i) {
        0 => PieChartSectionData(
          color: Colors.blue,
          value: 40,
          title: '40%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            shadows: shadows,
          ),
        ),
        1 => PieChartSectionData(
          color: Colors.green,
          value: 30,
          title: '30%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.green,
            shadows: shadows,
          ),
        ),
        2 => PieChartSectionData(
          color: Colors.red,
          value: 15,
          title: '15%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.red,
            shadows: shadows,
          ),
        ),
        _ => throw StateError('Invalid'),
      };
    });
  }

  List<PieChartSectionData> sections() {
    double index = 0;
    return products.map((element) {
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      index += 1;
      double vegetable = 0.0;
      double fruit = 0.0;
      double processed = 0.0;
      if (element['productType'] == 'vegetable') {
        vegetable++;
      }
      if (element['productType'] == 'fruit') {
        fruit++;
      }
      if (element['productType'] == 'processed') {
        processed++;
      }
      var items = [vegetable, fruit, processed];
      var newsum = 0.0;
      items.fold(0.0, (previous, sum) {
        newsum = previous + sum;
        return newsum;
      });
      print(newsum);
      return PieChartSectionData(
        color: element['productType'] == 'vegetable'
            ? Colors.green
            : element['productType'] == 'processed'
            ? Colors.purple
            : Colors.blue,
        value: element['productType'] == 'fruit'
            ? fruit
            : element['productType'] == 'vegetable'
            ? vegetable
            : element['productType'] == 'processed'
            ? processed
            : 0.0,
        title: element['productType'] == 'processed'
            ? ((processed / element.length) * 100).toStringAsFixed(1)
            : element['productType'] == 'fruit'
            ? ((fruit / element.length) * 100).toStringAsFixed(1)
            : element['productType'] == 'vegetable'
            ? ((vegetable / element.length) * 100).toStringAsFixed(1)
            : element.length.toString(),
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('create product'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pushNamed(context, '/CreateProductScreen');
              },
            ),
            ListTile(
              title: const Text('product dashboard'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pushNamed(context, '/ProductDashboardScreen');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "product dashboard",
                style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * .6,
                  minWidth: MediaQuery.sizeOf(context).width * .3,
                ),
                child: ScrollConfiguration(
                  behavior: MyCustomScrollBehavior(),
                  child: CarouselView.weighted(
                    backgroundColor: Colors.black12,
                    controller: controller,
                    itemSnapping: true,
                    flexWeights: const <int>[1, 7, 1],
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {
                                        setState(() {
                                          if (!event
                                                  .isInterestedForInteractions ||
                                              pieTouchResponse == null ||
                                              pieTouchResponse.touchedSection ==
                                                  null) {
                                            touchedIndex = -1;
                                            return;
                                          }
                                          touchedIndex = pieTouchResponse
                                              .touchedSection!
                                              .touchedSectionIndex;
                                        });
                                      },
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 10,
                                centerSpaceRadius: 50,
                                sections: sections(),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      shape: isSquare
                                          ? BoxShape.rectangle
                                          : BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'fruit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      shape: isSquare
                                          ? BoxShape.rectangle
                                          : BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'vegetable',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      shape: isSquare
                                          ? BoxShape.rectangle
                                          : BoxShape.circle,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'processed',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                            ],
                          ),
                          SizedBox(width: 30),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {
                                        setState(() {
                                          if (!event
                                                  .isInterestedForInteractions ||
                                              pieTouchResponse == null ||
                                              pieTouchResponse.touchedSection ==
                                                  null) {
                                            touchedIndex = -1;
                                            return;
                                          }
                                          touchedIndex = pieTouchResponse
                                              .touchedSection!
                                              .touchedSectionIndex;
                                        });
                                      },
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 10,
                                centerSpaceRadius: 50,
                                sections: sections(),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      shape: isSquare
                                          ? BoxShape.rectangle
                                          : BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'fruit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      shape: isSquare
                                          ? BoxShape.rectangle
                                          : BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'vegetable',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      shape: isSquare
                                          ? BoxShape.rectangle
                                          : BoxShape.circle,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'processed',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                            ],
                          ),
                          SizedBox(width: 30),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {
                                        setState(() {
                                          if (!event
                                                  .isInterestedForInteractions ||
                                              pieTouchResponse == null ||
                                              pieTouchResponse.touchedSection ==
                                                  null) {
                                            touchedIndex = -1;
                                            return;
                                          }
                                          touchedIndex = pieTouchResponse
                                              .touchedSection!
                                              .touchedSectionIndex;
                                        });
                                      },
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 10,
                                centerSpaceRadius: 50,
                                sections: sections(),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      shape: isSquare
                                          ? BoxShape.rectangle
                                          : BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'fruit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      shape: isSquare
                                          ? BoxShape.rectangle
                                          : BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'vegetable',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      shape: isSquare
                                          ? BoxShape.rectangle
                                          : BoxShape.circle,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'processed',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                            ],
                          ),
                          SizedBox(width: 30),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: SearchAnchor(
                viewOnSubmitted: (_) {
                  setState(() {
                    products = allProducts;
                  });
                  searchProducts(searchController.text);
                  searchController.closeView(searchController.text);
                },
                searchController: searchController,
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    onTap: () {
                      controller.openView();
                    },
                    leading: Icon(Icons.search),
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                      return products.map((item) {
                        return ListTile(
                          title: Text(item['productName'].toString()),
                          onTap: () {
                            setState(() {
                              products = allProducts;
                              searchProducts(item['productName'].toString());
                              controller.closeView(
                                item['productName'].toString(),
                              );
                            });
                          },
                        );
                      });
                    },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                bottom: 16.0,
                right: 72.0,
                left: 48.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 50),
                child: ScrollConfiguration(
                  behavior: MyCustomScrollBehavior(),
                  child: CarouselView.weighted(
                    flexWeights: const <int>[1, 2, 3, 2, 1],
                    consumeMaxWeight: false,
                    children: List<Widget>.generate(20, (int index) {
                      return ColoredBox(
                        color: Colors.primaries[index % Colors.primaries.length]
                            .withValues(alpha: 0.8),
                        child: const SizedBox.expand(),
                      );
                    }),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 32.0,
                horizontal: 48.0,
              ),
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * .66,
                child: ListView.builder(
                  padding: EdgeInsets.only(right: 24.0),
                  itemCount: products.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ExpansionTile(
                        leading: Text(
                          softWrap: true,
                          products[index]['productID'].toString(),
                        ),
                        title: Text(products[index]['productType'].toString()),
                        subtitle: Text(
                          products[index]['productName'].toString(),
                        ),
                        trailing: Column(
                          children: [
                            Text('quantity'),
                            Text(products[index]['quantity'].toString()),
                          ],
                        ),
                        children: [
                          Card(
                            child: Image.asset(
                              'assets/shampoo.png',
                              width: 330,
                              height: 130,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'id',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(products[index]['productID'].toString()),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'product name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(products[index]['productName'].toString()),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'quantity',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(products[index]['quantity'].toString()),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'price',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(products[index]['price'].toString()),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'product type',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(products[index]['productType'].toString()),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'date of manufacture',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                products[index]['dateOfManufacture'].toString(),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'date of expiry',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(products[index]['dateOfExpiry'].toString()),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'discount allowed',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                products[index]['discountAllowed'].toString(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse, // <-- This enables mouse dragging
  };
}
