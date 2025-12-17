// csvParser.ts
import { parse } from 'csv-parse/sync'

export type CsvRow = Record<string, string>

export function parseCsv(csvText: string): CsvRow[] {
  return parse(csvText, {
    columns: true,              // first row = headers
    skip_empty_lines: true,
    relax_quotes: true,
    relax_column_count: true,
    trim: true,
  })
}
