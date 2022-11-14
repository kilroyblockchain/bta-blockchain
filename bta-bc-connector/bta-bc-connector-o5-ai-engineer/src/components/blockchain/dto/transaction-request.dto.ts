import Client from 'fabric-client';
export class TransactionRequestDto {
  txId: Client.TransactionId;
  proposalResponses: Client.ProposalResponse[];
  proposal: Client.Proposal;
}
