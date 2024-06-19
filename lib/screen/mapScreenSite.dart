import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sitelocation/util/globalhelper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/site.dart';

class MapSiteScreen extends StatefulWidget {
  final Site site;

  const MapSiteScreen({
    super.key,
    required this.site,
  });

  @override
  MapSiteScreenState createState() => MapSiteScreenState();
}

class MapSiteScreenState extends State<MapSiteScreen> {
  GoogleMapController? mapController;
  LatLng siteCoordinates = const LatLng(0, 0);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      siteCoordinates = LatLng(widget.site.location.coordinates[1],
          widget.site.location.coordinates[0]);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(widget.site.siteId),
          position: siteCoordinates,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.site.siteDesc,
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: siteCoordinates,
              zoom: 15.0,
            ),
            markers: _markers,
          ),
          cardDetailAddress(),
          cardDetailSite(),
        ],
      ),
    );
  }

  Widget cardDetailAddress() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
            alignment: Alignment.topCenter,
            child: Card(
                color: Colors.white,
                child: IntrinsicHeight(
                    child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ที่อยู่"),
                        const Divider(),
                        Text(widget.site.siteAddress),
                      ]),
                )))));
  }

  Widget cardDetailSite() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Card(
                color: Colors.white,
                child: IntrinsicHeight(
                    child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: columnSite())))));
  }

  Widget columnSite() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: Colors.blue),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                siteInfoRow("สาขา", widget.site.siteDesc),
                const SizedBox(height: 8.0),
                siteInfoRow("ระยะทางภายในรัศมี",
                    "${widget.site.distanceFromSelected} กม."),
                const SizedBox(height: 8.0),
                siteInfoRow("เวลาเปิดปิดร้าน",
                    "${widget.site.siteOpenTime} - ${widget.site.siteCloseTime}"),
              ],
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 8.0),
        rowBtnAction(widget.site)
      ],
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

  Widget rowBtnAction(Site site) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              GlobalHelper().makePhoneCall(site.siteTel);
            },
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
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              GlobalHelper().openGoogleMaps(widget.site.location.coordinates[1],
                  widget.site.location.coordinates[0]);
            },
            icon: const Icon(
              Icons.golf_course,
              color: Colors.white,
            ),
            label: const Text('นำทาง', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
            ),
          ),
        ),
      ],
    );
  }
}
