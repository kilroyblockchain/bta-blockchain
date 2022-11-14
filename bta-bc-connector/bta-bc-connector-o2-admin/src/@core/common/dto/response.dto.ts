export class Response {
  success: boolean;
  statusCode: number;
  message: string[] | string;
  // eslint-disable-next-line
  data: any;

  // eslint-disable-next-line
  constructor(message: string[] | string, data?: any) {
    this.message = message;
    this.data = data;
  }

  setStatusCode(statusCode: number): this {
    this.statusCode = statusCode;
    return this;
  }

  setSuccess(success: boolean): this {
    this.success = success;
    return this;
  }
}
