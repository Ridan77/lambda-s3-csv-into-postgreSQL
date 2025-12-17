# S3 → Lambda CSV Ingestion Pipeline

## Overview

This document describes how to configure **AWS S3 event notifications** to trigger an **AWS Lambda** function when **CSV files** are uploaded. The pipeline is designed for **secure, event-driven ingestion** using a **private S3 bucket** and **prefix/suffix filtering**.

**High-level flow**:

```
Client upload (pre-signed URL)
        ↓
Private S3 bucket
        ↓  (ObjectCreated event)
Lambda function
        ↓
CSV processing (read / parse / persist)
```

---

## Key Concepts

### Amazon S3 (Simple Storage Service)

* Object storage service (not a filesystem)
* Stores **objects** identified by **keys** (paths)
* Emits **events** when object-level actions occur

### S3 Events

* Events are emitted on object lifecycle changes
* For ingestion, use:

  * `s3:ObjectCreated:*` (covers PUT, POST, multipart uploads)
* Events are **at-least-once** and **unordered**

### Lambda Invocation Model

* S3 sends **metadata only** (bucket + key)
* The file content is **not included** in the event
* Lambda must explicitly fetch the object from S3

---

## Bucket Configuration

### Bucket Settings

* **Public access**: Blocked (recommended)
* **Region**: Same region as Lambda
* **Encryption**: SSE-S3 (default)
* **Versioning**: Optional but recommended

### Folder / Prefix Structure (Logical)

```
incoming/
  csv/
processed/
failed/
```

> Note: S3 does not have real folders; these are key prefixes.

---

## Event Notification Configuration (Console)

Navigate to:

```
S3 → Bucket → Properties → Event notifications
```

### Notification Settings

* **Event type**: Object creation → All object create events
* **Event name**: `csv-upload-to-lambda`

### Filters

* **Prefix**: `incoming/csv/`
* **Suffix**: `.csv`

### Destination

* **Type**: Lambda function
* **Function**: Target CSV processor Lambda

AWS automatically adds a **resource-based policy** to allow S3 to invoke the Lambda.

---

## IAM Permissions

There are **two separate permissions** involved:

### 1. S3 → Lambda (Invoke Permission)

* Resource-based policy on the Lambda
* Automatically created by the console

### 2. Lambda → S3 (Read Permission)

* Identity-based policy on the Lambda execution role

#### Required Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::cerebi-csv-ingestion-dev/incoming/csv/*"
    }
  ]
}
```

---

## S3 Event Payload (Lambda Input)

Lambda receives an event shaped like:

```json
{
  "Records": [
    {
      "eventSource": "aws:s3",
      "eventName": "ObjectCreated:Put",
      "awsRegion": "eu-west-1",
      "s3": {
        "bucket": { "name": "cerebi-csv-ingestion-dev" },
        "object": { "key": "incoming/csv/test.csv" }
      }
    }
  ]
}
```

Key fields used:

* `record.s3.bucket.name`
* `record.s3.object.key`

---

## Lambda Implementation (TypeScript)

### Responsibilities

1. Extract bucket and key from the event
2. Fetch the CSV using `GetObject`
3. Read the object stream
4. Process the CSV contents

### Minimal Lambda Handler

```ts
import { S3Client, GetObjectCommand } from '@aws-sdk/client-s3'
import type { S3Event } from 'aws-lambda'
import { Readable } from 'stream'

const s3 = new S3Client({})

const streamToString = async (stream: Readable): Promise<string> =>
  new Promise((resolve, reject) => {
    const chunks: Buffer[] = []
    stream.on('data', (chunk) => chunks.push(chunk))
    stream.on('error', reject)
    stream.on('end', () => resolve(Buffer.concat(chunks).toString('utf-8')))
  })

export const handler = async (event: S3Event) => {
  const record = event.Records[0]

  const bucket = record.s3.bucket.name
  const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '))

  const response = await s3.send(
    new GetObjectCommand({ Bucket: bucket, Key: key })
  )

  if (!response.Body) throw new Error('Empty object body')

  const csv = await streamToString(response.Body as Readable)
  console.log(csv)

  return { statusCode: 200 }
}
```

> The AWS SDK v3 is provided by the Lambda runtime; it does not need to be bundled.

---

## Build & Deployment Notes

* TypeScript requires SDK modules at **build time**
* SDK can be installed as **devDependency only**
* Deployment artifact contains **only compiled JavaScript**

**ZIP contents**:

```
index.js
```

---

## Testing Matrix

| Path                    | File | Expected Result |
| ----------------------- | ---- | --------------- |
| `incoming/csv/test.csv` | CSV  | Lambda invoked  |
| `incoming/csv/test.txt` | TXT  | No invocation   |
| `incoming/test.csv`     | CSV  | No invocation   |

---

## Important Operational Notes

* Events are **at-least-once**; design Lambda to be idempotent
* No ordering guarantees
* Large CSVs should be streamed, not fully loaded into memory
* Consider moving processed files to `/processed/` or `/failed/`

---
Observability and Resource Monitoring

For data-processing Lambda functions, observability must come before optimization. Resource usage should be measured and logged consistently before changing memory or timeout settings.

What to observe per invocation:

Input file size (from the S3 event)

Execution duration (from the CloudWatch REPORT line)

Max memory used (from the CloudWatch REPORT line)

Request ID (for correlation across logs)

Recommended application-level logs:

At the start of each invocation, log lightweight, structured metadata:

const record = event.Records[0]

console.log(JSON.stringify({
requestId: context.awsRequestId,
bucket: record.s3.bucket.name,
key: record.s3.object.key,
sizeBytes: record.s3.object.size,
}))

This enables direct correlation between:
file size → runtime → memory usage

CloudWatch native metrics:

Each Lambda invocation automatically emits the following metrics:

Duration (milliseconds)

Billed duration (milliseconds)

Memory size (MB)

Max memory used (MB)

Init duration (cold start indicator)

Example CloudWatch output:

REPORT RequestId: ...
Duration: 209 ms
Memory Size: 128 MB
Max Memory Used: 106 MB

Tuning strategy:

Do not tune Lambda resources based on the smallest files.

Recommended approach:

Collect metrics across realistic file sizes

Increase memory only if:

Max memory usage consistently exceeds ~70–80%

Runtime increases disproportionately with file size

Timeout risk becomes visible

Re-measure after each configuration change

This approach avoids premature optimization and unnecessary cost.
## Summary

This setup provides:

* Secure, private S3 ingestion
* Precise event filtering
* Minimal Lambda deployment
* Clear IAM separation

The pattern is production-ready and suitable for customer-facing CSV ingestion pipelines.
