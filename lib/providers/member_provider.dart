import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:errandbuddy/model/member_model.dart';
import 'package:flutter/material.dart';

class MemberProvider with ChangeNotifier {
  List<Member> _members = [];

  List<Member> get members => _members;

  Future<void> fetchMembers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('ErrandMembers')
        .get();

    _members = snapshot.docs
        .map((doc) => Member.fromFirestore(doc.data(), doc.id))
        .toList();

    notifyListeners();
  }
}
