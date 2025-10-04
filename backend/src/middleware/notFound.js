const notFound = (req, res, next) => {
  res.status(404).json({
    success: false,
    message: `Không tìm thấy route ${req.originalUrl}`,
    requestedUrl: req.originalUrl,
    method: req.method,
    timestamp: new Date().toISOString()
  });
};

module.exports = notFound;
