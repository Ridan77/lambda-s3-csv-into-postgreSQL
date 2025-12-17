import iconv from 'iconv-lite'

export function decodeCsvBuffer(buffer: Buffer): string {
  // 1. Try UTF-8
  let text = buffer.toString('utf-8')

  // 2. Strip UTF-8 BOM if present
  text = text.replace(/^\uFEFF/, '')

  // 3. Heuristic: replacement character � indicates wrong encoding
  const replacementCharCount = (text.match(/�/g) || []).length

  if (replacementCharCount > 0) {
    // 4. Fallback to Windows-1255
    const win1255 = iconv.decode(buffer, 'windows-1255')

    // Optional sanity check: must contain Hebrew letters
    if (!/[א-ת]/.test(win1255)) {
      throw new Error('CSV encoding not supported (not UTF-8 or Windows-1255)')
    }
    console.log('CSV is win1255')
    return win1255
  }
  console.log('CSV is UTF8')

  return text
}
