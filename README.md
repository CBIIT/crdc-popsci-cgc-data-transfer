# Population Science Data Commons CGC Data Transfer Service
[![Coverage Status](https://coveralls.io/repos/github/CBIIT/crdc-popsci-cgc-data-transfer/badge.svg)](https://coveralls.io/github/CBIIT/crdc-popsci-cgc-data-transfer)

## Purpose

This microservice supports interoperability between the Population Science Data Commons (PSDC) and Cancer Genomics Cloud (CGC) to enable secure sharing of file manifest data. It acts as a bridge service that:

- **Receives manifest data** - Accepts CSV manifest files containing file metadata/listings from PSDC
- **Stores manifests in S3** - Uploads the manifest to an AWS S3 bucket with a unique filename
- **Generates time-limited signed URLs** - Creates CloudFront signed URLs that allow secure, temporary access to the manifest files
- **Returns access URLs** - Provides the signed URL back to the caller for secure file retrieval


## Main Endpoint

**POST** `/get-manifest-file-signed-url`
- Accepts manifest CSV data in request body
- Returns a time-limited signed URL for secure access
- URL expires after the configured duration (`SIGNED_URL_EXPIRY_SECONDS`)

This enables PSDC to share file manifests with CGC without exposing S3 credentials or requiring direct bucket access.

&nbsp;

## Requirements

### System Requirements
- **Node.js**: v22

### AWS Requirements
- AWS Account with:
  - S3 bucket for manifest file storage
  - CloudFront distribution configured with the S3 bucket
  - CloudFront key pair for signed URL generation
  - IAM credentials with S3 PutObject permissions

### Required Environment Variables

Create a `.env` file in the project root with the following variables:

```bash
# Application
VERSION=1.0.0
DATE=2025-12-30

# Bento Backend
BENTO_BACKEND_GRAPHQL_URI=<your-bento-backend-graphql-uri>

# AWS Configuration
AWS_REGION=<aws-region>
S3_ACCESS_KEY_ID=<your-s3-access-key>
S3_SECRET_ACCESS_KEY=<your-s3-secret-key>
FILE_MANIFEST_BUCKET_NAME=<your-s3-bucket-name>

# CloudFront Configuration
CLOUDFRONT_KEY_PAIR_ID=<your-cloudfront-key-pair-id>
CLOUDFRONT_PRIVATE_KEY=<your-cloudfront-private-key>
CLOUDFRONT_DOMAIN=<your-cloudfront-domain>
SIGNED_URL_EXPIRY_SECONDS=3600
```

### Installation & Running

```bash
# Install dependencies
npm install

# Start the application
npm start

# Run in debug mode
npm run debug

# Run tests
npm test
npm run test:ci

# Run tests with coverage
npm run test:coverage
```