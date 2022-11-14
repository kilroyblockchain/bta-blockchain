import * as crypto from 'crypto';

export const GenerateUniqueId = (): string => {
  return crypto.randomBytes(20).toString('hex');
};

export const GenerateSHA1Hash = (args: string): string => {
  const hash = crypto.createHash('sha1');
  hash.write(args); // write a single line to the buffer
  return hash.digest('hex'); // returns hash as string
};

/**
 * Hash string using sha256 hashing algorithm
 *
 * @param {string} args - String to hashed string
 * @return {Promise<string>} - Returns Promise of hashed hex string
 *
 *
 */
export const GenerateSHA256Hash = (args: string): string => {
  const hash = crypto.createHash('sha256');
  hash.write(args); // write a single line to the buffer
  return hash.digest('hex'); // returns hash as string
};
