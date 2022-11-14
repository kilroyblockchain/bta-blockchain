import {
  BadRequestException,
  HttpStatus,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { ChaincodeResponseDto } from '../dto/chaincode-response.dto';

// eslint-disable-next-line
export const HandleChaincodeException = (
  chaincodeResponseDto: ChaincodeResponseDto,
): Promise<void> => {
  switch (chaincodeResponseDto.statusCode) {
    case HttpStatus.BAD_REQUEST:
      throw new BadRequestException([chaincodeResponseDto.message]);
    case HttpStatus.NOT_FOUND:
      throw new NotFoundException([chaincodeResponseDto.message]);
    default:
      throw new InternalServerErrorException([chaincodeResponseDto.message]);
  }
};
