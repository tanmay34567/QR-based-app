const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  uid: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  phone: {
    type: String,
    required: true,
    unique: true
  },
  name: {
    type: String,
    default: function() {
      // Default to formatted phone or User
      return `User ${this.phone ? this.phone.slice(-4) : ''}`;
    }
  },
  qrData: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('User', UserSchema);
