class UserModel {
  // we may add some fields later ! I did it based on edit profile page fields
  final String fullName;
  final String email;
  final String phoneNumber;
  final String bio;

  UserModel({required this.fullName, required this.email, required this.phoneNumber, required this.bio});
}
