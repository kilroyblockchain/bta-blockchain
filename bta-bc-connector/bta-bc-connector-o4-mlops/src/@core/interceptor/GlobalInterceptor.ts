import {
  BadRequestException,
  CallHandler,
  ExecutionContext,
  HttpException,
  Injectable,
  InternalServerErrorException,
  Logger,
  NestInterceptor,
  NotFoundException,
} from '@nestjs/common';
import { catchError, Observable } from 'rxjs';
import { CHANNEL_CONSTANT } from '../common/constants/channel.constant';

@Injectable()
export class GlobalInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    // next.handle() is an Observable of the controller's result value
    return next.handle().pipe(
      catchError((error: Error) => {
        const logger = new Logger('GlobalInterceptor');
        logger.error(error);
        if (
          error.message.includes('not found') ||
          error.message.includes('make sure the chaincode') ||
          error.message.includes(CHANNEL_CONSTANT.CHANNEL_NOT_FOUND)
        )
          throw new NotFoundException([error.message]);

        if (error.message.includes('Incorrect number of params'))
          throw new BadRequestException([error.message]);

        // Incase of Http Exception like NotFoundException thrown
        if (error instanceof HttpException) throw error;

        // Incase of Error not matching above errors
        throw new InternalServerErrorException([error.message]);
      }),
    );
  }
}
