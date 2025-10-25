import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PrescriptionWidget extends StatelessWidget {
  const PrescriptionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 20,
            vertical: isMobile ? 24 : 40,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.fromARGB(255, 255, 190, 106),
                Color.fromARGB(255, 255, 227, 184)
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Doctor illustration
          Container(
            width: 280,
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(60),
            ),
            child: SvgPicture.asset(
              "assets/images/doctor.svg",
              width: 200,
              height: 200,
            ),
          ),
          
          const SizedBox(width: 40),
          
          // Content section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Have a prescription\nfrom a doctor?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: () {
                  showPopUpPrescription(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C42),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Upload prescription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Or enter e-prescription number',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          // The Row needs to know how to distribute space.
          // We'll use Expanded for the content Column.
          children: [
            // Doctor illustration
            Container(
              width: 180,
              height: 160,
              decoration: BoxDecoration(
                // Assuming Colors.white.withValues(alpha: 0.8) is a typo
                // and should be Colors.white.withOpacity(0.8) or a custom extension
                // Using a standard color for demonstration.
                color: Colors.grey[100], 
                borderRadius: BorderRadius.circular(40),
              ),
              child: SvgPicture.asset(
                "assets/images/doctor.svg",
                width: 140,
                height: 140,
              ),
            ),
            SizedBox(width: 8),

            // Wrap the content Column in Expanded to take up remaining space
            Expanded( 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center contents horizontally in this expanded area
                children: [
                  // Content section
                  const Text(
                    'Do you have\na prescription\nfrom a doctor?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 4),
                  // The inner Column is redundant here, you can place children directly.
                  // We keep the SizedBox and ElevatedButton directly here,
                  // and since the parent is Expanded, the SizedBox can use double.infinity.
                  SizedBox(
                    // width: double.infinity is now safe because the parent Expanded
                    // provides a constrained width.
                    width: double.infinity, 
                    child: ElevatedButton(
                      onPressed: () {
                        showPopUpPrescription(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C42),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Upload',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PrescriptionUploadDialog extends StatefulWidget {
  @override
  _PrescriptionUploadDialogState createState() => _PrescriptionUploadDialogState();
}

class _PrescriptionUploadDialogState extends State<PrescriptionUploadDialog> {
  bool isUploading = false;
  bool isFileSelected = false;
  bool isFileRead = false;
  bool isDataProcessed = false;
  double uploadProgress = 0.0;

  void _selectFile() {
    setState(() {
      isFileSelected = true;
    });
    _simulateUploadProcess();
  }

  void _simulateUploadProcess() async {
    setState(() {
      isUploading = true;
      uploadProgress = 0.0;
    });

    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(Duration(milliseconds: 100));
      setState(() {
        uploadProgress = i / 100;
      });
    }

    await Future.delayed(Duration(milliseconds: 300));
    setState(() {
      isFileRead = true;
      isUploading = false;
    });

    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      isDataProcessed = true;
    });
  }

  void _removeFile() {
    setState(() {
      isFileSelected = false;
      isFileRead = false;
      isDataProcessed = false;
      isUploading = false;
      uploadProgress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.of(context).size.width < 768;
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 20,
            vertical: isMobile ? 24 : 40,
          ),
          child: Container(
            width: isMobile ? double.infinity : 400,
            constraints: BoxConstraints(
              maxHeight: isMobile ? MediaQuery.of(context).size.height * 0.8 : 500,
            ),
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Prescription Upload',
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                
                SizedBox(height: isMobile ? 24 : 32),
                
                // Upload area
                if (!isFileSelected) ...[
                  GestureDetector(
                    onTap: _selectFile,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 32 : 40,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: isMobile ? 56 : 64,
                            height: isMobile ? 56 : 64,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Icon(
                              Icons.file_upload_outlined,
                              size: isMobile ? 28 : 32,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: isMobile ? 12 : 16),
                          Text(
                            'Select File',
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'or drag it here',
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // File selected state
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 14 : 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // File info
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Prescription.jpg',
                                    style: TextStyle(
                                      fontSize: isMobile ? 15 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '135 KB',
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _removeFile,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey.shade600,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 12 : 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Upload progress
                        if (isUploading) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prescription verification in progress...',
                                style: TextStyle(
                                  fontSize: isMobile ? 13 : 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: uploadProgress,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                                minHeight: 6,
                              ),
                            ],
                          ),
                        ],
                        
                        // Success states
                        if (isFileRead || isDataProcessed) ...[
                          const SizedBox(height: 16),
                        ],
                        
                        if (isFileRead) ...[
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'File read',
                                style: TextStyle(
                                  fontSize: isMobile ? 13 : 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        if (isDataProcessed) ...[
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Data processed',
                                style: TextStyle(
                                  fontSize: isMobile ? 13 : 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                
                SizedBox(height: isMobile ? 24 : 32),
                
                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: isMobile ? 46 : 50,
                  child: ElevatedButton(
                    onPressed: (isDataProcessed) ? () {
                      Navigator.of(context).pop();
                      // Add your continue logic here
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void showPopUpPrescription(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return PrescriptionUploadDialog();
    },
  );
}