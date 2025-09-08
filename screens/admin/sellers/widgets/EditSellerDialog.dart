import 'package:flutter/material.dart';

class EditSellerDialog extends StatelessWidget {
  const EditSellerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: const Text(
        'Edit Seller',
        style: TextStyle(
          color: Color(0xFF9B1C1C),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: 1000,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildCard(
                      title: 'User Information',
                      subtitle: 'Enter the seller\'s personal information',
                      icon: Icons.person,
                      children: [
                        _textField(label: 'Email', icon: Icons.email),
                        _textField(label: 'New Password', icon: Icons.lock),
                        _textField(label: 'Confirm New Password', icon: Icons.lock_outline),
                        Row(
                          children: [
                            Expanded(child: _textField(label: 'First Name', icon: Icons.person)),
                            const SizedBox(width: 8),
                            Expanded(child: _textField(label: 'Last Name', icon: Icons.person)),
                          ],
                        ),
                        _textField(label: 'Phone Number', icon: Icons.phone),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCard(
                      title: 'Business Address',
                      subtitle: 'Enter the business address',
                      icon: Icons.location_on,
                      children: [
                        _textField(label: 'Street Address', icon: Icons.location_on),
                        Row(
                          children: [
                            Expanded(child: _textField(label: 'City', icon: Icons.location_city)),
                            const SizedBox(width: 8),
                            Expanded(child: _textField(label: 'State', icon: Icons.map)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: _textField(label: 'Country', icon: Icons.public)),
                            const SizedBox(width: 8),
                            Expanded(child: _textField(label: 'Postal Code', icon: Icons.confirmation_number)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCard(
                title: 'Business Information',
                subtitle: 'Enter the business details',
                icon: Icons.business,
                children: [
                  _textField(label: 'Business Name', icon: Icons.apartment),
                  _textField(label: 'Business Description', icon: Icons.description),
                  Row(
                    children: [
                      Expanded(child: _textField(label: 'Business Phone', icon: Icons.phone)),
                      const SizedBox(width: 8),
                      Expanded(child: _textField(label: 'Tax ID', icon: Icons.receipt_long)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontSize: 16),
          ),
          child: const Text('Cancel'),
        ),
        SizedBox(
          height: 40,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF9B1C1C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE5E7EB)), // Light gray border
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: Color(0xFF9B1C1C)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ...children.map(
                (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: e,
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({required String label, required IconData icon}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}
