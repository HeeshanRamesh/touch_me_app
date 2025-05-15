import 'package:flutter/material.dart';

class ProfilePersonalDetailsScreen extends StatelessWidget {
  const ProfilePersonalDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Personal Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: const AssetImage('assets/profile_picture.png'),
                  child: const Icon(Icons.person, size: 50, color: Colors.grey), // Fallback icon
                ),
              ),
              const SizedBox(height: 30),
              // Name
              const Text(
                'Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8E8EE), // Light pink background
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _isEditing
                    ? TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      )
                    : Text(
                        _nameController.text,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
              ),
              const SizedBox(height: 20),
              // Email
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8E8EE),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _isEditing
                    ? TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      )
                    : Text(
                        _emailController.text,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
              ),
              const SizedBox(height: 20),
              // Phone
              const Text(
                'Phone',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8E8EE),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _isEditing
                    ? TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      )
                    : Text(
                        _phoneController.text,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
              ),
              const SizedBox(height: 20),
              // Location
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8E8EE),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _isEditing
                    ? TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      )
                    : Text(
                        _locationController.text,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
              ),
              const SizedBox(height: 20),
              // Gender
              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8E8EE),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _isEditing
                    ? TextField(
                        controller: _genderController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      )
                    : Text(
                        _genderController.text,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
              ),
              const SizedBox(height: 40),
              // Edit Profile / Save Changes Button
              Center(
                child: ElevatedButton(
                  onPressed: _isEditing ? _saveChanges : _toggleEditMode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A), // Purple background
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Save Changes' : 'Edit Profile',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}