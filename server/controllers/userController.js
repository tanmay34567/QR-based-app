const User = require('../models/User');

/**
 * @desc   Get logged in user profile
 * @route  GET /api/user
 * @access Private (JWT)
 */
const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.userId).select('-__v');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User profile not found'
      });
    }

    return res.status(200).json({
      success: true,
      user
    });
  } catch (error) {
    console.error('Get Profile Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error retrieving profile',
      error: error.message
    });
  }
};

/**
 * @desc   Update logged in user profile
 * @route  PUT /api/user
 * @access Private (JWT)
 */
const updateProfile = async (req, res) => {
  try {
    const { name, qrData } = req.body;
    const user = await User.findById(req.user.userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User profile not found'
      });
    }

    if (name !== undefined) {
      user.name = name.trim();
    }

    if (qrData !== undefined) {
      // Ensure qrData maintains valid TEL URI structure
      if (qrData.startsWith('tel:')) {
        user.qrData = qrData;
      } else {
        user.qrData = `tel:${qrData}`;
      }
    }

    await user.save();

    return res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
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
    console.error('Update Profile Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error updating profile',
      error: error.message
    });
  }
};

module.exports = {
  getProfile,
  updateProfile
};
