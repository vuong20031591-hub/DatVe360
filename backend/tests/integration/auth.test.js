const request = require('supertest');
const express = require('express');
const authRoutes = require('../../src/routes/auth');
const User = require('../../src/models/User');

// Create test app
const app = express();
app.use(express.json());
app.use('/api/v1/auth', authRoutes);

describe('Auth API Integration Tests', () => {
  describe('POST /api/v1/auth/register', () => {
    it('should register a new user successfully', async () => {
      const userData = {
        email: 'newuser@example.com',
        password: 'Password123',
        displayName: 'New User',
        phoneNumber: '0123456789',
      };

      const response = await request(app)
        .post('/api/v1/auth/register')
        .send(userData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('Đăng ký thành công');
      expect(response.body.data.user).toBeDefined();
      expect(response.body.data.user.email).toBe(userData.email.toLowerCase());
      expect(response.body.data.user.displayName).toBe(userData.displayName);
      expect(response.body.data.tokens).toBeDefined();
      expect(response.body.data.tokens.accessToken).toBeDefined();
      expect(response.body.data.tokens.refreshToken).toBeDefined();
    });

    it('should fail with duplicate email', async () => {
      const userData = {
        email: 'duplicate@example.com',
        password: 'Password123',
        displayName: 'User 1',
      };

      // Create first user
      await request(app)
        .post('/api/v1/auth/register')
        .send(userData)
        .expect(201);

      // Try to create duplicate
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send(userData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Email đã được sử dụng');
    });

    it('should fail with invalid email', async () => {
      const userData = {
        email: 'invalid-email',
        password: 'Password123',
        displayName: 'Test User',
      };

      const response = await request(app)
        .post('/api/v1/auth/register')
        .send(userData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Email không hợp lệ');
    });

    it('should fail with short password', async () => {
      const userData = {
        email: 'test@example.com',
        password: '12345', // Too short
        displayName: 'Test User',
      };

      const response = await request(app)
        .post('/api/v1/auth/register')
        .send(userData)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Mật khẩu phải có ít nhất 6 ký tự');
    });

    it('should fail without required fields', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /api/v1/auth/login', () => {
    let testUser;

    beforeEach(async () => {
      // Create test user
      testUser = await User.create({
        email: 'testuser@example.com',
        password: 'Password123',
        displayName: 'Test User',
      });
    });

    it('should login successfully with correct credentials', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'testuser@example.com',
          password: 'Password123',
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('Đăng nhập thành công');
      expect(response.body.data.user).toBeDefined();
      expect(response.body.data.user.email).toBe(testUser.email);
      expect(response.body.data.tokens).toBeDefined();
      expect(response.body.data.tokens.accessToken).toBeDefined();
      expect(response.body.data.tokens.refreshToken).toBeDefined();
    });

    it('should fail with incorrect password', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'testuser@example.com',
          password: 'WrongPassword',
        })
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Email hoặc mật khẩu không chính xác');
    });

    it('should fail with non-existent email', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'notfound@example.com',
          password: 'Password123',
        })
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Email hoặc mật khẩu không chính xác');
    });

    it('should fail with invalid email format', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'invalid-email',
          password: 'Password123',
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Email không hợp lệ');
    });

    it('should fail without password', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'testuser@example.com',
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Mật khẩu không được để trống');
    });
  });

  describe('POST /api/v1/auth/forgot-password', () => {
    let testUser;

    beforeEach(async () => {
      testUser = await User.create({
        email: 'testuser@example.com',
        password: 'Password123',
        displayName: 'Test User',
      });
    });

    it('should send password reset email for existing user', async () => {
      const response = await request(app)
        .post('/api/v1/auth/forgot-password')
        .send({
          email: 'testuser@example.com',
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain('Link đặt lại mật khẩu đã được gửi');

      // Check that reset token was generated
      const updatedUser = await User.findById(testUser._id);
      expect(updatedUser.resetPasswordToken).toBeDefined();
      expect(updatedUser.resetPasswordExpires).toBeDefined();
    });

    it('should fail with non-existent email', async () => {
      const response = await request(app)
        .post('/api/v1/auth/forgot-password')
        .send({
          email: 'notfound@example.com',
        })
        .expect(404);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Không tìm thấy tài khoản');
    });

    it('should fail with invalid email format', async () => {
      const response = await request(app)
        .post('/api/v1/auth/forgot-password')
        .send({
          email: 'invalid-email',
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Email không hợp lệ');
    });
  });

  describe('POST /api/v1/auth/reset-password', () => {
    let testUser;
    let resetToken;

    beforeEach(async () => {
      testUser = await User.create({
        email: 'testuser@example.com',
        password: 'OldPassword123',
        displayName: 'Test User',
      });

      await testUser.generatePasswordReset();
      resetToken = testUser.resetPasswordToken;
    });

    it('should reset password with valid token', async () => {
      const newPassword = 'NewPassword123';

      const response = await request(app)
        .post('/api/v1/auth/reset-password')
        .send({
          token: resetToken,
          password: newPassword,
        })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain('Đặt lại mật khẩu thành công');

      // Verify password was changed
      const updatedUser = await User.findById(testUser._id).select('+password');
      const isMatch = await updatedUser.comparePassword(newPassword);
      expect(isMatch).toBe(true);

      // Verify reset token was cleared
      expect(updatedUser.resetPasswordToken).toBeUndefined();
      expect(updatedUser.resetPasswordExpires).toBeUndefined();
    });

    it('should fail with invalid token', async () => {
      const response = await request(app)
        .post('/api/v1/auth/reset-password')
        .send({
          token: 'invalid-token',
          password: 'NewPassword123',
        })
        .expect(401);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Token không hợp lệ hoặc đã hết hạn');
    });

    it('should fail with short password', async () => {
      const response = await request(app)
        .post('/api/v1/auth/reset-password')
        .send({
          token: resetToken,
          password: '12345', // Too short
        })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('Mật khẩu mới phải có ít nhất 6 ký tự');
    });
  });
});

