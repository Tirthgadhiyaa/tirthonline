import 'package:flutter/material.dart';
import 'package:jewellery_diamond/widgets/responsive_ui.dart';
import 'package:jewellery_diamond/widgets/sized_box_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../gen/assets.gen.dart';

class ContactBanner extends StatefulWidget {
  const ContactBanner({super.key});

  @override
  State<ContactBanner> createState() => _ContactBannerState();
}

class _ContactBannerState extends State<ContactBanner> {
  bool mouseHoverR = false;
  bool mouseHoverC = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            color: Colors.black.withOpacity(0.03),
            child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: width * 0.05, horizontal: width * 0.05),
                child: Device.desktop(context)
                    ? NeedGuidanceDesktopTablet()
                    : Device.tablet(context)
                        ? NeedGuidanceDesktopTablet(isTablet: true)
                        : NeedGuidanceMobile())),
      ],
    );
  }

  Widget NeedGuidanceDesktopTablet({bool? isTablet = false}) {
    double width = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Expanded(
            child: Image.asset(Assets.images.companybanner.path,
                fit: BoxFit.cover)),
        SizedBox(width: width * 0.05),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need Guidance? Consult An Expert',
                style: TextStyle(
                    fontSize: isTablet == true ? 26 : 34,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            custSpace10Y,
            Text(
                'Receive one-on-one, personal guidance from our industry leading diamond experts in-store or online.',
                style: TextStyle(
                    fontSize: isTablet == true ? 16 : 20,
                    color: Colors.black.withOpacity(0.7))),
            custSpace30Y,
            if (Device.desktop(context))
              Row(
                children: [
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        mouseHoverR = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        mouseHoverR = false;
                      });
                    },
                    child: InkWell(
                      onTap: () async {},
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            color: mouseHoverR == true
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white,
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer)),
                        child: Text('REQUEST AN APPOINTMENT',
                            style: TextStyle(
                                color: mouseHoverR == true
                                    ? Colors.white
                                    : Colors.black)),
                      ),
                    ),
                  ),
                  custSpace10X,
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
                      onTap: () {
                        _makePhoneCall('+919227000200');
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            color: mouseHoverC == true
                                ? Theme.of(context).colorScheme.primary
                                : Colors.white,
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer)),
                        child: Text('CALL NOW',
                            style: TextStyle(
                                color: mouseHoverC == true
                                    ? Colors.white
                                    : Colors.black)),
                      ),
                    ),
                  ),
                ],
              ),
            if (Device.tablet(context) || Device.mobile(context))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        mouseHoverR = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        mouseHoverR = false;
                      });
                    },
                    child: InkWell(
                      onTap: () async {},
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            color: mouseHoverR == true
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer
                                : Colors.white,
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer)),
                        child: Text('REQUEST AN APPOINTMENT',
                            style: TextStyle(
                                color: mouseHoverR == true
                                    ? Colors.white
                                    : Colors.black)),
                      ),
                    ),
                  ),
                  custSpace10Y,
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
                      onTap: () {
                        _makePhoneCall('+919227000200');
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            color: mouseHoverC == true
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer
                                : Colors.white,
                            border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer)),
                        child: Text('CALL NOW',
                            style: TextStyle(
                                color: mouseHoverC == true
                                    ? Colors.white
                                    : Colors.black)),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        )),
      ],
    );
  }

  Widget NeedGuidanceMobile() {
    return Column(
      children: [
        Image.asset(Assets.images.companybanner.path, fit: BoxFit.cover),
        custSpace20Y,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Need Guidance? Consult An Expert',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            custSpace5Y,
            const Text(
                'Receive one-on-one, personal guidance from our industry leading diamond experts in-store or online.',
                style: TextStyle(fontSize: 14, color: Colors.black54)),
            custSpace20Y,
            Row(
              children: [
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      mouseHoverR = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      mouseHoverR = false;
                    });
                  },
                  child: InkWell(
                    onTap: () {},
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                          color: mouseHoverR == true
                              ? const Color(0xff4e4351)
                              : Colors.transparent,
                          border: Border.all(color: const Color(0xff4e4351))),
                      child: Text('REQUEST AN APPOINTMENT',
                          style: TextStyle(
                              color: mouseHoverR == true
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12)),
                    ),
                  ),
                ),
                custSpace10X,
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
                    onTap: () {
                      _makePhoneCall('+919227000200');
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                          color: mouseHoverC == true
                              ? const Color(0xff4e4351)
                              : Colors.transparent,
                          border: Border.all(color: const Color(0xff4e4351))),
                      child: Text('CALL NOW',
                          style: TextStyle(
                              color: mouseHoverC == true
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
}
