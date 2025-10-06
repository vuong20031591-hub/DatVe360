const User = require('../../../src/models/User');
const mongoose = require('mongoose');

describe('User Model', () => {
  describe('User Creation', () => {
    it('should create a valid user', async () => {
      const userData = {
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
        role: 'user',
      };

      const user = new User(userData);
      const savedUser = await user.save();

      expect(savedUser._id).toBeDefined();
      expect(savedUser.email).toBe(userData.email.toLowerCase());
      expect(savedUser.displayName).toBe(userData.displayName);
      expect(savedUser.role).toBe(userData.role);
      expect(savedUser.isActive).toBe(true);
      expect(savedUser.isVerified).toBe(false);
    });

    it('should hash password before saving', async () => {
      const userData = {
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      };

      const user = new User(userData);
      await user.save();

      expect(user.password).not.toBe(userData.password);
      expect(user.password).toMatch(/^\$2[ayb]\$.{56}$/); // bcrypt hash pattern
    });

    it('should fail without required fields', async () => {
      const user = new User({});

      let error;
      try {
        await user.save();
      } catch (err) {
        error = err;
      }

      expect(error).toBeDefined();
      expect(error.errors.email).toBeDefined();
      expect(error.errors.password).toBeDefined();
      expect(error.errors.displayName).toBeDefined();
    });

    it('should fail with invalid email', async () => {
      const userData = {
        email: 'invalid-email',
        password: 'password123',
        displayName: 'Test User',
      };

      const user = new User(userData);

      let error;
      try {
        await user.save();
      } catch (err) {
        error = err;
      }

      expect(error).toBeDefined();
      expect(error.errors.email).toBeDefined();
    });

    it('should fail with duplicate email', async () => {
      const userData = {
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      };

      await new User(userData).save();

      const duplicateUser = new User(userData);

      let error;
      try {
        await duplicateUser.save();
      } catch (err) {
        error = err;
      }

      expect(error).toBeDefined();
      expect(error.code).toBe(11000); // MongoDB duplicate key error
    });
  });

  describe('User Methods', () => {
    let user;

    beforeEach(async () => {
      user = new User({
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      });
      await user.save();
    });

    it('should compare password correctly', async () => {
      const isMatch = await user.comparePassword('password123');
      expect(isMatch).toBe(true);

      const isNotMatch = await user.comparePassword('wrongpassword');
      expect(isNotMatch).toBe(false);
    });

    it('should generate password reset token', async () => {
      await user.generatePasswordReset();

      expect(user.resetPasswordToken).toBeDefined();
      expect(user.resetPasswordExpires).toBeDefined();
      expect(user.resetPasswordExpires.getTime()).toBeGreaterThan(Date.now());
    });

    it('should add and remove refresh tokens', async () => {
      const token1 = 'refresh_token_1';
      const token2 = 'refresh_token_2';

      await user.addRefreshToken(token1);
      await user.addRefreshToken(token2);

      expect(user.refreshTokens).toHaveLength(2);
      expect(user.refreshTokens).toContain(token1);
      expect(user.refreshTokens).toContain(token2);

      await user.removeRefreshToken(token1);
      expect(user.refreshTokens).toHaveLength(1);
      expect(user.refreshTokens).not.toContain(token1);
      expect(user.refreshTokens).toContain(token2);
    });

    it('should clear all refresh tokens', async () => {
      await user.addRefreshToken('token1');
      await user.addRefreshToken('token2');
      await user.addRefreshToken('token3');

      expect(user.refreshTokens).toHaveLength(3);

      await user.clearRefreshTokens();
      expect(user.refreshTokens).toHaveLength(0);
    });

    it('should update last login', async () => {
      const beforeLogin = user.lastLoginAt;
      await new Promise(resolve => setTimeout(resolve, 10)); // Small delay

      await user.updateLastLogin();

      expect(user.lastLoginAt).toBeDefined();
      if (beforeLogin) {
        expect(user.lastLoginAt.getTime()).toBeGreaterThan(beforeLogin.getTime());
      }
    });
  });

  describe('User Statics', () => {
    beforeEach(async () => {
      await User.create([
        {
          email: 'user1@example.com',
          password: 'password123',
          displayName: 'User 1',
        },
        {
          email: 'user2@example.com',
          password: 'password123',
          displayName: 'User 2',
          phoneNumber: '0123456789',
        },
      ]);
    });

    it('should find user by email', async () => {
      const user = await User.findByEmail('user1@example.com');
      expect(user).toBeDefined();
      expect(user.email).toBe('user1@example.com');

      const notFound = await User.findByEmail('notfound@example.com');
      expect(notFound).toBeNull();
    });

    it('should find user by phone number', async () => {
      const user = await User.findByPhoneNumber('0123456789');
      expect(user).toBeDefined();
      expect(user.phoneNumber).toBe('0123456789');

      const notFound = await User.findByPhoneNumber('9999999999');
      expect(notFound).toBeNull();
    });
  });

  describe('User Roles', () => {
    it('should create user with default role', async () => {
      const user = new User({
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      });
      await user.save();

      expect(user.role).toBe('user');
    });

    it('should create admin user', async () => {
      const admin = new User({
        email: 'admin@example.com',
        password: 'password123',
        displayName: 'Admin User',
        role: 'admin',
      });
      await admin.save();

      expect(admin.role).toBe('admin');
    });

    it('should create operator user', async () => {
      const operator = new User({
        email: 'operator@example.com',
        password: 'password123',
        displayName: 'Operator User',
        role: 'operator',
      });
      await operator.save();

      expect(operator.role).toBe('operator');
    });

    it('should fail with invalid role', async () => {
      const user = new User({
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
        role: 'invalid_role',
      });

      let error;
      try {
        await user.save();
      } catch (err) {
        error = err;
      }

      expect(error).toBeDefined();
      expect(error.errors.role).toBeDefined();
    });
  });
});

