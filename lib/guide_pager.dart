// ignore_for_file: non_constant_identifier_names

import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/localization/language_constants.dart';
import 'package:diamond_booking/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_view_indicators/step_page_indicator.dart';
import 'package:sizer/sizer.dart';

class GuidePager extends StatefulWidget {
  String type;

  GuidePager({super.key, required this.type});
  @override
  _State createState() => _State(type);
}

class _State extends State<GuidePager> {
  String type;
  _State(this.type);

  final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();
  List<CustomerType> LstCustomerType = [];
  List<CustomerType> TmpLstCustomerType = [];
  List<CustomerType> OrgLstCustomerType = [];
  bool CheckVisableBut = false;
  final _pageController = PageController();
  final _currentPageNotifier = ValueNotifier<int>(0);
  @override
  void initState() {
    LstCustomerType.add(
        CustomerType(Image: "assets/images/p1.png", Name: "p1", Type: "1"));
    LstCustomerType.add(
        CustomerType(Image: "assets/images/p2.png", Name: "p2", Type: "1"));
    LstCustomerType.add(
        CustomerType(Image: "assets/images/p3.png", Name: "p3", Type: "1"));
    TmpLstCustomerType.add(
        CustomerType(Image: "assets/images/p1.png", Name: "p4", Type: "2"));
    TmpLstCustomerType.add(
        CustomerType(Image: "assets/images/p2.png", Name: "p5", Type: "2"));
    TmpLstCustomerType.add(
        CustomerType(Image: "assets/images/p3.png", Name: "p6", Type: "2"));
    if (type == "1") {
      OrgLstCustomerType = LstCustomerType;
    } else if (type == "2") {
      OrgLstCustomerType = TmpLstCustomerType;
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey1,
      body: _buildBody(),
    );
  }

  _buildBody() {
    return Container(
      // ignore: sort_child_properties_last
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildPageView(),
          _buildStepIndicator(),
        ],
      ),
      color: Colors.white,
    );
  }

  String x = "Next";

  _buildPageView() {
    return Expanded(
      child: PageView.builder(
        itemCount: OrgLstCustomerType.length,
        controller: _pageController,
        itemBuilder: (BuildContext context, int index) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                image: AssetImage(OrgLstCustomerType[index].Image),
                width: 200,
                height: 200,
              ),
              Container(
                height: 20,
              ),
              // ignore: sort_child_properties_last
              Container(
                // ignore: sort_child_properties_last
                child: Text(
                  getTranslated(context, OrgLstCustomerType[index].Name),
                  style: TextStyle(fontSize: 4.w, fontWeight: FontWeight.bold),
                ),
                margin: const EdgeInsets.all(15),
              ),
              Container(
                height: 20,
              ),
              // ignore: sort_child_properties_last
              Visibility(
                // ignore: sort_child_properties_last
                child: Container(
                  width: 150,
                  height: 35,
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    child: Center(
                      child: Text(
                        getTranslated(context, x),
                        style: TextStyle(
                          color: kTypeUserTextColor,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LoginScreen(
                                title: '',
                              )));
                    },
                  ),
                ),
                visible: CheckVisableBut,
              )
            ],
          ));
        },
        onPageChanged: (int index) {
          if (index == OrgLstCustomerType.length - 1) {
            setState(() {
              CheckVisableBut = true;
            });
          }
          _currentPageNotifier.value = index;
        },
      ),
    );
  }

  _buildStepIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: StepPageIndicator(
        itemCount: OrgLstCustomerType.length,
        currentPageNotifier: _currentPageNotifier,
        size: 16,
        onPageSelected: (int index) {
          if (_currentPageNotifier.value > index) {
            _pageController.jumpToPage(index);
          }
        },
      ),
    );
  }
}

class CustomerType {
  late String Name, Image, Type;
  CustomerType({required this.Image, required this.Name, required this.Type});
}
