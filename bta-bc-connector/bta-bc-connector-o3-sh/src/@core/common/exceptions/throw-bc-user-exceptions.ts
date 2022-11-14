import {
  ConflictException,
  InternalServerErrorException,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';

// eslint-disable-next-line
export const ThrowBcUserException = (err: Error) => {
  if (err.message.includes('Already Registered And Enrolled')) {
    throw new ConflictException([err.message]);
  } else if (err.message.includes('not found')) {
    throw new NotFoundException([err.message]);
  } else if (
    err.message.includes('Invalid Key or salt') ||
    err.message.includes('Authentication failure')
  ) {
    throw new UnauthorizedException([err.message]);
  } else if (err.message.includes('is already registered')) {
    throw new InternalServerErrorException(
      'User is already registered but not found on the wallet. Re-enroll the existing user for accessing',
    );
  } else {
    throw new InternalServerErrorException([err.message]);
  }
};
