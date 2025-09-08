/* import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:jewellery_diamond/core/layout/base_layout.dart';
import 'package:jewellery_diamond/widgets/sized_box_widget.dart';

import '../../../data/models/product_model.dart';
import '../product_list_page/widgets/product_grid_widget.dart';

class BackupProductDetailPage extends StatefulWidget {
  static const String routeName = '/Details';

  const BackupProductDetailPage({super.key});

  @override
  State<BackupProductDetailPage> createState() => _BackupProductDetailPageState();
}

class _BackupProductDetailPageState extends State<BackupProductDetailPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return BaseLayout(
      // backgroundColor: Colors.white,
      key: scaffoldKey,
      body: Builder(builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              children: [
                custSpace50Y,
                const ProductDetailContent(),
                custSpace50Y,
                _buildProductRelatedGrid(sampleProducts[0]),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProductRelatedGrid(Product product) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Related Product',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 26! * 0.9,
                ),
          ),
          const Divider(height: 30, color: Colors.black26),
          custSpace30Y,
          SizedBox(
            height: 350,
            child: ProductGrid(
              products:
                  sampleProducts.where((p) => p.id != product.id).toList(),
              isHorzontal: true, wishlistProducts: [],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductDetailContent extends StatefulWidget {
  const ProductDetailContent({super.key});

  @override
  ProductDetailContentState createState() => ProductDetailContentState();
}

class ProductDetailContentState extends State<ProductDetailContent> {
  bool mouseHoverC = false;
  bool mouseHoverR = false;
  bool mouseHoverF = false;
  bool mouseHoverS = false;
  bool isHovering = false;
  Offset? _pointerOffset;
  bool _hovering = false;
  final GlobalKey _imageKey = GlobalKey();

  final double zoomScale = 2.5;
  final double zoomWindowSize = 350;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: MouseRegion(
            onEnter: (_) {
              setState(() {
                _hovering = true;
              });
            },
            onExit: (_) {
              setState(() {
                _hovering = false;
                _pointerOffset = null;
              });
            },
            onHover: (event) {
              final box =
                  _imageKey.currentContext?.findRenderObject() as RenderBox?;
              if (box != null) {
                final localPos = box.globalToLocal(event.position);
                setState(() {
                  _pointerOffset = localPos;
                });
              }
            },
            child: Stack(
              children: [
                Image.asset(
                  "assets/images/others/01.webp",
                  key: _imageKey,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                if (_hovering && _pointerOffset != null)
                  Builder(builder: (context) {
                    final box = _imageKey.currentContext?.findRenderObject()
                        as RenderBox?;
                    if (box == null) return const SizedBox();
                    final imageSize = box.size;
                    final zoomAreaSize = zoomWindowSize / zoomScale;
                    double clipX = _pointerOffset!.dx - zoomAreaSize / 2;
                    double clipY = _pointerOffset!.dy - zoomAreaSize / 2;
                    clipX = clipX.clamp(0.0, imageSize.width - zoomAreaSize);
                    clipY = clipY.clamp(0.0, imageSize.height - zoomAreaSize);
                    return Positioned(
                      left: clipX,
                      top: clipY,
                      width: zoomAreaSize,
                      height: zoomAreaSize,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: 20,
            ),
            child: Stack(
              children: [
                DetailsDataWidget(),
                if (_hovering && _pointerOffset != null)
                  ZoomView(
                    imagePath: "assets/images/others/01.webp",
                    imageKey: _imageKey,
                    pointerOffset: _pointerOffset!,
                    zoomScale: zoomScale,
                    zoomWindowSize: zoomWindowSize,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget BoldTitleText({required String title, required String value,isUnderlined=false}) {
    return RichText(
      text: TextSpan(
        text: '$title:  ',
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 17,),
        children: [
          TextSpan(
              text: value, style: TextStyle(fontWeight: FontWeight.normal,fontSize: 15,decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none,)),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }

  Widget CustomIconTitle(
      {required String text, required String text2, required IconData icon}) {
    return InkWell(
      onTap: () {},
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        children: [
          Icon(icon, size: 35, color: Color(0xff002f8c)),
          custSpace15X,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(text2, style: const TextStyle(fontSize: 12)),
            ],
          ),
          custSpace10X
        ],
      ),
    );
  }

  Widget DetailsDataWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Round 2.5 D VVS - A123A',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        custSpace5Y,
        Text('\$5464464',
            style: TextStyle(
                fontSize: 26! * 0.9,
                color: const Color(0xff002f8c),
                fontWeight: FontWeight.w500)),
        custSpace30Y,
        Row(
          children: [
            MouseRegion(
              onEnter: (_) {
                setState(() {
                  mouseHoverC = true;
                });
              },
              onExit: (_) {
                setState(() {
                  mouseHoverC = false;
                });
              },
              child: InkWell(
                onTap: () {},
                child: AnimatedContainer(
                  height: 55,
                  width: 250,
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                      color: mouseHoverC == true
                          ? Color(0xff002f8c)
                          : Colors.transparent,
                      border: Border.all(color: Color(0xff002f8c))),
                  child: Center(
                      child: Text('ADD TO CART',
                          style: TextStyle(
                              fontSize: 26! * 0.6,
                              color: mouseHoverC == true
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w600))),
                ),
              ),
            ),
            custSpace10X,
            MouseRegion(
              onEnter: (_) {
                setState(() {
                  mouseHoverF = true;
                });
              },
              onExit: (_) {
                setState(() {
                  mouseHoverF = false;
                });
              },
              child: InkWell(
                onTap: () {},
                child: AnimatedContainer(
                  height: 55,
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                      color: mouseHoverF == true
                          ? Color(0xff002f8c)
                          : Colors.transparent,
                      border: Border.all(color: Color(0xff002f8c))),
                  child: Center(
                      child: Icon(CupertinoIcons.heart,
                          color:
                              mouseHoverF == true ? Colors.white : Colors.black,
                          size: 26! * 0.9)),
                ),
              ),
            ),
            custSpace10X,
            MouseRegion(
              onEnter: (_) {
                setState(() {
                  mouseHoverS = true;
                });
              },
              onExit: (_) {
                setState(() {
                  mouseHoverS = false;
                });
              },
              child: InkWell(
                onTap: () {},
                child: AnimatedContainer(
                  height: 55,
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                      color: mouseHoverS == true
                          ? Color(0xff002f8c)
                          : Colors.transparent,
                      border: Border.all(color: Color(0xff002f8c))),
                  child: Center(
                      child: Icon(CupertinoIcons.share,
                          color:
                              mouseHoverS == true ? Colors.white : Colors.black,
                          size: 26! * 0.9)),
                ),
              ),
            ),
          ],
        ),
        custSpace50Y,
        Text('Product Information',
            style: TextStyle(
                fontSize: 26! * 0.9,
                color: Colors.black,
                fontWeight: FontWeight.w500)),
        const Divider(height: 30, color: Colors.black26),
        custSpace20Y,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoldTitleText(title: 'SKU', value: '298620 /298620',isUnderlined: true),
                  custSpace10Y,
                  BoldTitleText(title: 'Type', value: 'Natural'),
                  custSpace10Y,
                  BoldTitleText(title: 'Shape', value: 'Round'),
                  custSpace10Y,
                  BoldTitleText(title: 'Carat', value: '2.5'),
                  custSpace10Y,
                  BoldTitleText(title: 'Color', value: 'D'),
                  custSpace10Y,
                  BoldTitleText(title: 'Clarity', value: 'VVS'),
                  custSpace10Y,
                  BoldTitleText(title: 'Cut', value: 'EX'),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoldTitleText(title: 'Polish', value: 'Very Good'),
                  custSpace10Y,
                  BoldTitleText(title: 'Symmetry', value: 'Good'),
                  custSpace10Y,
                  BoldTitleText(title: 'Fluorescence', value: 'None'),
                  custSpace10Y,
                  BoldTitleText(title: 'Table', value: '70%'),
                  custSpace10Y,
                  BoldTitleText(title: 'Depth', value: '25%'),
                  custSpace10Y,
                  BoldTitleText(
                      title: 'Stone Dimensions (mm)', value: '4 X 2 X 3'),
                ],
              ),
            ),
          ],
        ),
        custSpace50Y,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Certificate',
                style: TextStyle(
                    fontSize: 26! * 0.9,
                    color: Colors.black,
                    fontWeight: FontWeight.w500)),
            MouseRegion(
              onEnter: (_) => setState(() => isHovering = true),
              onExit: (_) => setState(() => isHovering = false),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        child: SingleChildScrollView(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/others/gia certificate.jpg',
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text(
                  'View Report',
                  style: TextStyle(
                    fontSize: 16 * 0.9,
                    color: isHovering ? Colors.black : Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 30, color: Colors.black26),
        custSpace50Y,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomIconTitle(
                  text: 'RISK FREE SHOPPING',
                  text2: '30-day returns',
                  icon: CupertinoIcons.checkmark_shield),
              custSpace20X,
              Container(color: Colors.black12, width: 1, height: 50),
              custSpace20X,
              CustomIconTitle(
                  text: 'LIFETIME WARRANTY',
                  text2: 'Complimentary repairs & care',
                  icon: LineAwesome.medal_solid),
              custSpace20X,
              Container(color: Colors.black12, width: 1, height: 50),
              custSpace20X,
              CustomIconTitle(
                  text: 'FREE SHIPPING',
                  text2: 'On every order',
                  icon: Bootstrap.truck),
            ],
          ),
        )
      ],
    );
  }
}


class ZoomView extends StatelessWidget {
  final String imagePath;
  final GlobalKey imageKey;
  final Offset pointerOffset;
  final double zoomScale;
  final double zoomWindowSize;

  const ZoomView({
    super.key,
    required this.imagePath,
    required this.imageKey,
    required this.pointerOffset,
    this.zoomScale = 2.5,
    this.zoomWindowSize = 300,
  });

  @override
  Widget build(BuildContext context) {
    final box = imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox();
    final imageSize = box.size;
    final zoomAreaSize = zoomWindowSize / zoomScale;
    double clipX = pointerOffset.dx - zoomAreaSize / 2;
    double clipY = pointerOffset.dy - zoomAreaSize / 2;
    clipX = clipX.clamp(0.0, imageSize.width - zoomAreaSize);
    clipY = clipY.clamp(0.0, imageSize.height - zoomAreaSize);

    return Container(
      width: zoomWindowSize,
      height: zoomWindowSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: ClipRect(
        child: Transform(
          transform: Matrix4.identity()
            ..translate(-clipX - 50, -clipY - 50)
            ..scale(zoomScale),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: imageSize.width,
            height: imageSize.height,
          ),
        ),
      ),
    );
  }
}
 */