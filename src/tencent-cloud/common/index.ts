export * from 'tencentcloud-sdk-nodejs/tencentcloud/common/interface';
import { Credential } from 'tencentcloud-sdk-nodejs/tencentcloud/common/interface';

/**
 * Get Tencent Cloud common credential.
 */
export function getCredential(): Credential {
  return {
    secretId: process.env.TENCENT_CLOUD_SECRET_ID,
    secretKey: process.env.TENCENT_CLOUD_SECRET_KEY,
  };
}
