import 'package:flutter/material.dart';

/// custom app bar

AppBar customAppBar({required String title})=> AppBar(
    title:  Text(title),
    centerTitle: true,
    elevation: 0);