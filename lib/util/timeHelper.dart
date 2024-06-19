class TimeHelper {

  bool isCurrentTimeInRange(String start, String end) {
    DateTime now = DateTime.now();
    DateTime startTime = timeStringCovertToDateTime(start,false);
    DateTime endTime = timeStringCovertToDateTime(end,true);
    // Check if 'now' is between 'start' and 'end'
    if (now.isAfter(startTime) && now.isBefore(endTime)) {
      return true;
    } else {
      return false;
    }
  }

  DateTime timeStringCovertToDateTime(String timeString,bool isEnd){
    DateTime now = DateTime.now();
    if(isEnd){
      if(timeString == "00:00:00"){
        timeString = "23:59:59";
      }
    }
    List<String> parts = timeString.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);
    return DateTime(now.year, now.month, now.day, hours, minutes, seconds);
  }
}