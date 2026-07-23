const jwt = require('jsonwebtoken');
const { admin } = require('../config/firebase');
const User = require('../models/User');

/**
 * @desc   Authenticate user via Firebase ID Token, create/find user, return JWT
 * @route  POST /api/auth/login
 * @access Public
 */
const login = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({
        success: false,
        message: 'idToken is required'
      });
    }

    let uid;
    let phoneNumber;

    try {
      // Verify Firebase ID Token using Firebase Admin SDK
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      uid = decodedToken.uid;
      phoneNumber = decodedToken.phone_number;
    } catch (firebaseErr) {
      console.warn('Firebase ID Token verification failed:', firebaseErr.message);

      // Dev mode fallback for manual testing if explicitly configured
      if (process.env.ALLOW_TEST_TOKENS === 'true' && idToken.startsWith('test_token_')) {
        const parts = idToken.split('_');
        phoneNumber = parts[2] || '+919876543210';
        uid = `test_uid_${phoneNumber.replace(/[^0-9]/g, '')}`;
        console.log(`[DEV MODE] Accepted test token for phone: ${phoneNumber}, uid: ${uid}`);
      } else {
        return res.status(401).json({
          success: false,
          message: 'Invalid Firebase ID Token',
          error: firebaseErr.message
        });
      }
    }

    if (!phoneNumber) {
      return res.status(400).json({
        success: false,
        message: 'Phone number not verified in Firebase account'
      });
    }

    // Ensure phone number format
    const formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : `+${phoneNumber}`;
    const qrData = `tel:${formattedPhone}`;

    // Find existing user by UID or phone number
    let user = await User.findOne({ $or: [{ uid }, { phone: formattedPhone }] });

    if (!user) {
      // Create new user
      user = await User.create({
        uid,
        phone: formattedPhone,
        name: `User ${formattedPhone.slice(-4)}`,
        qrData
      });
      console.log(`New user registered: ${user.phone}`);
    } else {
      // Update existing user UID and QR data if needed
      user.uid = uid;
      if (!user.qrData) {
        user.qrData = qrData;
      }
      await user.save();
    }

    // Generate backend JWT token
    const jwtPayload = {
      userId: user._id,
      uid: user.uid,
      phone: user.phone
    };

    const token = jwt.sign(
      jwtPayload,
      process.env.JWT_SECRET || 'super_secret_jwt_key_qr_dialer_2026',
      { expiresIn: '30d' }
    );

    return res.status(200).json({
      success: true,
      message: 'Authentication successful',
      token,
      user: {
        _id: user._id,
        uid: user.uid,
        name: user.name,
        phone: user.phone,
        qrData: user.qrData,
        createdAt: user.createdAt
      }
    });

  } catch (error) {
    console.error('Login Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error during authentication',
      error: error.message
    });
  }
};

module.exports = {
  login
};
