import 'dart:core';

List<String> selectStateList = ['Select City'];

class CityList {
  static const List<String> selectState = ["Select City"];
  static const List<String> andhraPradeshCity = ["Amaravati", "Other"];
  static const List<String> chandigarhCity = ["Chandigarh"];
  static const List<String> assamCity = ["Dispur", "Guwahati", "Other"];
  static const List<String> biharCity = ["Patna", "Other"];
  static const List<String> arunachalPradeshCity = ["Itanagar", "Other"];
  static List<String> popularCities = [
    'All City',
    'Chandigarh',
    // 'Mohali',
    'Ludhiana',
    // 'Amritsar',
    'Pune',
    'Bangalore',
    'Chennai',
    // 'Hyderabad',
    'Guwahati',
    'Kolkata',
    'New Delhi',
    'Noida',
    'Gurugram',
    // 'Ghaziabad',
    // 'Faridabad',
    'Indore',
    // 'Mumbai',
    'Bhopal',
    'Lucknow',
    'Agra',
    // 'Kanpur',
    // 'Jaipur',
    'Raipur',
    'North Goa',
    // 'South Goa'
  ];

  static const List<String> chhatisgarhCity = [
    'Raipur',
    'Other',
  ];
  static const List<String> dadarAndNagarCity = ['Dadra and Nagar Haveli'];

  static const List<String> damanDiuCity = ['Daman', 'Diu', "Silvassa"];

  static const List<String> delhiCity = [
    "Ghaziabad",
    "Gurugram",
    "Faridabad",
    'New Delhi',
    "Noida",
  ];

  static const List<String> goaCity = ["North Goa", "South Goa"];
  static const List<String> gujaratCity = [
    'Ahmedabad',
    'Gandhinagar',
    'Rajkot',
    'Surat',
    'Other'
  ];

  static const List<String> haryanaCity = [
    'Ambala',
    'Bhiwani',
    'Fatehabad',
    'Hissar',
    'Jhajjar',
    'Jind',
    'Karnal',
    'Kaithal',
    'Kurukshetra',
    'Mahendragarh',
    'Mewat',
    'Palwal',
    'Panchkula',
    'Panipat',
    'Rewari',
    'Rohtak',
    'Sirsa',
    'Sonipat',
    'Yamuna Nagar',
    "Other"
  ];
  static const List<String> himachalPradeshCity = [
    'Bilaspur',
    'Chamba',
    'Kullu',
    'Lahaul and Spiti',
    'Mandi',
    'Shimla',
    "Other"
  ];

  static const List<String> jammuKashmirCity = ["Jammu", "Kashmir", "Other"];

  static const List<String> jharkhandCity = ["Ranchi", "Other"];
  static const List<String> karnatakaCity = ['Bangalore', "Other"];
  static const List<String> keralaCity = ['Thiruvananthapuram', "Other"];

  static const List<String> madhyaPradeshCity = ["Indore", "Bhopal", "Other"];
  static const List<String> maharashtraCity = [
    'Mumbai',
    'Navi Mumbai',
    'Pune',
    "Other"
  ];
  static const List<String> manipurCity = ["Imphal", "Other"];
  static const List<String> meghalayaCity = ["Shillong", "Other"];
  static const List<String> mizoramCity = ['Aizawl', "Other"];

  static const List<String> nagalandCity = ['Kohima', "Other"];

  static const List<String> odissaCity = ["Bhubaneswar", "other"];
  static const List<String> pondicherryCity = [
    'Pondicherry',
    'Other',
  ];
  static const List<String> punjabCity = [
    "Amritsar",
    "Ludhiana",
    "Mohali",
    "Other"
  ];
  static const List<String> rajasthanCity = [
    'Ajmer',
    'Alwar',
    'Bikaner',
    'Jodhpur',
    'Jaipur',
    'Jaisalmer',
    'Kota',
    'Udaipur',
    "Other"
  ];
  static const List<String> sikkimCity = [
    'East Sikkim',
    'North Sikkim',
    'South Sikkim',
    'West Sikkim',
    "Other"
  ];

  static const List<String> tamilNaduCity = ['Chennai', "Other"];
  static const List<String> tripuraCity = ["Agartala", "Other"];
  static const List<String> telangaCity = ["Hyderabad", "Other"];

  static const List<String> uttarPradeshCity = [
    "Lucknow",
    "Agra",
    "Kanpur",
    "Other"
  ];
  static const List<String> uttarkhandCity = [
    'Almora',
    'Bageshwar',
    'Chamoli',
    'Champawat',
    'Dehradun',
    'Haridwar',
    'Nainital',
    'Pauri Garhwal',
    'Pithoragarh',
    'Rudraprayag',
    'Tehri Garhwal',
    "Other"
  ];
  static const List<String> uttarakhandCity = ["Uttranchal"];
  static const List<String> westBengalCity = ['Kolkata', "Other"];
  static const List<String> notAvailableCity = ["S"];
}

List<String> getStateCity(dropState) {
  List<String> stateCity = [];
  switch (dropState) {
    case "Andhra Pradesh":
      stateCity = CityList.andhraPradeshCity;
      break;
    case "Arunachal Pradesh":
      stateCity = CityList.arunachalPradeshCity;
      break;
    case "Assam":
      stateCity = CityList.assamCity;
      break;
    case "Bihar":
      stateCity = CityList.biharCity;
      break;
    case "Chandigarh":
      stateCity = CityList.chandigarhCity;
      break;
    case "Chhattisgarh":
      stateCity = CityList.chhatisgarhCity;
      break;
    case "Dadra & Nagar Haveli":
      stateCity = CityList.dadarAndNagarCity;
      break;
    case "Daman & Diu":
      stateCity = CityList.damanDiuCity;
      break;
    case "Delhi NCR":
      stateCity = CityList.delhiCity;
      break;
    case "Goa":
      stateCity = CityList.goaCity;
      break;
    case "Gujarat":
      stateCity = CityList.gujaratCity;
      break;
    case "Haryana":
      stateCity = CityList.haryanaCity;
      break;
    case "Himachal Pradesh":
      stateCity = CityList.himachalPradeshCity;
      break;
    case "Jammu & Kashmir":
      stateCity = CityList.jammuKashmirCity;
      break;
    case "Jharkhand":
      stateCity = CityList.jharkhandCity;
      break;
    case "Karnataka":
      stateCity = CityList.karnatakaCity;
      break;
    case "Kerala":
      stateCity = CityList.keralaCity;
      break;
    case "Madhya Pradesh":
      stateCity = CityList.madhyaPradeshCity;
      break;
    case "Maharashtra":
      stateCity = CityList.maharashtraCity;
      break;
    case "Manipur":
      stateCity = CityList.manipurCity;
      break;
    case "Meghalaya":
      stateCity = CityList.meghalayaCity;
      break;
    case "Mizoram":
      stateCity = CityList.mizoramCity;
      break;
    case "Nagaland":
      stateCity = CityList.nagalandCity;
      break;
    case "Orissa":
      stateCity = CityList.odissaCity;
      break;
    case "Punjab":
      stateCity = CityList.punjabCity;
      break;
    case "Pondicherry":
      stateCity = CityList.pondicherryCity;
      break;
    case "Rajasthan":
      stateCity = CityList.rajasthanCity;
      break;
    case "Sikkim":
      stateCity = CityList.sikkimCity;
      break;
    case "Tamil Nadu":
      stateCity = CityList.tamilNaduCity;
      break;
    case "Tripura":
      stateCity = CityList.tripuraCity;
      break;
    case "Uttar Pradesh":
      stateCity = CityList.uttarPradeshCity;
      break;
    case "Uttarakhand":
      stateCity = CityList.uttarakhandCity;
      break;
    case "West Bengal":
      stateCity = CityList.westBengalCity;
      break;
    case "Telangana":
      stateCity = CityList.telangaCity;
      break;
    default:
      stateCity = CityList.notAvailableCity;
  }
  return stateCity;
}
