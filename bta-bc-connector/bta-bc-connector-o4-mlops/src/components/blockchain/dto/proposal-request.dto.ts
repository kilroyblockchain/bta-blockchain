import Client from 'fabric-client';
export class ProposalRequestDto {
  targets: string[];
  chaincodeId: string;
  fcn: string;
  args: Array<string>;
  chainId: string;
  txId: Client.TransactionId;
  // eslint-disable-next-line
  transientMap: any;
}
