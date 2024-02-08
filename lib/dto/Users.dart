import 'dart:ffi';

class Users
{
    final int id;
    final String profileName;
    final String name;
    final int status;
    final String email;

    const Users({
      required this.id, required this.profileName, required this.name, required this.status, required this.email
    });

    factory Users.fromJson(Map<String, dynamic> addjson){

      return Users(
          id: addjson["id"],
          profileName:  addjson["profileName"],
          name: addjson["name"],
          status: addjson["status"],
        email: addjson["email"]
      );
    }

    // factory Users.fromJson(Map<String, dynamic> json) {
    //   return switch (json) {
    //     {
    //     'id': Long id,
    //     'profileName': String profileName,
    //     'name': String name,
    //     'status': int status,
    //     'email': String email,
    //     } =>
    //         Users(
    //           id: id,
    //           profileName: profileName,
    //           name: name,
    //           status: status,
    //           email: email
    //         ),
    //     _ => throw const FormatException('Failed to load users.'),
    //   };
    // }

}