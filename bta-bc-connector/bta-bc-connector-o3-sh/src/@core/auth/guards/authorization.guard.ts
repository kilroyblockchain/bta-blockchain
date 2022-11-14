import {
  Injectable,
  ExecutionContext,
  CanActivate,
  Logger,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import * as dotenv from 'dotenv';
dotenv.config();

@Injectable()
export class AuthorizationGuard implements CanActivate {
  // eslint-disable-next-line
  async canActivate(context: ExecutionContext) {
    const logger = new Logger('AuthorizationGuard');
    const headers = context.switchToHttp().getRequest().headers;
    if (!headers.authorization) {
      logger.error('Authorization not found on the header');
      throw new BadRequestException([
        'Need full authentication to access the resource',
      ]);
    }
    if (headers.authorization !== 'Basic ' + process.env.AUTHORIZATION_TOKEN) {
      logger.error('Authorization token does not match');
      throw new ForbiddenException([
        'Need full authentication to access the resource',
      ]);
    }
    if (headers.org_name !== process.env.ORG_NAME) {
      logger.error('Org Name does not match');
      throw new ForbiddenException([
        'Need full authentication to access the resource',
      ]);
    }
    return headers;
  }
}
