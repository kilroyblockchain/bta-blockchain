import { EntryUserDetailDto } from './entry-user-detail.dto';

export class ModelReviewResponseDto {
  id: string;

  deployedUrl: string;

  deploymentInstruction: string;

  productionURL: string;

  reviewSupportingDocument: string;

  reviewStatus: string;

  ratings: string;

  comment: string;

  reviewedModelVersionId: string;

  recordDate: string;

  entryUserDetail: EntryUserDetailDto;

  creatorMSP: string;
}
