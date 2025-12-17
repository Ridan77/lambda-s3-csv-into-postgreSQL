import { S3Client, GetObjectCommand } from '@aws-sdk/client-s3'
import type { Context, S3Event } from 'aws-lambda'
import { Readable } from 'stream'
import { decodeCsvBuffer } from './hebrewDecoder'

const s3 = new S3Client({})

const streamToBuffer = async (stream: Readable): Promise<Buffer> =>
  new Promise((resolve, reject) => {
    const chunks: Buffer[] = []
    stream.on('data', (chunk) => chunks.push(chunk))
    stream.on('error', reject)
    stream.on('end', () => resolve(Buffer.concat(chunks)))
  })

export const handler = async (event: S3Event, context: Context) => {
  if (!event?.Records?.length) {
    console.warn('No S3 records in event')
    return { statusCode: 200 }
  }

  const record = event.Records[0]
  const bucket = record.s3.bucket.name
  const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '))
  const sizeBytes = record.s3.object.size

  console.log(
    JSON.stringify({
      requestId: context.awsRequestId,
      bucket,
      key,
      sizeBytes,
    })
  )

  const response = await s3.send(
    new GetObjectCommand({
      Bucket: bucket,
      Key: key,
    })
  )

  if (!response.Body) {
    throw new Error('Empty S3 object body')
  }
  const bodyBuffer = await streamToBuffer(response.Body as Readable)
  const csvText = decodeCsvBuffer(bodyBuffer)

  console.log('CSV content:\n', csvText)

  return { statusCode: 200 }
}
