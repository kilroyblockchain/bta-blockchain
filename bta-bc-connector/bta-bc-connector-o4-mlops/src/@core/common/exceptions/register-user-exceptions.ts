import {
  ForbiddenException,
  HttpStatus,
  InternalServerErrorException,
} from '@nestjs/common';
import { COMMON_ERROR } from '../constants/common-error.constant';
import { Response } from '../dto/response.dto';
import { USER_CONSTANT } from '../constants/user.constant';

// eslint-disable-next-line
export const ThrowRegisterUserException = (response: Response) => {
  if (response.statusCode == HttpStatus.FORBIDDEN) {
    throw new ForbiddenException([USER_CONSTANT.USER_REGISTER_FAILED]);
  } else {
    throw new InternalServerErrorException([COMMON_ERROR.SOMETHING_WENT_WRONG]);
  }
};
