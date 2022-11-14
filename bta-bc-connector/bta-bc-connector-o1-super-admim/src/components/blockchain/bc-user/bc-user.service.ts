import { Injectable, Logger } from '@nestjs/common';
import Client, * as hfc from 'fabric-client';
import { USER_CONSTANT } from 'src/@core/common/constants/user.constant';
import { GenerateSHA1Hash, GenerateSHA256Hash } from 'src/@core/utils/helper';
import { ThrowBcUserException } from 'src/@core/common/exceptions/throw-bc-user-exceptions';
import { RegisterUserDto } from './dto/register-user.dto';
import { BcUserResponseDto } from './dto/bc-user-response.dto';

@Injectable()
export class BcUserService {
  /**
   * GetClientInfoForOrg function loads the client necessary connection and crypto details from the data provided on connection profile
   * If username is passed on the parameter then, checks whether the user is enrolled or not before getting the client information
   *
   *
   * @param {string} orgName - Name of the organization to get the connection profile details
   * @param {string} key - Key of the user to get the detail
   * @param {string} salt - Unique string associated with the key generated
   * @returns {Promise<Client>} - Returns response type Client
   *
   *
   **/
  async getClientInfoForOrg(
    orgName: string,
    key?: string,
    salt?: string,
  ): Promise<Client> {
    try {
      const logger = new Logger('GetClientForOrg');
      const connectionProfilePath = process.env.CONNECTION_FILE_PATH;
      const configFile =
        connectionProfilePath +
        'connection-profile-' +
        orgName.toLowerCase() +
        '.yaml';
      const client: Client = hfc.loadFromConfig(configFile);
      // this will create both the state store and the crypto store based
      // on the settings in the client section of the connection profile
      await client.initCredentialStores();

      if (key) {
        const generatedKeyData = this.generateKey(key, salt);
        const keyHash = generatedKeyData[0];
        // Hash Username
        const user = await client.getUserContext(keyHash, true);
        if (!user) {
          logger.error('Invalid Key or salt');
          throw new Error('Invalid Key or salt');
        }
        logger.log('User found on the wallet');
      }
      return client;
    } catch (err) {
      const error: Error = err;
      if (error.message.includes('no such file or directory')) {
        throw new Error(
          'Connection Profile not found for the organization ' + orgName,
        );
      }
      throw new Error(err);
    }
  }

  /**
   * EnrollAndRegisterUser function that registers the user on blockchain network and stores the user credentials on the wallet
   *
   *
   * @param {string} userName - Username to be registered
   * @param {string} orgName - Name of the organization where the user is going to be enrolled
   * @returns {Promise<Client>} - Returns response type Client
   *
   *
   **/
  async enrollAndRegisterUser(
    registerUserDto: RegisterUserDto,
    orgName: string,
  ): Promise<BcUserResponseDto> {
    const logger = new Logger('EnrollAndRegisterUser');
    try {
      const caAdminId = process.env.CA_ADMIN_ID;
      const caAdminPassword = process.env.CA_ADMIN_PWD;
      const client = await this.getClientInfoForOrg(orgName);

      const registerUserDtoString = JSON.stringify(registerUserDto);
      // Hash Username

      const hashedData = GenerateSHA256Hash(registerUserDtoString);
      const generatedKeyData = this.generateKey(hashedData);
      const key = generatedKeyData[0];
      const salt = generatedKeyData[1];

      // client can now act as an agent for organization
      // first check to see if the user is already on the wallet
      let user = await client.getUserContext(key, true);
      if (user && user.isEnrolled()) {
        logger.error(USER_CONSTANT.USER_ALREADY_REGISTERED);
        throw new Error(
          'User ' +
            registerUserDto.email +
            ' Is Already Registered And Enrolled',
        );
      } else {
        // user was not enrolled, so we will need an admin user object to register
        logger.log(
          'User ' +
            registerUserDto.email +
            ' was not enrolled, so we will need admin user object to register',
        );

        const adminUserObj = await client.setUserContext({
          username: caAdminId,
          password: caAdminPassword,
        });
        logger.log(USER_CONSTANT.USER_CONTEXT_SET_SUCCESS + caAdminId);
        const caClient = client.getCertificateAuthority();
        await caClient.register(
          {
            enrollmentID: key,
            enrollmentSecret: key + salt,
            affiliation: 'org1.department1',
            maxEnrollments: 50,
          },
          adminUserObj,
        );
        logger.log(USER_CONSTANT.USER_SECRET_FOUND + registerUserDto.email);
        // Add User credentials to the wallet
        user = await client.setUserContext({
          username: key,
          password: key + salt,
        });
        logger.log(
          'Successfully enrolled username ' +
            registerUserDto.email +
            ' and setUserContext on the client object',
        );
      }
      return new BcUserResponseDto(hashedData, salt);
    } catch (err) {
      logger.error(err);
      await ThrowBcUserException(err);
    }
  }

  async userReEnrollment(
    registerUserDto: RegisterUserDto,
    orgName: string,
  ): Promise<BcUserResponseDto> {
    const logger = new Logger('EnrollAndRegisterUser');
    try {
      const client = await this.getClientInfoForOrg(orgName);

      const registerUserDtoString = JSON.stringify(registerUserDto);
      // Hash Username

      const hashedData = GenerateSHA256Hash(registerUserDtoString);
      const generatedKeyData = this.generateKey(hashedData);
      const key = generatedKeyData[0];
      const salt = generatedKeyData[1];

      // client can now act as an agent for organization
      // first check to see if the user is already on the wallet
      const user = await client.getUserContext(key, true);
      if (user && user.isEnrolled()) {
        logger.error(USER_CONSTANT.USER_ALREADY_REGISTERED);
        throw new Error(
          'User ' +
            registerUserDto.email +
            ' Is Already Registered And Enrolled',
        );
      } else {
        // user was not enrolled, so we will need an admin user object to register
        logger.log(
          'User ' +
            registerUserDto.email +
            ' was not enrolled, so we will need admin user object to register',
        );

        const loginUser = await client.setUserContext({
          username: key,
          password: key + salt,
        });
        const caClient = client.getCertificateAuthority();
        await caClient.reenroll(loginUser, [{ name: key, optional: true }]);

        logger.log(
          'Successfully re-enrolled user ' +
            registerUserDto.email +
            ' and setUserContext on the client object',
        );
      }
      return new BcUserResponseDto(hashedData, salt);
    } catch (err) {
      logger.error(err);
      await ThrowBcUserException(err);
    }
  }

  private generateKey(hashedData: string, salt?: string): string[] {
    if (!salt) {
      salt = GenerateSHA1Hash(hashedData);
    }
    return [GenerateSHA256Hash(salt + hashedData + salt), salt];
  }
}
