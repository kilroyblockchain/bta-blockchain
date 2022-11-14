import { ModelVersionProjectDto } from 'src/components/model-version/dto/model-version-project.dto';
import { PurposeDetail } from './store-project.dto';

export class ProjectResponseDto {
  projectId: string;

  name: string;

  detail: string;

  domain: string;

  members: string[];

  status: boolean;

  creatorMSP: string;

  entryUser: string;

  recordDate: string;

  modelVersions: ModelVersionProjectDto[];

  purposeDetail: PurposeDetail;

  createdBy: string;
}
