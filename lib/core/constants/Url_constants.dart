// final baseUrl = 'http://ecmtest.iotwater.in:3010/api/v1/';
// final ecmapi = 'ecm/';
// final authapi = 'auth/';

// ignore: non_constant_identifier_names
// ignore_for_file: non_constant_identifier_names, duplicate_ignore, file_names

final String WebApiStatusOk = 'Ok';
final String WebApiStatusFail = 'Fail';
final String WebApiUrl = 'http://ecmv2.iotwater.in:3011/api/v1/';
final String loginPrefix = 'auth/';
final String ecmApiPrefix = 'ecm/';
final String ecmImagePrefix = 'ecm_images/';
final String damageImagePrefix = 'damage_images/';
final String routineImagePrefix = 'routine_images/';
final String damageApiPrefix = 'damage/';
final String projectPrefix = 'project/';
final String routinePrefix = 'routine/';

String GetHttpRequest(String ApiPrefix, String CallName) {
  var url = WebApiUrl + ApiPrefix + CallName;
  return url;
}
