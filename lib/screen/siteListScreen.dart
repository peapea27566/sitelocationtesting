import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sitelocation/screen/mapScreenSite.dart';
import 'package:sitelocation/util/coordinateshelper.dart';
import 'package:sitelocation/util/globalhelper.dart';
import 'package:sitelocation/util/timeHelper.dart';
import '../model/site.dart';

class SiteListScreen extends StatefulWidget {
  final List<double> coordinatesSelected;

  const SiteListScreen({
    super.key,
    required this.coordinatesSelected,
  });

  @override
  SiteListScreenState createState() => SiteListScreenState();
}

class SiteListScreenState extends State<SiteListScreen> {
  List<Site> sites = [];
  List<Site> filteredSites = [];
  double paddingHeight = 8.0;

  @override
  void initState() {
    super.initState();
    loadSiteFileData();
  }

  Future<void> loadSiteFileData() async {
    final String response =
        await rootBundle.loadString('assets/site-list.json');
    final List<dynamic> data = json.decode(response);

    var sitesTemps = data
        .map((item) => Site.fromJson(item))
        .where((item) =>
            item.location.coordinates[0] != 0.0 &&
            item.location.coordinates[1] != 0.0)
        .toList();
    var siteOpens = sitesTemps
        .where((item) => TimeHelper()
            .isCurrentTimeInRange(item.siteOpenTime, item.siteCloseTime))
        .toList();
    var siteClose = sitesTemps
        .where((item) => !TimeHelper()
            .isCurrentTimeInRange(item.siteOpenTime, item.siteCloseTime))
        .toList();
    calculateDistancesAndMarkOpen(siteOpens, true);
    calculateDistancesAndMarkOpen(siteClose, false);
    List<Site> listSite = [...siteOpens, ...siteClose];

    setState(() {
      sites = listSite;
      filteredSites = listSite;
    });
  }

  void calculateDistancesAndMarkOpen(List<Site> branches, bool isOpen) {
    for (var branch in branches) {
      double distance = CoordinatesHelper().calculateDistance(
        widget.coordinatesSelected[0], // Selected latitude
        widget.coordinatesSelected[1], // Selected longitude
        branch.location.coordinates[1], // Branch longitude
        branch.location.coordinates[0], // Branch latitude
      );
      branch.distanceFromSelected = distance;
      branch.isOpen = isOpen;
    }
    // Sort branches by distance in ascending order
    branches.sort(
        (a, b) => a.distanceFromSelected.compareTo(b.distanceFromSelected));
  }

  void searchLocation(String query) {
    setState(() {
      filteredSites = sites
          .where((site) =>
              site.siteDesc.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ค้นหาสาขา',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.blue,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          fieldSearchSite(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSites.length,
              itemBuilder: (context, index) {
                final site = filteredSites[index];
                return cardSite(site);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget fieldSearchSite() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
          decoration: InputDecoration(
            hintText: 'ค้นหาสาขา',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          onSubmitted: (value) {
            searchLocation(value);
          }),
    );
  }

  Widget cardSite(Site site) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: paddingHeight),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    siteInfoRow("สาขา", site.siteDesc),
                    SizedBox(height: paddingHeight),
                    siteInfoRow("ระยะทางภายในรัศมี",
                        "${site.distanceFromSelected} กม."),
                    SizedBox(height: paddingHeight),
                    site.isOpen
                        ? siteInfoRow("เวลาเปิดปิดร้าน",
                            "${site.siteOpenTime} - ${site.siteCloseTime}")
                        : closeSiteTimeText("เวลาเปิดปิดร้าน",
                            "(เปิด ${site.siteOpenTime} - ${site.siteCloseTime})"),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8.0),
            rowBtnAction(site)
          ],
        ),
      ),
    );
  }

  Widget siteInfoRow(String section, String detail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$section : ',
        ),
        Text(detail,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ))
      ],
    );
  }

  Widget closeSiteTimeText(String section, String detail) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$section : ',
        ),
        Row(
          children: [
            const Text("ปิด",
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            Text(
              detail,
            )
          ],
        )
      ],
    );
  }

  Widget rowBtnAction(Site site) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: site.isOpen
                ? () {
                    GlobalHelper().makePhoneCall(site.siteTel);
                  }
                : null,
            icon: const Icon(
              Icons.call,
              color: Colors.blue,
            ),
            label: Flexible(
              child: Text(
                site.siteTel,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Colors.blue),
              ),
            ),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                disabledForegroundColor: Colors.white.withOpacity(0.80)),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: site.isOpen
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MapSiteScreen(
                                site: site,
                              )),
                    );
                  }
                : null,
            icon: const Icon(
              Icons.map,
              color: Colors.white,
            ),
            label:
                const Text('แผนที่สาขา', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              disabledForegroundColor: Colors.lightBlue.withOpacity(0.38),
              disabledBackgroundColor: Colors.grey.withOpacity(0.12),
            ),
          ),
        ),
      ],
    );
  }
}
