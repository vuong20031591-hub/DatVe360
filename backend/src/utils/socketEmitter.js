/**
 * Socket Emitter Utility
 * Helper functions to emit socket events from anywhere in the application
 */

let io = null;

/**
 * Initialize socket emitter with io instance
 */
const init = (ioInstance) => {
  io = ioInstance;
};

/**
 * Get socket handler instance
 */
const getHandler = () => {
  if (!io || !io.socketHandler) {
    console.warn('Socket.IO not initialized');
    return null;
  }
  return io.socketHandler;
};

/**
 * Emit booking status update
 */
const emitBookingUpdate = (bookingId, data) => {
  const handler = getHandler();
  if (handler) {
    handler.emitBookingUpdate(bookingId, data);
  }
};

/**
 * Emit payment status update
 */
const emitPaymentUpdate = (paymentId, data) => {
  const handler = getHandler();
  if (handler) {
    handler.emitPaymentUpdate(paymentId, data);
  }
};

/**
 * Emit seat availability update
 */
const emitSeatUpdate = (scheduleId, data) => {
  const handler = getHandler();
  if (handler) {
    handler.emitSeatUpdate(scheduleId, data);
  }
};

/**
 * Emit notification to specific user
 */
const emitToUser = (userId, event, data) => {
  const handler = getHandler();
  if (handler) {
    handler.emitToUser(userId, event, data);
  }
};

/**
 * Emit notification to all admins
 */
const emitToAdmins = (event, data) => {
  const handler = getHandler();
  if (handler) {
    handler.emitToAdmins(event, data);
  }
};

/**
 * Emit new booking notification to admins
 */
const notifyNewBooking = (booking) => {
  emitToAdmins('booking:new', {
    bookingId: booking.bookingId,
    totalAmount: booking.totalAmount,
    passengers: booking.passengers?.length || 0,
    createdAt: booking.createdAt,
  });
};

/**
 * Emit booking cancellation notification
 */
const notifyBookingCancelled = (booking) => {
  emitToAdmins('booking:cancelled', {
    bookingId: booking.bookingId,
    reason: booking.cancellationReason,
    cancelledAt: new Date(),
  });
};

/**
 * Emit payment success notification
 */
const notifyPaymentSuccess = (payment, booking) => {
  // Notify user
  if (booking.userId) {
    emitToUser(booking.userId.toString(), 'payment:success', {
      bookingId: booking.bookingId,
      paymentId: payment._id,
      amount: payment.amount,
      method: payment.method,
    });
  }

  // Notify admins
  emitToAdmins('payment:received', {
    bookingId: booking.bookingId,
    paymentId: payment._id,
    amount: payment.amount,
    method: payment.method,
  });
};

/**
 * Emit payment failure notification
 */
const notifyPaymentFailed = (payment, booking) => {
  if (booking.userId) {
    emitToUser(booking.userId.toString(), 'payment:failed', {
      bookingId: booking.bookingId,
      paymentId: payment._id,
      reason: payment.failureReason,
    });
  }
};

module.exports = {
  init,
  emitBookingUpdate,
  emitPaymentUpdate,
  emitSeatUpdate,
  emitToUser,
  emitToAdmins,
  notifyNewBooking,
  notifyBookingCancelled,
  notifyPaymentSuccess,
  notifyPaymentFailed,
};

